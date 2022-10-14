# set FULL to 1 to include support in Movie and ShineSelect
.set FULL, 1
.include "LevelSelect.s"

.Mar.changeState:
## Level Select
  #lbz r0, 0x64(r31)
  #cmpwi r0, 0
  #beq- .Mar.changeState.done
  bl LevelSelect
  bne+ cr1, .Mar.changeState.done # not activated
  mr r3, r31
  bl TMarDirector.moveStage
  li r28, 9 # nextState = LevelTransition
  b .Mar.changeState.applied
.Mar.changeState.done:
  lbz r0, 0x64(r31)
  b 4+$b$.Mar.changeState

.Mar.moveStage:
  lis r817F, 0x817F
  lhz r0, $LevelSelect.en@l(r817F) # [LS, AL]
  cmpwi r0, 1 # AL only
  bne .Mar.moveStage.done
## clear FMV flag
  lhz r0, 0x4c(r31)
  rlwinm r0, r0, 0, 0x18, 0x16
  sth r0, 0x4c(r31)
## store nextArea and set flags
  lwz rFM, TFlagManager.smInstance$r13(r13)
  mr rApp, r28
  lhz rAns, 0xE(rApp)
  bl handleRestartN
## set curArea = prevArea # TODO
  lhz rAns, 0xa(r28)
  sth rAns, 0xe(r28)
.Mar.moveStage.done:
## orig
  li r0, 0xff
  addi r4, r1, 0x54
  b 4+$b$.Mar.moveStage

.Mar.disable.PinnaFMV:
  lis r12, 0x817F
  lbz r4, $AreaLock.en@l(r12)
  xori r4, r4, 1 # locked ? false : true
  b TFlagManager.setBool


.if FULL == 1
# @Movie
.Movie.direct:
  bl LevelSelect
  bne+ cr1, .Movie.direct.done # not activated
  li r3, 2
  stw r3, 0x12c(r1)
.Movie.direct.done:
## orig
  lwz r3, 0x20(r31)
  b 4+$b$.Movie.direct

.Movie.decideNextMode:
  lis r817F, 0x817F
  lbz r0, $LevelSelect.en@l(r817F)
  cmpwi r0, 1 # test if LS activated
  bne .Movie.moveStage.done
## return
  b .Movie.decideNextMode.applied
.Movie.moveStage.done:
## orig
  cmplwi r5, 0xe
  b 4+$b$.Movie.decideNextMode

# @ShineSelect
.ShineSelect.direct:
  bl LevelSelect
  bne+ cr1, .ShineSelect.direct.done # not activated
  b .ShineSelect.direct.applied
.ShineSelect.direct.done:
## orig
  lwz r3, 0x20(r30)
  subi r5, r31, 0x34
  lbz r0, 0x13b(r3)
  b 4+$b$.ShineSelect.direct
.endif

.gameLoop.preReturn:
## reset LevelSelect.en
  lis r3, 0x817F
  li r0, 0
  stb r0, $LevelSelect.en@l(r3)
## orig
  mr r3, r29
  b 4+$b$.gameLoop.preReturn

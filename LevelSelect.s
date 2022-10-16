.set r817F, 3 # 817F0000
.set rC, 4
.set rBtn, 5
.set rC4, 5
.set rIdx, 6
.set rAns, 7
.set rAnsEp, 8
.set rD, 9 # BL trick
.set rApp, 10 # gpApplication
.set rFM, 11 # FlagManager
.set rArr, 12 # tmp

LevelSelect: # cr1.EQ: activated
## read button input: [M]*1 [C]*1 [btn]*2
  lis rBtn, JUTGamePad.mPadButton@ha
  lwz rBtn, JUTGamePad.mPadButton@l(rBtn)
## check input
  andi.  r0, rBtn, 0x208
  cmplwi cr1, r0, 0x208
## check if already activated
  lis r817F, 0x817F
  lbz r0, $LevelSelect.en@l(r817F)
  mr. r0, r0
## return if needed
  # cr1.eq && cr0.eq
  crand 4*cr1+eq, 4*cr1+eq, eq
  bnelr+ cr1
## Level Select
  mflr r12
  bl .L.LevelSelect
.D:
.D.Special:
  # 8 bit/entry: [1bit] epFlag==7 | [7bit] area
  .long 0x00141516
  .long 0x0017181D
  .long 0x34000090 # Red coin fish@NB8: 0x80|0x10
.D.Secrets:
  # 8 bit/entry: [1bit] ep==1 | [7bit] area
  .long 0x2F2E3020
  .long 0x32293328
  .long 0x2A1FBA3C
.D.Sublevels:
  # 8 bit/entry
  .long 0x371E213A
  .long 0x0E2C3900
.D.Plaza:
  .long 0x00010507
  .long 0x08090200
.D.Extra:
.D.PinnaPark:
## ep: 0,1,2,3,4,5,7 | area=D
## epFlag: 0,2,4,5,6,7,0
  .long 0x123457D0
  .long 0x24567000
.D.SirenaHotel:
## ep: 0,1,2,2,3,4 | area=7
## episo: 1,2,3,4,6,7
  .long 0x12234070
  .long 0x23467001

.L.LevelSelect:
  mflr rD
  mtlr r12
## prepare registers
  lis rApp, gpApplication@ha
  la  rApp, gpApplication@l(rApp)
  lwz rFM, TFlagManager.smInstance$r13(r13)

## calc index
## btn: S YXZA -LRZ ----
## XZRL=8,4,2,1
  rlwinm rIdx, rBtn, 32-7, 0x8 # X=8
  rlwimi rIdx, rBtn, 32-2, 0x4 # Z=4
  rlwimi rIdx, rBtn, 32-4, 0x2 # R=2
  rlwimi rIdx, rBtn, 32-6, 0x1 # L=1
## YSY=8,4,2
  rlwinm r0, rBtn, 32- 8, 0x8 # Y=+8
  rlwimi r0, rBtn, 32-10, 0x6 # S,Y=4,+2
## merge XZRL and YSY-
  or rIdx, rIdx, r0
# TODO? handle rIdx>=12

## check C==0(Special) or 9(Secrets)
  rlwinm. rC, rBtn, 32-16, 0xF
  beq handleSpecial
  cmpwi rC, 9
  beq handleSecrets

## calc C index
### [(*), 6, 2, (*); 4, 5, 3, (*); 0, (*), 1]
### 110 0/10 00/0 100/ 101 0|11 00/0 000/ 000 0/01 00
.set CIdxMagic, 06204530001<<(32-3*10)
### CIdx = magic <<(3*C) &7
  lis r0, CIdxMagic@h
  ori r0, r0, CIdxMagic@l
  mulli rC, rC, 3
  rlwnm rC, r0, rC, 0x7
## prepare CIdx<<2 (destroy rBtn)
  slwi rC4, rC, 2

## Y+Z(14) -> SirenaHotel
## X+Z(12) -> PinnaPark
  cmpwi rIdx, 12
  bge handleExtra

## Y(10) -> Plaza
  cmpwi rIdx, 10
  bge handlePlaza
## X(8) -> Sublevels
  cmpwi rIdx, 8
  bge handleSublevels

## stage
### area: [2, 3, 4, 5, 6, 8, 9, (*)]
### magic = 0x34568902 rotl sizeof(0xFF)
### ans = idx | (magic<<(Cidx<<2)) &0x0F00
### ep = idx
  lis r0, 0x5689
  ori r0, r0, 0x0234
  slwi rArr, rC, 2
  rlwnm rArr, r0, rArr, 0x0F00
  or rAns, rIdx, rArr
  rlwinm rAnsEp, rIdx, 0, 0x7
  b .L.loadStage

handleSpecial:
  lhz rAns, 0xE(rApp) # backup for handleRestartN
## neutral
  cmpwi rIdx, 0
  beq handleRestartN
## Z restart
  cmpwi rIdx, 4
  beq handleRestartZ
## Y restart
  cmpwi rIdx, 10
  beq handleRestartY
## Special
  # rD = .D.Special
  lbzx r0, rD, rIdx # offset = idx
  rlwinm rAns, r0, 8, 0x3F00
  rlwinm rAnsEp, r0, 32-7, 0x1
  mulli rAnsEp, rAnsEp, 7
  b .L.loadStage

handleRestartN:
## set prevMap = curMap
  lhz r0, 0xA(rApp)
  sth r0, 0xE(rApp)
handleRestartZ:
## load curMap, ep
  lbz rAnsEp, 0xDF(rFM)
  b .L.loadStageWithoutBackup
handleRestartY: # load 817F0000
  lhz rAns, $LevelSelect.area@l(r817F)
  lbz rAnsEp, $LevelSelect.epFlag@l(r817F)
  b .L.loadStage

handleSecrets:
  la rArr, .D.Secrets-.D(rD)
  lbzx r0, rArr, rIdx
  rlwinm rAns, r0, 8, 0x3F00
  rlwimi rAns, r0, 32-7, 0x0001
  # ep: 2,5,3,0,1,5,1,3,4,5,0,*
  .set SecretEpMagic, 05301513450<<2 | 02
  lis r0, SecretEpMagic@h
  ori r0, r0, SecretEpMagic@l
  mulli rArr, rIdx, 3
  rlwnm rAnsEp, r0, rArr, 0x7
  b .L.loadStage

handleSublevels:
  la rArr, .D.Sublevels-.D(rD)
  lbzx r0, rArr, rC # Cidx as index
  rlwinm rAns, r0, 8, 0x3F00
  # ep: 1,1,3,7,3,2,3
  .set SublevelEpMagic, 0x13732301
  lis r0, SublevelEpMagic@h
  ori r0, r0, SublevelEpMagic@l
  rlwnm rAnsEp, r0, rC4, 0x7
  b .L.loadStage

handleExtra:
  la rArr, .D.Extra-.D-12*4(rD)
  rlwinm r0, rIdx, 2, 0x38 # offset: {12,14}<<2
  lwzux r0, rArr, r0
  rlwnm rAns, r0, rC4, 0x7 # ep
  rlwimi rAns, r0, 4, 0x0F00 # a0 => aEE
  lwz r0, 4(rArr)
  rlwnm rAnsEp, r0, rC4, 0x7
  b .L.loadStage

handlePlaza:
## [0, 1, 5, 7; 8, 9, 2, (*)]
## 15789200
## ans == 0x0100 | (magic << (arr:=CIdx<<2) &0xF)
  .set PlazaEpMagic, 0x15789200
  lis r0, PlazaEpMagic@h
  ori r0, r0, PlazaEpMagic@l
  rlwnm rAns, r0, rC4, 0xF
  ori rAns, rAns, 0x0100
  li rAnsEp, 0

.L.loadStage:
### backup to 817F0000 (for Y)
  sth rAns, $LevelSelect.area@l(r817F)
  stb rAnsEp, $LevelSelect.epFlag@l(r817F)

/* rAns, rAnsEp, rFM, rApp, r817F */
.L.loadStageWithoutBackup:
## reset QFT
  li  r0, 1
  stb r0, 0xB3(r817F)
### set SGT Reset Stopwatch Flag
# stb r0, 0x100(r817F)
### set SGT Disable Custom IG Timer Flag = 1
# stb r0, 0x101(r817F)
### en flag
  stb r0, $LevelSelect.en@l(r817F)
## FlagManager
### epFlag(40003)
  stb rAnsEp, 0xDF(rFM)
### reset coin counter(40002)
  li  r0, 0
  stw r0, 0xD8(rFM)
##### set SGT Stop Stopwatch Flag = 0
#  stw r0, 0x10C(r817F)
### set flag
  lhz r0, 0xCC(rFM)
#### Got a Shine in previous stage (30006)
  ori r0, r0, 0x4000
##### + watched AP, court, peach kidnap, FLUDD theft flag
# ori r0, r0, 0x40FF
#### clear watched Pinna kidnap FMV flag (prevent spawn in PP unlocked position)
  rlwinm r0, r0, 0, 0x14, 0x12
  sth r0, 0xCC(rFM)
## rApp = gpApplication
### write nextArea
  sth rAns, 0x12(rApp)

# SirenaHotel(0x07) or Casino(0x0E) ? 59 : 0
  rlwinm r0, rAns, 32-8, 0xFF # area
  lwz rArr, 0x20(rApp) # TMarioGamePad*
  li rC, 59
  cmpwi r0, 0x07 # SirenaHotel
  beq- .L.handleStickCD
  cmpwi r0, 0x0E # Casino
  beq- .L.handleStickCD
  li rC, 0
.L.handleStickCD:
  sth rC, 0xe4(rArr)
  blr

# disable TMarioGamePad::onNeutralMarioKey when LevelSelect is activated
.TMarioGamePad.onNeutralMarioKey:
  lis r12, $LevelSelect.en@ha
  lbz r0, $LevelSelect.en@l(r12)
  mr. r0, r0
  bnelr # return if LevelSelect is activated
  li r0, 60
  b 4+$b$.TMarioGamePad.onNeutralMarioKey

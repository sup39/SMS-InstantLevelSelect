$$ = 0x817f9800;

$LevelSelect.area = 0x817f0000;
$LevelSelect.epFlag = 0x817f0002;
$LevelSelect.en = 0x817f0004;
$AreaLock.en = 0x817f0005;

$b$.TMarioGamePad.onNeutralMarioKey = TMarioGamePad.onNeutralMarioKey;

$b$.Mar.changeState = 0x1C + TMarDirector.changeState;
.Mar.changeState.applied = 0x724 + TMarDirector.changeState;
$b$.Mar.moveStage = 0x40 + TMarDirector.moveStage;
$bl$.Mar.disable.PinnaFMV = 0x84 + TMarDirector.fireStreamingMovie;

$b$.gameLoop.preDirect = 0x20c + TApplication.gameLoop;
$b$.gameLoop.preReturn = 0x414 + TApplication.gameLoop;

$b$.Movie.direct = 0x43C + TMovieDirector.direct;
$b$.Movie.decideNextMode = 0x30 + TMovieDirector.decideNextMode;
.Movie.decideNextMode.applied = 0x198 + TMovieDirector.decideNextMode;

$b$.ShineSelect.direct = 0x174 + TSelectDir.direct;
.ShineSelect.direct.applied = 0x194 + TSelectDir.direct;

@ECHO OFF
TITLE "Packing Icons..."

FOR /F "tokens=1 delims= " %%i IN ('getPID') DO (
    set PID=%%i
)

"C:\Program Files\PowerToys\modules\Awake\PowerToys.Awake.exe" --pid %PID%

ECHO "Packing Size 128"

START /B /WAIT CMD /C ""E:\Program Files (x86)\ShoeBox\ShoeBox.exe" "plugin=shoebox.plugin.spriteSheet::PluginCreateSpriteSheet" "files=E:\Owner\Documents\SuperTryJam2023\raw\icon-sizes\128" "renderDebugLayer=false" "texPowerOfTwo=false" "fileName=icons-128.xml" "useCssOverHack=false" "texPadding=1" "animationNameIds=@name_####" "scale=1" "fileGenerate2xSize=false" "animationMaxFrames=1000" "animationFrameIdStart=0" "texMaxSize=2048" "texCropAlpha=true" "texExtrudeSize=0" "texSquare=false" fileFormatLoop="\t^<SubTexture name=\"@ID\"\tx=\"@x\"\ty=\"@y\"\twidth=\"@w\"\theight=\"@h\" frameX=\"-@fx\" frameY=\"-@fy\" frameWidth=\"@fw\" frameHeight=\"@fh\"/^>\n""

IF %ERRORLEVEL% GTR 0 EXIT /B 

START /B MOVE /Y "E:\Owner\Documents\SuperTryJam2023\raw\icon-sizes\128\icons-128.*" "E:\Owner\Documents\SuperTryJam2023\assets\images"

IF %ERRORLEVEL% GTR 0 EXIT /B %ERRORLEVEL%

ECHO "Packing Size 72"

START /B /WAIT CMD /C ""E:\Program Files (x86)\ShoeBox\ShoeBox.exe" "plugin=shoebox.plugin.spriteSheet::PluginCreateSpriteSheet" "files=E:\Owner\Documents\SuperTryJam2023\raw\icon-sizes\72" "renderDebugLayer=false" "texPowerOfTwo=false" "fileName=icons-72.xml" "useCssOverHack=false" "texPadding=1" "animationNameIds=@name_####" "scale=1" "fileGenerate2xSize=false" "animationMaxFrames=1000" "animationFrameIdStart=0" "texMaxSize=2048" "texCropAlpha=true" "texExtrudeSize=0" "texSquare=false" fileFormatLoop="\t^<SubTexture name=\"@ID\"\tx=\"@x\"\ty=\"@y\"\twidth=\"@w\"\theight=\"@h\" frameX=\"-@fx\" frameY=\"-@fy\" frameWidth=\"@fw\" frameHeight=\"@fh\"/^>\n""

IF %ERRORLEVEL% GTR 0 EXIT /B %ERRORLEVEL%


START /B MOVE /Y "E:\Owner\Documents\SuperTryJam2023\raw\icon-sizes\72\icons-72.*" "E:\Owner\Documents\SuperTryJam2023\assets\images"

IF %ERRORLEVEL% GTR 0 EXIT /B %ERRORLEVEL%

ECHO "Packing Size 64"

START /B /WAIT CMD /C ""E:\Program Files (x86)\ShoeBox\ShoeBox.exe" "plugin=shoebox.plugin.spriteSheet::PluginCreateSpriteSheet" "files=E:\Owner\Documents\SuperTryJam2023\raw\icon-sizes\64" "renderDebugLayer=false" "texPowerOfTwo=false" "fileName=icons-64.xml" "useCssOverHack=false" "texPadding=1" "animationNameIds=@name_####" "scale=1" "fileGenerate2xSize=false" "animationMaxFrames=1000" "animationFrameIdStart=0" "texMaxSize=2048" "texCropAlpha=true" "texExtrudeSize=0" "texSquare=false" fileFormatLoop="\t^<SubTexture name=\"@ID\"\tx=\"@x\"\ty=\"@y\"\twidth=\"@w\"\theight=\"@h\" frameX=\"-@fx\" frameY=\"-@fy\" frameWidth=\"@fw\" frameHeight=\"@fh\"/^>\n""

IF %ERRORLEVEL% GTR 0 EXIT /B %ERRORLEVEL%

START /B MOVE /Y "E:\Owner\Documents\SuperTryJam2023\raw\icon-sizes\64\icons-64.*" "E:\Owner\Documents\SuperTryJam2023\assets\images"

IF %ERRORLEVEL% GTR 0 EXIT /B %ERRORLEVEL%

ECHO "Packing Size 32"

START /B /WAIT CMD /C ""E:\Program Files (x86)\ShoeBox\ShoeBox.exe" "plugin=shoebox.plugin.spriteSheet::PluginCreateSpriteSheet" "files=E:\Owner\Documents\SuperTryJam2023\raw\icon-sizes\32" "renderDebugLayer=false" "texPowerOfTwo=false" "fileName=icons-32.xml" "useCssOverHack=false" "texPadding=1" "animationNameIds=@name_####" "scale=1" "fileGenerate2xSize=false" "animationMaxFrames=1000" "animationFrameIdStart=0" "texMaxSize=2048" "texCropAlpha=true" "texExtrudeSize=0" "texSquare=false" fileFormatLoop="\t^<SubTexture name=\"@ID\"\tx=\"@x\"\ty=\"@y\"\twidth=\"@w\"\theight=\"@h\" frameX=\"-@fx\" frameY=\"-@fy\" frameWidth=\"@fw\" frameHeight=\"@fh\"/^>\n""

IF %ERRORLEVEL% GTR 0 EXIT /B %ERRORLEVEL%


START /B MOVE /Y "E:\Owner\Documents\SuperTryJam2023\raw\icon-sizes\32\icons-32.*" "E:\Owner\Documents\SuperTryJam2023\assets\images"

IF %ERRORLEVEL% GTR 0 EXIT /B %ERRORLEVEL%

ECHO "Packing Glyphs 24"

START /B /WAIT CMD /C ""E:\Program Files (x86)\ShoeBox\ShoeBox.exe" "plugin=shoebox.plugin.spriteSheet::PluginCreateSpriteSheet" "files=E:\Owner\Documents\SuperTryJam2023\raw\glyphs\24" "renderDebugLayer=false" "texPowerOfTwo=false" "fileName=glyphs-24.xml" "useCssOverHack=false" "texPadding=1" "animationNameIds=@name_####" "scale=1" "fileGenerate2xSize=false" "animationMaxFrames=1000" "animationFrameIdStart=0" "texMaxSize=2048" "texCropAlpha=true" "texExtrudeSize=0" "texSquare=false" fileFormatLoop="\t^<SubTexture name=\"@ID\"\tx=\"@x\"\ty=\"@y\"\twidth=\"@w\"\theight=\"@h\" frameX=\"-@fx\" frameY=\"-@fy\" frameWidth=\"@fw\" frameHeight=\"@fh\"/^>\n""

IF %ERRORLEVEL% GTR 0 EXIT /B %ERRORLEVEL%


START /B MOVE /Y "E:\Owner\Documents\SuperTryJam2023\raw\glyphs\24\glyphs-24.*" "E:\Owner\Documents\SuperTryJam2023\assets\images"

IF %ERRORLEVEL% GTR 0 EXIT /B %ERRORLEVEL%

ECHO "Packing Glyphs 36"

START /B /WAIT CMD /C ""E:\Program Files (x86)\ShoeBox\ShoeBox.exe" "plugin=shoebox.plugin.spriteSheet::PluginCreateSpriteSheet" "files=E:\Owner\Documents\SuperTryJam2023\raw\glyphs\36" "renderDebugLayer=false" "texPowerOfTwo=false" "fileName=glyphs-36.xml" "useCssOverHack=false" "texPadding=1" "animationNameIds=@name_####" "scale=1" "fileGenerate2xSize=false" "animationMaxFrames=1000" "animationFrameIdStart=0" "texMaxSize=2048" "texCropAlpha=true" "texExtrudeSize=0" "texSquare=false" fileFormatLoop="\t^<SubTexture name=\"@ID\"\tx=\"@x\"\ty=\"@y\"\twidth=\"@w\"\theight=\"@h\" frameX=\"-@fx\" frameY=\"-@fy\" frameWidth=\"@fw\" frameHeight=\"@fh\"/^>\n""

IF %ERRORLEVEL% GTR 0 EXIT /B %ERRORLEVEL%

START /B MOVE /Y "E:\Owner\Documents\SuperTryJam2023\raw\glyphs\36\glyphs-36.*" "E:\Owner\Documents\SuperTryJam2023\assets\images"

IF %ERRORLEVEL% GTR 0 EXIT /B %ERRORLEVEL%

EXIT /B

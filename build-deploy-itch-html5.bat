@ECHO OFF
TITLE "Build & Deploy for Itch [HTML5]"

FOR /F "tokens=1 delims= " %%i IN ('getPID') DO (
    set PID=%%i
)

"C:\Program Files\PowerToys\modules\Awake\PowerToys.Awake.exe" --pid %PID%

ECHO "Building..."
lime build html5 -clean -final -nolaunch 
IF %ERRORLEVEL% == 0 GOTO DEPLOY
ECHO "Build failed, exiting..."
PAUSE
EXIT /B %ERRORLEVEL%

:DEPLOY
ECHO "Deploying to Itch..."
butler upgrade
butler push export/html5/bin axolstudio/spinilization:html5
IF %ERRORLEVEL% == 0 GOTO SUCCESS
ECHO "Deploy failed, exiting..."
PAUSE
EXIT /B %ERRORLEVEL%

:SUCCESS
ECHO "Success!"
PAUSE

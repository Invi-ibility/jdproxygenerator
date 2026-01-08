@ECHO OFF
SETLOCAL

REM --------------------------------------------------
REM  proxy.bat - Setup and run proxy-scrapper.py
REM  - Detects Python 3
REM  - If missing, creates virtual environment (venv)
REM  - Installs dependencies once 
REM  - Creates a marker file '.deps_installed' the first time dependencies are installed
REM  - Runs proxy-scrapper.py
REM --------------------------------------------------

SET "CURRENT_DIR=%~dp0"
SET "VENV_DIR=%CURRENT_DIR%env"
SET "MARKER_FILE=%CURRENT_DIR%.deps_installed"
SET "SCRIPT_NAME=proxy-scrapper.py"

CD /D "%CURRENT_DIR%"

ECHO.
ECHO === proxy.bat - starting in "%CURRENT_DIR%" ===
ECHO.

REM 1) Find Python
FOR %%P IN (py python) DO (
    WHERE %%P >NUL 2>&1 && (
        SET "PYLAUNCHER=%%P"
        ECHO Python detected: %PYLAUNCHER%
        GOTO CREATE_VENV
    )
)

CALL :FAIL "Python 3 was not found in PATH. Please install Python 3."
GOTO :EOF

:CREATE_VENV
REM 2) Create venv if missing
IF NOT EXIST "%VENV_DIR%\Scripts\activate.bat" (
    ECHO Creating virtual environment in "%VENV_DIR%"
    %PYLAUNCHER% -m venv "%VENV_DIR%"
    IF ERRORLEVEL 1 CALL :FAIL "Failed to create virtual environment."
) ELSE (
    ECHO Virtual environment already exists: "%VENV_DIR%"
)

REM 3) Activate venv
CALL "%VENV_DIR%\Scripts\activate.bat"

REM ---- Dependency installation (one-time) ----
SET "VENV_PY=%VENV_DIR%\Scripts\python.exe"

REM If marker file exists -> skip installs
IF NOT EXIST "%MARKER_FILE%" (
    IF NOT EXIST "%CURRENT_DIR%requirements.txt" (
        CALL :FAIL "requirements.txt not found."
    )

    REM If no marker file but requirements.txt exists -> first run: backup + install
    ECHO Installing dependencies...
    "%VENV_PY%" -m pip install --upgrade pip
    "%VENV_PY%" -m pip install -r "%CURRENT_DIR%requirements.txt"
    IF ERRORLEVEL 1 CALL :FAIL "Dependency installation failed."

    ECHO Dependencies installed successfully.
    ECHO installed > "%MARKER_FILE%"
) ELSE (
    ECHO Dependencies already installed. Skipping.
)

REM 5) Run proxy-scrapper.py
IF NOT EXIST "%CURRENT_DIR%%SCRIPT_NAME%" (
    CALL :FAIL "%SCRIPT_NAME% not found."
)
ECHO Running proxy-scrapper.py
"%VENV_PY%" "%CURRENT_DIR%%SCRIPT_NAME%"
IF ERRORLEVEL 1 (
    ECHO WARNING: proxy-scrapper.py finished with errors.
) ELSE (
    ECHO proxy-scrapper.py executed successfully.
)

REM ---- Check expected output ----
IF EXIST "%CURRENT_DIR%proxylist.jdproxies" (
    ECHO Proxy list generated: proxylist.jdproxies
) ELSE (
    ECHO WARNING: proxylist.jdproxies was not generated.
)

ECHO.
ECHO === proxy.bat - finished ===
PAUSE
ENDLOCAL
EXIT /B 0

REM ---- Error handler ----
:FAIL
ECHO.
ECHO ERROR: %~1
ECHO.
PAUSE
ENDLOCAL
EXIT /B 1
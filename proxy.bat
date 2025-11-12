@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

REM --------------------------------------------------
REM  proxy.bat - Setup and run proxy-scrapper.py
REM  - Creates venv if needed
REM  - On first run: uses requirements.txt -> ren to .bak -> install
REM  - If requirements.txt.bak exists: SKIPS installs
REM --------------------------------------------------

SET "CURRENT_DIR=%~dp0"
CD /D "%CURRENT_DIR%"

ECHO.
ECHO === proxy.bat - starting in "%CURRENT_DIR%" ===
ECHO.

REM 1) Find Python
SET "PYLAUNCHER="
WHERE py >NUL 2>&1
IF %ERRORLEVEL%==0 (
    SET "PYLAUNCHER=py -3"
) ELSE (
    WHERE python >NUL 2>&1
    IF %ERRORLEVEL%==0 (
        SET "PYLAUNCHER=python"
    ) ELSE (
        ECHO ERROR: Python not found in PATH. Please install Python 3 and try again.
        PAUSE
        EXIT /B 1
    )
)

REM 2) Create venv if missing
IF NOT EXIST "%CURRENT_DIR%env\Scripts\activate.bat" (
    ECHO Creating virtual environment in "%CURRENT_DIR%env"...
    %PYLAUNCHER% -m venv "%CURRENT_DIR%env"
    IF %ERRORLEVEL% NEQ 0 (
        ECHO Failed to create virtual environment.
        PAUSE
        EXIT /B 1
    )
) ELSE (
    ECHO Virtual environment already exists: "%CURRENT_DIR%env"
)

REM 3) Activate venv
CALL "%CURRENT_DIR%env\Scripts\activate.bat"

REM 4) Dependency logic (NO nested IFs)

REM If backup exists -> skip installs
IF EXIST "%CURRENT_DIR%requirements.txt.bak" GOTO SKIP_DEPS

REM If no backup but requirements.txt exists -> first run: backup + install
IF EXIST "%CURRENT_DIR%requirements.txt" GOTO INSTALL_ONCE

REM No requirements at all -> skip
GOTO AFTER_DEPS

:INSTALL_ONCE
ECHO First run: backing up requirements.txt to requirements.txt.bak...
REN "%CURRENT_DIR%requirements.txt" "requirements.txt.bak"
IF %ERRORLEVEL% NEQ 0 (
    ECHO WARNING: Failed to backup requirements.txt. Skipping dependency installation.
    GOTO AFTER_DEPS
)

ECHO Installing dependencies from requirements.txt.bak (one-time)...
"%CURRENT_DIR%env\Scripts\python.exe" -m pip install --upgrade pip
"%CURRENT_DIR%env\Scripts\python.exe" -m pip install -r "%CURRENT_DIR%requirements.txt.bak"
IF %ERRORLEVEL% NEQ 0 (
    ECHO WARNING: Some dependencies may not have installed correctly.
) ELSE (
    ECHO Dependencies installed successfully.
)
GOTO AFTER_DEPS

:SKIP_DEPS
ECHO requirements.txt.bak found -> skipping dependency installation.
GOTO AFTER_DEPS

:AFTER_DEPS

REM 5) Run proxy-scrapper.py
IF EXIST "%CURRENT_DIR%proxy-scrapper.py" (
    ECHO Running proxy-scrapper.py...
    "%CURRENT_DIR%env\Scripts\python.exe" "%CURRENT_DIR%proxy-scrapper.py"
    IF %ERRORLEVEL% NEQ 0 (
        ECHO proxy-scrapper.py finished with errors.
    ) ELSE (
        ECHO proxy-scrapper.py executed successfully.
    )
) ELSE (
    ECHO ERROR: proxy-scrapper.py not found in "%CURRENT_DIR%".
)

ECHO.
ECHO === proxy.bat - finished ===
PAUSE
ENDLOCAL
EXIT /B 0
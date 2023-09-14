@echo off
setlocal enabledelayedexpansion

:: Define the path to the local user's Python installation directory
set "user_python_dir=%LOCALAPPDATA%\Programs\Python\Python311"
mkdir "%user_python_dir%" 2>nul
:: Check if Python is installed in the user's local directory
if exist "%user_python_dir%" (
    for /f "delims=" %%p in ('where /r "%user_python_dir%" python.exe') do (
        set "python_path=%%p"
        set "python_installed=true"
        goto :PythonInstalled
    )
)

:PythonInstalled
if defined python_installed (
    echo Python is already installed on your system.
    echo Installed Python version:
    cd %LOCALAPPDATA%\Programs\Python\Python311
    python --version
    echo Installed Python path: !python_path!
) else (
    echo Python is not found in the user's local directory.
    :: Check for internet connectivity
    ping google.com -n 1 >nul
    if errorlevel 1 (
        echo You don't have an internet connection! Shame.
    ) else (
        echo You have an internet connection.
        set /p install_choice=Do you want to install python?(Y/N)
        if /i "!install_choice!"=="Y" (
            :: Download the latest Python installer
            echo Downloading Python !latest_version!...
            bitsadmin /transfer "PythonInstaller" https://www.python.org/ftp/python/!latest_version!/python-!latest_version!-amd64.exe "%TEMP%\python-installer.exe"
            :: Install Python silently
            echo Installing Python !latest_version!...
            "%TEMP%\python-installer.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
            if errorlevel 1 (
                echo Installation failed.
            ) else (
                echo Python !latest_version! has been installed successfully.
            )
        ) else (
            echo Python installation was skipped.
        )
    )
    pause
    :: Add an extra second of loading
    timeout /t 1 > nul
    :: Close the loading window
    Echo Python step successfully passed...
    echo installing modules required
    goto :pip_install
)

:pip_install
rem Set the user's Python directory
set "user_python_dir=%LOCALAPPDATA%\Programs\Python"
rem Find the Python executable path
for /f "delims=" %%p in ('where /r "%user_python_dir%" python.exe') do (
    set "python_path=%%p"
)

rem Download and install pip
cd "%user_python_dir%\Python311\Scripts"
curl -o get-pip.py https://bootstrap.pypa.io/get-pip.py
"%python_path%" "get-pip.py" %*
rem Install pandas using pip
pip install pandas
pip install tabulate
pip install shutil
pip install numpy
pip install Matplotlib

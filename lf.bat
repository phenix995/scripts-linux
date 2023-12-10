@echo off
setlocal enabledelayedexpansion

set "DIRECTORY=C:\path\to\your\directory"

for %%F in ("%DIRECTORY%\*") do (
    sed -i 's/\r$//' "%%F"
)

echo Conversion to LF completed.
pause

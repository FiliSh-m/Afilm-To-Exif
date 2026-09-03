@echo off
setlocal enabledelayedexpansion

rem ============================================================
rem  AfilmToExif - writes Afilm frame settings into scanned images
rem
rem  Place this .bat file in a folder containing:
rem    - the Afilm JSON export (any .json file in this folder)
rem    - the scanned images, one per frame, in frame order
rem      (alphabetical filename order == frame order: 01.jpg, 02.jpg, ...)
rem
rem  Requires in PATH:
rem    - exiftool  https://exiftool.org
rem    - jq        https://jqlang.github.io/jq/download/
rem  Keep "Afilm Frames.jq" in the same folder as this .bat.
rem ============================================================

rem ---- Find the Afilm JSON export: any .json in this folder ----
set "JSON="
set "JSONCOUNT=0"
for %%f in (*.json) do (
    set /a JSONCOUNT+=1
    if not defined JSON set "JSON=%%f"
)
if not defined JSON (
    echo No JSON file found in this folder!
    exit /b 1
)
if %JSONCOUNT% GTR 1 echo Note: %JSONCOUNT% JSON files found - using %JSON% (first alphabetically).

rem ---- Which image extensions to process ----
set "EXTS=*.jpg *.jpeg *.tif *.tiff *.png"

rem ---- Collect image files, ordered alphabetically ----
set "N=0"
for %%f in (%EXTS%) do (
    set /a N+=1
    set "IM_!N!=%%f"
)
if %N%==0 (
    echo No image files found!
    exit /b 1
)

rem ---- Check required tools ----
where exiftool >nul 2>&1 || (echo exiftool not found in PATH. Install from https://exiftool.org & exit /b 1)
where jq >nul 2>&1 || (echo jq not found in PATH. Install from https://jqlang.github.io/jq/download/ & exit /b 1)
if not exist "%~dp0Afilm Frames.jq" (echo Missing "Afilm Frames.jq" next to this .bat & exit /b 1)
if not exist "%JSON%" (echo JSON file "%JSON%" not found & exit /b 1)

set "ARGFILE=%TEMP%\afilm_frame_args.txt"

echo Writing metadata from %JSON% to %N% image(s)...
echo.

rem ---- For each image in order, write the matching frame's data ----
for /l %%i in (1,1,%N%) do (
    set "IMG=!IM_%%i!"

    jq -r -f "%~dp0Afilm Frames.jq" --argjson n "%%i" "%JSON%" > "!ARGFILE!"

    set "EMPTY=1"
    for %%z in ("!ARGFILE!") do if not %%~zz EQU 0 set "EMPTY=0"

    if "!EMPTY!"=="1" (
        echo Frame %%i -^> !IMG! : no data in JSON, skipping
    ) else (
        echo Frame %%i -^> !IMG!
        exiftool -overwrite_original -m -@ "!ARGFILE!" "!IMG!"
        if errorlevel 1 echo   warning: exiftool returned an error for !IMG!
    )
    del /q "!ARGFILE!" >nul 2>&1
)

echo.
echo Done. Processed %N% image(s).
endlocal

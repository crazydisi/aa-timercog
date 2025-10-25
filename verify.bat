@echo off
REM Timer Cog - Verification Script for Windows (Batch)
REM Run this to verify everything is set up correctly

setlocal enabledelayedexpansion
set "ALL_PASS=1"

echo ========================================================
echo    Timer Cog - Project Verification Script
echo ========================================================
echo.

REM Check Python version
echo ========================================================
echo 1. Checking Python version...
python --version 2>nul
if %errorlevel% equ 0 (
    echo [PASS] Python is installed
) else (
    echo [FAIL] Python not found
    set "ALL_PASS=0"
)
echo.

REM Check if in virtual environment
echo ========================================================
echo 2. Checking virtual environment...
if defined VIRTUAL_ENV (
    echo [OK] Virtual environment active: %VIRTUAL_ENV%
) else (
    echo [WARNING] No virtual environment detected
    echo    Recommendation: Create and activate venv
)
echo.

REM Check if package is installed
echo ========================================================
echo 3. Checking if package is installed...
python -c "import timercog; print(f'Timer Cog version: {timercog.__version__}')" 2>nul
if %errorlevel% equ 0 (
    echo [PASS] Package import
) else (
    echo [FAIL] Package import
    set "ALL_PASS=0"
)
echo.

REM Check dev dependencies
echo ========================================================
echo 4. Checking dev dependencies...

python -c "import black; print(f'Black: {black.__version__}')" 2>nul
if %errorlevel% equ 0 (
    echo [PASS] Black installed
) else (
    echo [FAIL] Black installed
    set "ALL_PASS=0"
)

python -c "import flake8; print(f'Flake8: {flake8.__version__}')" 2>nul
if %errorlevel% equ 0 (
    echo [PASS] Flake8 installed
) else (
    echo [FAIL] Flake8 installed
    set "ALL_PASS=0"
)

python -c "import isort; print(f'Isort: {isort.__version__}')" 2>nul
if %errorlevel% equ 0 (
    echo [PASS] Isort installed
) else (
    echo [FAIL] Isort installed
    set "ALL_PASS=0"
)

python -c "import pytest; print(f'Pytest: {pytest.__version__}')" 2>nul
if %errorlevel% equ 0 (
    echo [PASS] Pytest installed
) else (
    echo [FAIL] Pytest installed
    set "ALL_PASS=0"
)
echo.

REM Check code formatting
echo ========================================================
echo 5. Checking code formatting with Black...
black --check timercog\ 2>nul
if %errorlevel% equ 0 (
    echo [PASS] Black formatting
) else (
    echo [FAIL] Black formatting
    set "ALL_PASS=0"
)
echo.

REM Check import sorting
echo ========================================================
echo 6. Checking import sorting with isort...
isort --check-only timercog\ 2>nul
if %errorlevel% equ 0 (
    echo [PASS] Isort import sorting
) else (
    echo [FAIL] Isort import sorting
    set "ALL_PASS=0"
)
echo.

REM Check flake8
echo ========================================================
echo 7. Running flake8 linting...
flake8 timercog\ --count --select=E9,F63,F7,F82 --show-source 2>nul
if %errorlevel% equ 0 (
    echo [PASS] Flake8 critical errors check
) else (
    echo [FAIL] Flake8 critical errors check
    set "ALL_PASS=0"
)
echo.

REM Run tests
echo ========================================================
echo 8. Running pytest...
pytest -v
if %errorlevel% equ 0 (
    echo [PASS] Pytest tests
) else (
    echo [FAIL] Pytest tests
    set "ALL_PASS=0"
)
echo.

REM Check project structure
echo ========================================================
echo 9. Checking project structure...

if exist "pyproject.toml" (
    echo [PASS] pyproject.toml exists
) else (
    echo [FAIL] pyproject.toml missing
    set "ALL_PASS=0"
)

if exist ".flake8" (
    echo [PASS] .flake8 exists
) else (
    echo [FAIL] .flake8 missing
    set "ALL_PASS=0"
)

if exist ".gitignore" (
    echo [PASS] .gitignore exists
) else (
    echo [FAIL] .gitignore missing
    set "ALL_PASS=0"
)

if exist "tests\" (
    echo [PASS] tests\ directory exists
) else (
    echo [FAIL] tests\ directory missing
    set "ALL_PASS=0"
)

if exist "tests\test_basic.py" (
    echo [PASS] tests\test_basic.py exists
) else (
    echo [FAIL] tests\test_basic.py missing
    set "ALL_PASS=0"
)
echo.

REM Try building the package
echo ========================================================
echo 10. Testing package build...
if exist "dist\" rmdir /s /q dist 2>nul
if exist "build\" rmdir /s /q build 2>nul
for /d %%i in (*.egg-info) do rmdir /s /q "%%i" 2>nul

python -m build
if %errorlevel% equ 0 (
    echo [PASS] Package build
) else (
    echo [FAIL] Package build
    set "ALL_PASS=0"
)
echo.

REM Check built package
if exist "dist\" (
    echo ========================================================
    echo 11. Validating built package...
    twine check dist\*
    if %errorlevel% equ 0 (
        echo [PASS] Twine package validation
    ) else (
        echo [FAIL] Twine package validation
        set "ALL_PASS=0"
    )
    echo.
)

REM Final summary
echo ========================================================
if "%ALL_PASS%"=="1" (
    echo [SUCCESS] ALL CHECKS PASSED!
    echo Your project is ready for deployment!
    echo.
    echo Next steps:
    echo   1. Review any placeholder values (author, email, URLs^)
    echo   2. Push to GitHub and verify CI/CD passes
    echo   3. Set up PyPI trusted publishing
    echo   4. Create a release to publish
    echo.
    exit /b 0
) else (
    echo [FAILURE] SOME CHECKS FAILED
    echo Please review the errors above
    echo.
    echo To fix issues:
    echo   - Run: pip install -e .[dev]
    echo   - Format: black timercog\ ^&^& isort timercog\
    echo   - Test: pytest
    echo   - See: FIXES.md for troubleshooting
    echo.
    exit /b 1
)

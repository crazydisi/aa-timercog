#!/bin/bash
# Timer Cog - Verification Script
# Run this to verify everything is set up correctly

set -e  # Exit on error

echo "╔════════════════════════════════════════════════╗"
echo "║   Timer Cog - Project Verification Script     ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track status
ALL_PASS=true

check_step() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}: $1"
    else
        echo -e "${RED}✗ FAIL${NC}: $1"
        ALL_PASS=false
    fi
}

# Check Python version
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Checking Python version..."
python --version | grep -E "Python 3\.(10|11|12)"
check_step "Python version 3.10+"

# Check if in virtual environment
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. Checking virtual environment..."
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo -e "${GREEN}✓${NC} Virtual environment active: $VIRTUAL_ENV"
else
    echo -e "${YELLOW}⚠${NC} No virtual environment detected"
    echo "   Recommendation: Create and activate venv"
fi

# Check if package is installed
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. Checking if package is installed..."
python -c "import timercog; print(f'Timer Cog version: {timercog.__version__}')" 2>/dev/null
check_step "Package import"

# Check dev dependencies
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4. Checking dev dependencies..."
python -c "import black; print(f'Black: {black.__version__}')" 2>/dev/null
check_step "Black installed"
python -c "import flake8; print(f'Flake8: {flake8.__version__}')" 2>/dev/null
check_step "Flake8 installed"
python -c "import isort; print(f'Isort: {isort.__version__}')" 2>/dev/null
check_step "Isort installed"
python -c "import pytest; print(f'Pytest: {pytest.__version__}')" 2>/dev/null
check_step "Pytest installed"

# Check code formatting
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5. Checking code formatting with Black..."
black --check timercog/ 2>&1 | head -n 5
check_step "Black formatting"

# Check import sorting
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6. Checking import sorting with isort..."
isort --check-only timercog/ 2>&1 | head -n 5
check_step "Isort import sorting"

# Check flake8
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "7. Running flake8 linting..."
flake8 timercog/ --count --select=E9,F63,F7,F82 --show-source 2>&1
check_step "Flake8 critical errors check"

# Check line lengths
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "8. Checking line lengths..."
MAX_LENGTH=$(find timercog -name "*.py" -exec wc -L {} \; | sort -rn | head -1 | awk '{print $1}')
if [ "$MAX_LENGTH" -le 100 ]; then
    echo -e "${GREEN}✓${NC} Max line length: $MAX_LENGTH (limit: 100)"
else
    echo -e "${RED}✗${NC} Max line length: $MAX_LENGTH (limit: 100)"
    ALL_PASS=false
fi

# Run tests
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "9. Running pytest..."
pytest -v 2>&1 | tail -n 20
check_step "Pytest tests"

# Check if tests directory exists
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "10. Checking project structure..."
[ -f "pyproject.toml" ] && echo -e "${GREEN}✓${NC} pyproject.toml exists" || echo -e "${RED}✗${NC} pyproject.toml missing"
[ -f ".flake8" ] && echo -e "${GREEN}✓${NC} .flake8 exists" || echo -e "${RED}✗${NC} .flake8 missing"
[ -f ".gitignore" ] && echo -e "${GREEN}✓${NC} .gitignore exists" || echo -e "${RED}✗${NC} .gitignore missing"
[ -d "tests" ] && echo -e "${GREEN}✓${NC} tests/ directory exists" || echo -e "${RED}✗${NC} tests/ directory missing"
[ -f "tests/test_basic.py" ] && echo -e "${GREEN}✓${NC} tests/test_basic.py exists" || echo -e "${RED}✗${NC} tests/test_basic.py missing"

# Try building the package
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "11. Testing package build..."
rm -rf dist/ build/ *.egg-info 2>/dev/null
python -m build 2>&1 | tail -n 5
check_step "Package build"

# Check built package
if [ -d "dist" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "12. Validating built package..."
    twine check dist/* 2>&1
    check_step "Twine package validation"
fi

# Final summary
echo ""
echo "╔════════════════════════════════════════════════╗"
if [ "$ALL_PASS" = true ]; then
    echo -e "║  ${GREEN}✓ ALL CHECKS PASSED!${NC}                          ║"
    echo "║  Your project is ready for deployment!        ║"
else
    echo -e "║  ${RED}✗ SOME CHECKS FAILED${NC}                          ║"
    echo "║  Please review the errors above               ║"
fi
echo "╚════════════════════════════════════════════════╝"
echo ""

if [ "$ALL_PASS" = true ]; then
    echo "Next steps:"
    echo "  1. Review any placeholder values (author, email, URLs)"
    echo "  2. Push to GitHub and verify CI/CD passes"
    echo "  3. Set up PyPI trusted publishing"
    echo "  4. Create a release to publish"
    echo ""
    exit 0
else
    echo "To fix issues:"
    echo "  • Run: pip install -e .[dev]"
    echo "  • Format: black timercog/ && isort timercog/"
    echo "  • Test: pytest"
    echo "  • See: FIXES.md for troubleshooting"
    echo ""
    exit 1
fi
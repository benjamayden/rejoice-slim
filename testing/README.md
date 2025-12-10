← **[Back to Testing Guide](../docs/TESTING.md)** | **[Main README](../README.md)**

# Testing Infrastructure

**For Contributors and Developers**

Test suite infrastructure details. For user-facing testing guide, see [docs/TESTING.md](../docs/TESTING.md).

## Quick Start

```bash
# Run all tests (from project root)
./testing/test_suite.sh

# Run only settings tests
python3 testing/test_settings.py
```

## Test Scripts

### `test_suite.sh`
Main test runner that validates:
- Configuration & setup (4 tests)
- CLI commands (6 tests)
- File management (3 tests)
- AI features (1 test)
- Module integrity (2 tests)
- New features (3 tests)
- Recovery system (2 tests)

**Pass Rate**: 85% (18/21 tests)

### `test_settings.py`
Comprehensive settings validation (17 tests):
- .env file operations
- All 7 submenu functions
- Configuration validation (20 settings)
- Boolean, numeric, path, URL validation
- Streaming settings logic
- Module structure verification

**Pass Rate**: 100% (17/17 tests)

## Test Logs

All test results are saved to `logs/` directory with timestamp:
```
logs/test_results_20251209_112458.txt
```

These are automatically git-ignored to keep the repository clean.

## Running Tests

### From Project Root
```bash
./testing/test_suite.sh
python3 testing/test_settings.py
```

### From Testing Directory
```bash
cd testing
./test_suite.sh
python3 test_settings.py
cd ..
```

## Documentation

For complete testing documentation, see:
- [docs/TESTING.md](../docs/TESTING.md) - User testing guide

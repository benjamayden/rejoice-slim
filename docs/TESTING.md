← **[Back to Documentation](/README.md)**

# Testing Guide

Validate your Rejoice installation and features with automated tests.

## Quick Start

Run all tests:

```bash
./testing/test_suite.sh
```

## What Gets Tested

✅ Configuration & dependencies  
✅ All CLI commands  
✅ File management  
✅ Module imports  
✅ New features (stall detection, auto-stop)  
✅ Recovery system  
✅ Settings validation

## Manual Tests to Run

```bash
# 1. Test silence auto-stop (NEW FEATURE)
rec
# [Stay silent for 2+ minutes]
# Should auto-stop at 120 seconds

# 2. Test stall detection (NEW FEATURE)
rec
# [Disconnect mic after starting]
# Should stop after 5 seconds

# 3. Full workflow test
rec           # Record
rec -l        # List
rec -v 1      # View
rec -g 1      # AI analyze
rec -1        # Append
```

## Check Results

- Console output shows pass/fail for each test
- Detailed logs saved to `testing/logs/test_results_YYYYMMDD_HHMMSS.txt`

**For test infrastructure details, see [testing/README.md](../testing/README.md)**

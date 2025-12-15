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
# 1. Test silent segment auto-stop (NEW FEATURE)
rec
# [Stay silent for ~2-3 minutes]
# Should auto-stop after 3 consecutive silent segments
# Detection is based on volume analysis, not transcription
# Each segment is 30-60s, so ~90-180s total

# 2. Test auto-stop resets on speech
rec
# [Speak for 10s]
# [Stay silent for 1 minute]
# [Speak again for 10s]  ← This resets the counter
# [Stay silent for 3 minutes]
# Should auto-stop after the 3 minutes of final silence

# 3. Test stall detection (NEW FEATURE)
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

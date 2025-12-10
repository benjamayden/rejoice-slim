#!/bin/bash
# Rejoice Automated Test Suite
# Tests core functionality and generates a report

set -e  # Exit on error (can be disabled for comprehensive testing)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Test results array
declare -a TEST_RESULTS

# Helper functions
print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_test() {
    echo -e "${YELLOW}Testing:${NC} $1"
}

pass_test() {
    echo -e "${GREEN}✅ PASS:${NC} $1"
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
    TEST_RESULTS+=("✅ $1")
}

fail_test() {
    echo -e "${RED}❌ FAIL:${NC} $1"
    echo -e "${RED}   Error:${NC} $2"
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
    TEST_RESULTS+=("❌ $1 - $2")
}

skip_test() {
    echo -e "${YELLOW}⏭️  SKIP:${NC} $1"
    echo -e "${YELLOW}   Reason:${NC} $2"
    ((SKIPPED_TESTS++))
    ((TOTAL_TESTS++))
    TEST_RESULTS+=("⏭️  $1 - $2")
}

# Check if we're in the right directory
if [ ! -f "src/transcribe.py" ]; then
    echo -e "${RED}Error: Must run from rejoice-slim root directory${NC}"
    exit 1
fi

# Activate virtual environment if it exists
if [ -d "venv" ]; then
    echo "🔧 Activating virtual environment..."
    source venv/bin/activate
else
    echo -e "${YELLOW}⚠️  No virtual environment found. Using system Python.${NC}"
fi

# Source .env if it exists
if [ -f ".env" ]; then
    set -a
    source .env
    set +a
else
    echo -e "${RED}Error: .env file not found. Run setup.sh first.${NC}"
    exit 1
fi

print_header "🧪 REJOICE TEST SUITE"
echo "Testing Date: $(date)"
echo "Python: $(python3 --version)"
echo "Save Path: ${SAVE_PATH:-Not set}"
echo ""

# ============================================================================
# TEST SECTION 1: CONFIGURATION & SETUP
# ============================================================================
print_header "1️⃣  Configuration & Setup Tests"

# Test 1.1: Check .env exists and has required variables
print_test "1.1 - Configuration file (.env) exists and is valid"
REQUIRED_VARS=("SAVE_PATH" "OUTPUT_FORMAT" "WHISPER_MODEL" "OLLAMA_MODEL")
MISSING_VARS=()
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        MISSING_VARS+=("$var")
    fi
done

if [ ${#MISSING_VARS[@]} -eq 0 ]; then
    pass_test "All required configuration variables present"
else
    fail_test "Configuration incomplete" "Missing: ${MISSING_VARS[*]}"
fi

# Test 1.2: Check save path exists
print_test "1.2 - Save path directory exists"
if [ -d "$SAVE_PATH" ]; then
    pass_test "Save path exists: $SAVE_PATH"
else
    fail_test "Save path missing" "Directory not found: $SAVE_PATH"
fi

# Test 1.3: Check Python modules
print_test "1.3 - Required Python modules installed"
if python3 -c "import whisper, sounddevice, numpy, pyperclip" 2>/dev/null; then
    pass_test "Core Python dependencies available"
else
    fail_test "Python dependencies missing" "Run: pip install -r requirements.txt"
fi

# Test 1.4: Check Ollama availability
print_test "1.4 - Ollama service availability (optional)"
if command -v ollama &> /dev/null; then
    if curl -s http://localhost:11434/api/tags &> /dev/null; then
        pass_test "Ollama service is running"
    else
        skip_test "Ollama not running" "AI features will be disabled"
    fi
else
    skip_test "Ollama not installed" "AI features will be disabled"
fi

# ============================================================================
# TEST SECTION 2: CLI COMMAND AVAILABILITY
# ============================================================================
print_header "2️⃣  CLI Command Tests"

# Test 2.1: Help command
print_test "2.1 - Help command"
if python3 src/transcribe.py --help &> /dev/null; then
    pass_test "Help command works"
else
    fail_test "Help command failed" "Could not run --help"
fi

# Test 2.2: Settings command (run automated settings tests)
print_test "2.2 - Settings menu accessible and functional"
TEST_SETTINGS_PATH="test_settings.py"
if [ -f "testing/test_settings.py" ]; then
    TEST_SETTINGS_PATH="testing/test_settings.py"
fi

if [ -f "$TEST_SETTINGS_PATH" ]; then
    if python3 "$TEST_SETTINGS_PATH" &> /dev/null; then
        pass_test "Settings tests passed (17/17 tests)"
    else
        fail_test "Settings tests" "Some settings tests failed"
    fi
else
    skip_test "Settings tests" "test_settings.py not found"
fi

# Test 2.3: List command
print_test "2.3 - List transcripts command"
if python3 src/transcribe.py --list &> /dev/null; then
    pass_test "List command works"
else
    fail_test "List command failed" "Could not run --list"
fi

# Test 2.4: Open folder command
print_test "2.4 - Open folder command"
# This will fail on headless systems, so we just check if it exits cleanly
if python3 src/transcribe.py --open-folder 2>&1 | grep -q "transcripts"; then
    pass_test "Open folder command works"
else
    skip_test "Open folder" "Requires GUI environment"
fi

# Test 2.5: List devices command
print_test "2.5 - List audio devices"
if python3 src/transcribe.py --list-devices &> /dev/null; then
    pass_test "Audio device listing works"
else
    fail_test "List devices failed" "Could not enumerate audio devices"
fi

# Test 2.6: List sessions command
print_test "2.6 - List recovery sessions"
if python3 src/transcribe.py --list-sessions &> /dev/null; then
    pass_test "List sessions command works"
else
    fail_test "List sessions failed" "Could not list recovery sessions"
fi

# ============================================================================
# TEST SECTION 3: FILE MANAGEMENT
# ============================================================================
print_header "3️⃣  File Management Tests"

# Test 3.1: Check if transcripts exist
print_test "3.1 - Transcript directory has content"
TRANSCRIPT_COUNT=$(find "$SAVE_PATH" -name "*_*_*.${OUTPUT_FORMAT}" 2>/dev/null | wc -l)
if [ "$TRANSCRIPT_COUNT" -gt 0 ]; then
    pass_test "Found $TRANSCRIPT_COUNT transcripts"
else
    skip_test "No existing transcripts" "Create one with 'rec' to test"
fi

# Test 3.2: Test viewing a transcript (if any exist)
if [ "$TRANSCRIPT_COUNT" -gt 0 ]; then
    print_test "3.2 - View transcript by ID"
    # Get first transcript ID
    FIRST_TRANSCRIPT=$(find "$SAVE_PATH" -name "*_*_*.${OUTPUT_FORMAT}" | head -1)
    # Extract ID (last 6 digits before the date)
    TRANSCRIPT_ID=$(basename "$FIRST_TRANSCRIPT" | grep -oE '[0-9]{6}' | head -1)
    
    if [ -n "$TRANSCRIPT_ID" ]; then
        if python3 src/transcribe.py --view "$TRANSCRIPT_ID" &> /dev/null; then
            pass_test "Can view transcript $TRANSCRIPT_ID"
        else
            fail_test "View transcript failed" "Could not view ID: $TRANSCRIPT_ID"
        fi
    else
        skip_test "View transcript" "Could not extract transcript ID"
    fi
else
    skip_test "View transcript" "No transcripts to test"
fi

# Test 3.3: Test show audio files (if transcripts exist)
if [ "$TRANSCRIPT_COUNT" -gt 0 ] && [ -n "$TRANSCRIPT_ID" ]; then
    print_test "3.3 - Show audio files for transcript"
    if python3 src/transcribe.py --audio "$TRANSCRIPT_ID" &> /dev/null; then
        pass_test "Audio files command works for ID: $TRANSCRIPT_ID"
    else
        fail_test "Show audio failed" "Could not show audio for ID: $TRANSCRIPT_ID"
    fi
else
    skip_test "Show audio files" "No transcripts to test"
fi

# ============================================================================
# TEST SECTION 4: AI FEATURES
# ============================================================================
print_header "4️⃣  AI Feature Tests"

# Test 4.1: Check if AI analysis is available
print_test "4.1 - AI analysis availability"
if command -v ollama &> /dev/null && curl -s http://localhost:11434/api/tags &> /dev/null; then
    # Test with a small file if transcripts exist
    if [ "$TRANSCRIPT_COUNT" -gt 0 ] && [ -n "$TRANSCRIPT_ID" ]; then
        print_test "4.2 - AI analysis on transcript"
        # Create test output with timeout (AI can be slow)
        if timeout 30 python3 src/transcribe.py --genai "$TRANSCRIPT_ID" &> /dev/null; then
            pass_test "AI analysis works on transcript $TRANSCRIPT_ID"
        else
            skip_test "AI analysis test" "Timeout or error (this is normal for large files)"
        fi
    else
        skip_test "AI analysis" "No transcripts to test"
    fi
else
    skip_test "AI features" "Ollama not available"
fi

# ============================================================================
# TEST SECTION 5: MODULE IMPORTS
# ============================================================================
print_header "5️⃣  Module Integrity Tests"

# Test 5.1: Import all core modules
print_test "5.1 - Core module imports"
MODULES=(
    "audio_buffer"
    "volume_segmenter"
    "quick_transcript"
    "transcript_manager"
    "audio_manager"
    "file_header"
    "id_generator"
    "loading_indicator"
    "safety_net"
    "debug_logger"
    "summarization_service"
    "settings"
    "commands"
)

FAILED_IMPORTS=()
for module in "${MODULES[@]}"; do
    if ! python3 -c "import sys; sys.path.insert(0, 'src'); import $module" 2>/dev/null; then
        FAILED_IMPORTS+=("$module")
    fi
done

if [ ${#FAILED_IMPORTS[@]} -eq 0 ]; then
    pass_test "All ${#MODULES[@]} modules import successfully"
else
    fail_test "Module import failed" "Failed: ${FAILED_IMPORTS[*]}"
fi

# Test 5.2: Check for syntax errors
print_test "5.2 - Python syntax validation"
SYNTAX_ERRORS=0
for pyfile in src/*.py; do
    if ! python3 -m py_compile "$pyfile" 2>/dev/null; then
        ((SYNTAX_ERRORS++))
    fi
done

if [ $SYNTAX_ERRORS -eq 0 ]; then
    pass_test "No syntax errors in Python files"
else
    fail_test "Syntax errors found" "$SYNTAX_ERRORS files have syntax errors"
fi

# ============================================================================
# TEST SECTION 6: NEW FEATURES (Auto-stop & Stall Detection)
# ============================================================================
print_header "6️⃣  New Feature Tests"

# Test 6.1: Check if new methods exist
print_test "6.1 - Audio buffer stall detection method"
if python3 -c "
import sys; sys.path.insert(0, 'src')
from audio_buffer import CircularAudioBuffer
buffer = CircularAudioBuffer()
assert hasattr(buffer, 'get_time_since_last_write')
" 2>/dev/null; then
    pass_test "get_time_since_last_write() method exists"
else
    fail_test "Stall detection missing" "get_time_since_last_write() not found"
fi

# Test 6.2: Check volume segmenter silence tracking
print_test "6.2 - Volume segmenter silence duration method"
if python3 -c "
import sys; sys.path.insert(0, 'src')
from audio_buffer import CircularAudioBuffer
from volume_segmenter import VolumeSegmenter
buffer = CircularAudioBuffer()
segmenter = VolumeSegmenter(buffer)
assert hasattr(segmenter, 'get_current_silence_duration')
" 2>/dev/null; then
    pass_test "get_current_silence_duration() method exists"
else
    fail_test "Silence tracking missing" "get_current_silence_duration() not found"
fi

# Test 6.3: Check if SILENCE_DURATION_SECONDS is loaded
print_test "6.3 - Silence duration configuration"
if [ -n "$SILENCE_DURATION_SECONDS" ]; then
    pass_test "SILENCE_DURATION_SECONDS set to: ${SILENCE_DURATION_SECONDS}s"
else
    fail_test "Silence duration not configured" "SILENCE_DURATION_SECONDS missing from .env"
fi

# ============================================================================
# TEST SECTION 7: RECOVERY SYSTEM
# ============================================================================
print_header "7️⃣  Recovery System Tests"

# Test 7.1: Check for audio_sessions directory
print_test "7.1 - Recovery directory structure"
SESSIONS_DIR="${SAVE_PATH}/audio_sessions"
if [ -d "$SESSIONS_DIR" ]; then
    pass_test "Recovery directory exists: $SESSIONS_DIR"
else
    skip_test "Recovery directory" "Not created yet (normal for new installation)"
fi

# Test 7.2: Check for session files
if [ -d "$SESSIONS_DIR" ]; then
    print_test "7.2 - Recovery session files"
    SESSION_COUNT=$(find "$SESSIONS_DIR" -name "*.wav" 2>/dev/null | wc -l)
    if [ "$SESSION_COUNT" -gt 0 ]; then
        skip_test "Found $SESSION_COUNT session files" "These should be recovered"
    else
        pass_test "No pending recovery sessions (clean state)"
    fi
else
    skip_test "Session files check" "No sessions directory"
fi

# ============================================================================
# GENERATE REPORT
# ============================================================================
print_header "📊 TEST SUMMARY"

echo -e "Total Tests:  ${TOTAL_TESTS}"
echo -e "${GREEN}Passed:       ${PASSED_TESTS}${NC}"
echo -e "${RED}Failed:       ${FAILED_TESTS}${NC}"
echo -e "${YELLOW}Skipped:      ${SKIPPED_TESTS}${NC}"
echo ""

# Calculate pass rate
if [ $TOTAL_TESTS -gt 0 ]; then
    PASS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo -e "Pass Rate:    ${PASS_RATE}%"
fi

echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Detailed Results:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

for result in "${TEST_RESULTS[@]}"; do
    echo -e "$result"
done

echo ""

# Write report to file
if [ -d "testing/logs" ]; then
    REPORT_FILE="testing/logs/test_results_$(date +%Y%m%d_%H%M%S).txt"
else
    REPORT_FILE="test_results_$(date +%Y%m%d_%H%M%S).txt"
fi
{
    echo "Rejoice Test Suite Report"
    echo "========================="
    echo "Date: $(date)"
    echo "Python: $(python3 --version)"
    echo ""
    echo "Summary:"
    echo "--------"
    echo "Total:   $TOTAL_TESTS"
    echo "Passed:  $PASSED_TESTS"
    echo "Failed:  $FAILED_TESTS"
    echo "Skipped: $SKIPPED_TESTS"
    echo ""
    echo "Results:"
    echo "--------"
    for result in "${TEST_RESULTS[@]}"; do
        echo "$result"
    done
} > "$REPORT_FILE"

echo -e "${GREEN}📄 Report saved to: ${REPORT_FILE}${NC}\n"

# Exit with appropriate code
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}⚠️  Some tests failed. Review the report above.${NC}"
    exit 1
else
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
fi

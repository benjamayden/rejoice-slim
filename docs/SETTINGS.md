# ⚙️ Settings Guide

**← [Back to Home](/README.md)**

## 🎛️ Configuration Menu

Access settings anytime with:
```bash
rec -s
```

This opens an interactive menu to configure all aspects of Rejoice.

### Settings Menu Structure

Navigate with `rec -s`, then choose:

```
Main Menu:
1. Recording Settings
   1. Change save path
   2. Auto-stop threshold (default: 3 segments)
   3. Min chars for content (default: 10 chars)
   4. Auto-cleanup audio files
   
2. Transcription Settings
   1. Change Whisper model
   2. Change language
   
3. Output Settings
   1. Change output format (md/txt)
   2. Auto-copy to clipboard
   3. Auto-open file
   
4. AI Settings (requires Ollama)
   1. Change Ollama model
   2. Auto-generate metadata
   3. AI timeout settings
   
5. Audio Settings
   1. Select microphone device
   
6. Command Settings
   1. Change command name
   
7. View Current Settings
8. Reset to Defaults
9. Exit
```

## 📋 Basic Settings

### 🎤 Recording Command
- **What it is:** The command you type to start recording
- **Default:** `rec`
- **Examples:** `record`, `transcribe`, `voice`, `tr`
- **Why change it:** Avoid conflicts with other commands
- **How to change:** `rec -s` → Command → Change Command Name

### 📁 Save Path
- **What it is:** Where your transcript files are saved
- **Default:** `~/Documents/transcripts`
- **Pro tip:** Set to your Obsidian vault for seamless integration
- **Examples:** `~/MyVault/Voice Notes`, `~/Desktop/Transcripts`

### 📝 Output Format
- **Options:** `md` (Markdown) or `txt` (plain text)
- **Default:** `md` - **Recommended for Obsidian users**
- **Markdown benefits:** YAML frontmatter, tags, better organization
- **Plain text:** Simple format, works everywhere

## 🤖 AI Models

### Whisper Model Selection
Control transcription accuracy and speed:

| Model  | Size | Speed    | Accuracy | Best For |
|--------|------|----------|----------|----------|
| `tiny` | 39MB | Fastest  | Good     | Quick notes, testing |
| `base` | 74MB | Fast     | Better   | General use, older computers |
| `small`| 244MB| Balanced | Very Good| **Recommended default** |
| `medium`| 769MB| Slower  | Excellent| Professional use |
| `large`| 1550MB| Slowest | Best     | Critical accuracy needs |

**Recommendation:** Start with `small`, upgrade to `medium` if you need better accuracy.

### Ollama Model Selection (Optional)
Controls AI-generated filenames and metadata:

| Model      | Size | Speed | Quality | Best For |
|------------|------|-------|---------|----------|
| `gemma3:4b`| 2.5GB| Fast  | Excellent| **Recommended default** |
| `llama3`   | 4.7GB| Medium| Excellent| Alternative to Gemma |
| `qwen3:0.6b`| 350MB| Fastest| Good   | Limited RAM/storage |
| `phi3`     | 2.3GB| Fast  | Very Good| Alternative option |

**Without Ollama:** Files get timestamp names like `transcript_2024-10-20_14-30.md`

## 🌍 Language Settings

### Language Detection
- **Default:** `auto` (automatic detection)
- **Manual options:** `en` (English), `es` (Spanish), `fr` (French), `de` (German), etc.
- **When to use manual:** Consistent accuracy for single-language environments
- **When to use auto:** Multi-language conversations or unsure

### Supported Languages
Whisper supports 99+ languages including:
- **Common:** English, Spanish, French, German, Italian, Portuguese, Russian, Chinese, Japanese, Korean
- **Full list:** Available in the configuration menu

## 🎯 Auto Actions

### Auto Copy to Clipboard
- **Default:** Enabled
- **What it does:** Copies transcript text after saving
- **Useful for:** Quickly pasting into other apps
- **Disable if:** Working with sensitive content

### Auto Open File
- **Default:** Disabled  
- **What it does:** Opens saved file in default editor after transcription
- **Useful for:** Immediate review and editing
- **Enable if:** You always edit transcripts after recording

### Auto Metadata Generation
- **Default:** Enabled (if Ollama installed)
- **What it does:** AI generates filename, summary, and tags
- **Disable if:** Want manual control over metadata
- **Requirements:** Ollama must be installed and running

## 🧠 AI Analysis Settings

### Content Length Limits
- **Setting:** `OLLAMA_MAX_CONTENT_LENGTH`
- **Default:** 15,000 characters
- **What it does:** Maximum content size for AI processing
- **Large content:** Uses hierarchical chunking for files over 3,000 chars
- **Adjust if:** Getting timeouts or want to process larger files

### AI Analysis Features
- **Command:** `rec -g 000042` (AI analysis of transcripts)
- **Extracts:** Main themes, key questions, action items, narrative threads
- **Processing:** Hierarchical summarization for large content (30k+ characters)
- **Output:** Intelligent filename, comprehensive summary, relevant tags

### AI Timeout Settings  
- **Default:** 180 seconds (3 minutes)
- **What it does:** How long to wait for AI responses
- **Increase if:** Large files are timing out
- **Decrease if:** Want faster failures on problematic content

## ⚡ Performance Settings

### Auto-Stop Detection
Controls when recording automatically stops due to inactivity:

#### Empty Segment Threshold
- **Setting:** `EMPTY_SEGMENT_THRESHOLD`
- **Default:** 3 segments
- **What it does:** Auto-stops after this many consecutive empty transcription segments
- **How it works:** Checks if the last 3 segments combined have meaningful content after each segment is transcribed
- **Example:** If segments 5, 6, and 7 combined have < 10 characters, recording stops
- **Change via:** `rec -s` → `1` (Recording Settings) → `2` (Auto-stop threshold)

#### Minimum Characters for Content
- **Setting:** `EMPTY_SEGMENT_MIN_CHARS`
- **Default:** 10 characters
- **What it does:** Minimum characters in last N segments combined to consider "has content"
- **Example:** "Hello" (5 chars) across 3 segments = empty, "Hello world" (11 chars) = has content
- **Change via:** `rec -s` → `1` (Recording Settings) → `3` (Minimum chars for content)

### Streaming Transcription Settings
Controls how audio is segmented during recording:

#### Buffer Size
- **Setting:** `STREAMING_BUFFER_SIZE_SECONDS`
- **Default:** 300 seconds (5 minutes)
- **What it does:** Keeps last 5 minutes of audio in memory for processing
- **Why:** Allows transcribing recent audio without loading entire recording
- **Change via:** Edit `.env` file directly (advanced users)

#### Segment Duration Limits
These control when audio segments are created and transcribed:

- **Min Duration:** `STREAMING_MIN_SEGMENT_DURATION=30` (30 seconds)
  - Won't create segments shorter than 30s (prevents tiny fragments)
  - **Change via:** Edit `.env` file
  
- **Target Duration:** `STREAMING_TARGET_SEGMENT_DURATION=60` (60 seconds)
  - Tries to create segments around 60s when natural pauses occur
  - **Change via:** Edit `.env` file
  
- **Max Duration:** `STREAMING_MAX_SEGMENT_DURATION=90` (90 seconds)
  - Forces segment creation at 90s even if you're still talking
  - Prevents segments from getting too large for processing
  - **Change via:** Edit `.env` file

**How segmentation works:**
1. Recording captures audio continuously
2. When you pause speaking (volume drops), creates a segment
3. If no pause happens for 90s, forces segment creation anyway
4. Each segment gets transcribed in background
5. After segment transcription, checks if last 3 segments combined have content
6. If last 3 segments have < 10 chars combined, auto-stops recording

> **Note:** Segment duration limits are advanced settings. The defaults work well for most use cases.

## 🎤 Audio Settings

### Microphone Selection
```bash
python src/transcribe.py --list-devices
```
Shows available audio input devices:
```
Available audio devices:
  0: Built-in Microphone (default)
  1: USB Headset Microphone  
  2: Blue Yeti USB Microphone
```

Set preferred device in configuration or use:
```bash
python src/transcribe.py --device 2  # Use Blue Yeti
```

### Audio Quality Settings
- **Sample Rate:** 16kHz (optimized for Whisper)
- **Channels:** Mono (speech recognition works best with single channel)
- **Bit Depth:** 16-bit (sufficient for voice)

> **Note:** These are optimized automatically. Manual adjustment usually not needed.

## 📄 Output Customization

### Markdown Format (Default)
```markdown
---
date: 2024-10-20 14:30
duration: 00:02:45
tags: [meeting-notes, project-planning, brainstorming]
summary: Discussion about new feature roadmap and timeline priorities
ai_model: gemma3:4b
whisper_model: small
---

# Project Planning Meeting - October 20th

[Transcription content here...]
```

### Plain Text Format
```
Date: 2024-10-20 14:30
Duration: 00:02:45
Tags: meeting-notes, project-planning, brainstorming
Summary: Discussion about new feature roadmap and timeline priorities

Project Planning Meeting - October 20th

[Transcription content here...]
```

### Custom Templates
Edit `templates.json` to customize output format:
```json
{
  "markdown": {
    "header": "---\ndate: {date}\nduration: {duration}\ntags: {tags}\nsummary: {summary}\n---\n\n# {title}\n\n",
    "content": "{transcript}"
  },
  "text": {
    "header": "Date: {date}\nDuration: {duration}\nTags: {tags}\nSummary: {summary}\n\n{title}\n\n",
    "content": "{transcript}"
  }
}
```

## 🔧 Command Settings

### Change Your Command Name
You can change the command from `rec` to anything you prefer:

```bash
rec -s                    # Open settings
# Choose: 6. Command → 1. Change Command Name
# Enter new name: record, transcribe, voice, etc.
```

**Examples:**
- `record` - More descriptive
- `transcribe` - Clear purpose  
- `voice` - Short and memorable
- `tr` - Very short
- `notes` - For note-taking workflow

**What happens:**
- Updates your `~/.zshrc` file automatically
- Creates backup of old `.zshrc` 
- Old command stops working immediately
- New command works after `source ~/.zshrc`

**Safety features:**
- Won't overwrite existing commands
- Creates backup before changes
- Shows current command name
- Validates new command name

## 🔧 Environment Variables

Advanced users can set environment variables in `.env`:

```bash
# Whisper Settings
WHISPER_MODEL=small
WHISPER_LANGUAGE=auto

# Ollama Settings  
OLLAMA_MODEL=gemma3:4b
OLLAMA_TIMEOUT=30

# Output Settings
OUTPUT_FORMAT=md
OUTPUT_PATH=~/Documents/transcripts

# Auto Actions
AUTO_COPY=true
AUTO_OPEN=false
AUTO_METADATA=true

# Performance
CHUNK_DURATION=10
NO_SPEECH_TIMEOUT=120
WORKERS=2
```

## 🔄 Resetting Configuration

### Reset to Defaults
```bash
python src/transcribe.py --reset-config
```

### Reconfigure Everything
```bash
python src/transcribe.py --config
```

### Backup Settings
Your settings are stored in `.env`. Back it up:
```bash
cp .env .env.backup
```

## 🛠️ Troubleshooting Settings

### "Settings not saving"
- Check file permissions in the project directory
- Ensure `.env` file is writable
- Try running `rec -s` as your user (not sudo)

### "Command not found after changing alias"
- Restart terminal: `source ~/.zshrc`
- Or use full path: `python /path/to/rejoice/src/transcribe.py`
- Or run uninstall: `rec -s` → Uninstall → Run Uninstall

### "AI features stopped working"
- Check Ollama: `ollama list`
- Test connection: `curl http://localhost:11434/api/version`
- Try different model: `ollama pull gemma3:4b`

### "Audio device not found"
- List devices: `python src/transcribe.py --list-devices`
- Check system audio preferences
- Try default device: Don't specify device number

---

**← [Back to Home](README.md)** | **Next: [Dependencies Guide →](DEPENDENCIES.md)**
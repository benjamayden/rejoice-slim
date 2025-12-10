# Rejoice - Local Voice Transcriber 🎙️

**Turn your voice into searchable notes - completely offline and private.**

Rejoice is a voice-to-text tool that runs entirely on your computer. Perfect for **Obsidian users** who want to capture thoughts, meetings, and ideas as voice notes that automatically become searchable Markdown files in their vault.

## ✨ What It Does

- 🎤 **One-command recording** - Start transcribing with `rec`
- 🆔 **Smart ID system** - Easy-to-reference transcripts with descriptive names
- ➕ **Append to transcripts** - Add to existing recordings with `rec -{id}`
- 🤖 **AI-powered analysis** - Hierarchical summarization extracts key themes, questions, and actions
- 📝 **Obsidian-ready** - Markdown format with YAML frontmatter
- 🔄 **Real-time transcription** - See your words appear as you speak
- 🎯 **Smart auto-stop** - Automatically stops when no speech detected
- ⚡ **Short commands** - Use `-l`, `-v`, `-g`, `-s` for quick access
- 🏠 **100% local** - Your voice data never leaves your computer

## � Privacy First

- ✅ **All processing on your device** - Whisper + Ollama run locally
- ✅ **No cloud services** - Zero external API calls
- ✅ **Completely offline** - No internet required after setup
- ✅ **You control the data** - Files saved where you choose

## 🎯 Perfect For

- � **Meeting notes** and voice journaling
- � **Quick idea capture** and brainstorming  
- 📚 **Lecture transcription** and interviews
- 📖 **Obsidian workflow** integration

## 🚀 Quick Start

### Installation
```bash
curl -fsSL https://raw.githubusercontent.com/benjamayden/rejoice-slim/main/setup.sh | bash
```

### Basic Usage  
```bash
rec           # Start recording
rec -l        # List all transcripts
rec -v 000001 # View by ID
```

**See [docs/USAGE.md](docs/USAGE.md) for all commands and AI features**

---

## 📚 Documentation

- **[🔧 Installation Guide](docs/INSTALLATION.md)** - Detailed setup options and troubleshooting
- **[📖 How to Use](docs/USAGE.md)** - Complete user guide with examples  
- **[⚙️ Settings](docs/SETTINGS.md)** - Configuration options and customization
- **[📦 Dependencies](docs/DEPENDENCIES.md)** - Package details and security information
- **[🏗️ Architecture](docs/ARCHITECTURE.md)** - System design and developer guide
- **[🧪 Testing](docs/TESTING.md)** - Automated test suite and validation

---

**Questions?** Check the [documentation](docs/README.md) or create an issue on GitHub.
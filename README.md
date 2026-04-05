# Suvadu — Binary Releases

**Suvadu** is a cross-agent memory service for AI tools. Install it once, and every AI tool you use — Claude, Cursor, Windsurf, and any MCP-compatible client — shares the same long-term memory. Your preferences, decisions, project context — remembered across tools and conversations.

- **Local-first**: all data stays on your machine
- **Works with any MCP-compatible AI tool**
- **Free tier**: 50 memories (plenty to try it)
- **Pro**: one-time purchase, yours forever

Website: [suvadu.aisforapp.com](https://suvadu.aisforapp.com)

---

## Install

### macOS (Apple Silicon) / Linux

```bash
curl -fsSL https://suvadu.aisforapp.com/install.sh | bash
```

### Windows (PowerShell)

```powershell
irm https://suvadu.aisforapp.com/install.ps1 | iex
```

### What the installer does

1. Downloads the latest binary for your platform
2. Extracts to `~/.local/lib/suvadu/`
3. Creates a symlink at `~/.local/bin/suvadu`
4. Auto-detects and configures your AI clients (Claude Desktop, Claude Code, Cursor)
5. You're ready — open your AI client and start talking

### Update

Run the same install command again. It downloads the latest version and overwrites the existing install. Your memories and settings are preserved.

---

## Supported Platforms

| Platform | Architecture | Status |
|----------|-------------|--------|
| macOS | arm64 (Apple Silicon) | Supported |
| Linux | x86_64 | Supported |
| Windows | x86_64 | Supported |

---

## Issues & Feedback

Found a bug? Have a feature request?

- **Bug reports**: [Open an issue](https://github.com/aisforapp/suvadu-releases/issues/new?template=bug_report.md)
- **Feature requests**: [Start a discussion](https://github.com/aisforapp/suvadu-releases/discussions/new?category=feature-requests)
- **General questions**: [Discussions](https://github.com/aisforapp/suvadu-releases/discussions)

You can also report bugs directly from your AI conversation:
> "Report a suvadu bug — recall is returning irrelevant results"

Your AI agent will collect diagnostics and help you file the report.

---

## Privacy

Suvadu is local-first. Your memories never leave your machine.

- All data stored at `~/.suvadu/` on your machine
- No cloud sync, no hosted service
- One anonymous startup ping per session (version, platform, tier) for product analytics
- No memory content, queries, or personal data ever transmitted
- [Full privacy policy](https://suvadu.aisforapp.com/privacy)

---

## About This Repository

This is the **public releases repository** for Suvadu. It contains:

- Binary releases for all supported platforms
- Install scripts (`install.sh`, `install.ps1`)
- Issue tracker for bug reports
- Discussions for feature requests and community

The source code is in a separate private repository.

---

Made by [A is for App](https://aisforapp.com)

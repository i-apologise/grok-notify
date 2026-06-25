# grok-notify

**Hear when [Grok](https://x.ai/cli) finishes a response.**

A tiny install script that adds global hooks for sound + an optional macOS notification. No extra apps, no hand-edited config — one command and you're done.

| | |
|---|---|
| **Best on** | macOS (`afplay` + Notification Center) |
| **Also works on** | Linux (best-effort: `paplay` or terminal bell) |
| **Installs to** | `~/.grok/hooks/` (global — all projects) |
| **License** | MIT |

---

## Quick start

**Requires:** [Grok CLI](https://x.ai/cli) installed (`grok` works in your terminal).

```bash
git clone https://github.com/i-apologise/grok-notify.git
cd grok-notify
chmod +x install.sh
./install.sh --test
```

`--test` installs hooks **and** plays three sample sounds so you know it works.

Then:

1. **Restart Grok** (quit fully, or open a new session).
2. Press **Ctrl+L** → **Hooks** → confirm **`notify-on-stop`** is listed.
3. Send any prompt — when the agent **stops**, you should hear a sound (and optionally see a banner).

<details>
<summary><strong>Other install options</strong></summary>

**One-liner (temp dir)**

```bash
git clone --depth 1 https://github.com/i-apologise/grok-notify.git /tmp/grok-notify \
  && chmod +x /tmp/grok-notify/install.sh \
  && /tmp/grok-notify/install.sh --test
```

**GitHub CLI**

```bash
gh repo clone i-apologise/grok-notify
cd grok-notify
./install.sh --test
```

**Install only (skip sound test)**

```bash
./install.sh
```

**Uninstall**

```bash
./install.sh --uninstall
```

</details>

---

## What you get

Hooks are copied into **`~/.grok/hooks/`** and apply to **every project**.

### Sounds by event

| Event | Sound | When |
|-------|-------|------|
| `Stop` | Glass | Agent finished a turn/response |
| `StopFailure` | Basso | Turn failed (API/error) |
| `SessionEnd` | Hero | You quit the Grok session |

### Files installed

| Path | Role |
|------|------|
| `~/.grok/hooks/notify-on-stop.json` | Registers which Grok events to hook |
| `~/.grok/hooks/scripts/notify-done.sh` | Plays sound / shows notification |

**Manual test anytime:**

```bash
~/.grok/hooks/scripts/notify-done.sh
```

---

## Customize (optional)

Export these in your shell profile (`~/.zshrc`, `~/.config/fish/config.fish`, etc.) **before** starting Grok.

| Variable | Default | What it does |
|----------|---------|--------------|
| `GROK_NOTIFY_SOUND` | `Glass` | macOS system sound name |
| `GROK_NOTIFY_BANNER` | `1` | `0` = sound only (no Notification Center banner) |
| `GROK_NOTIFY_SPEAK` | `0` | `1` = speak "Grok done" via `say` |

**Examples**

```bash
# zsh / bash
export GROK_NOTIFY_SOUND=Ping
export GROK_NOTIFY_BANNER=0
export GROK_NOTIFY_SPEAK=1
```

```fish
# fish
set -x GROK_NOTIFY_SOUND Ping
set -x GROK_NOTIFY_BANNER 0
set -x GROK_NOTIFY_SPEAK 1
```

Other macOS sounds worth trying: `Ping`, `Hero`, `Purr`, `Sosumi`, `Funk`, `Tink`, `Basso`.

---

## Platform notes

| Platform | Behavior |
|----------|----------|
| **macOS** | Full support — `afplay` + Notification Center (`osascript`) |
| **Linux** | Tries `paplay` (`complete.oga`), else terminal bell |
| **Docker-only Grok** | Hooks may run inside the container; **host speakers usually won't play** unless Grok runs on the Mac |

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Hook missing in Ctrl+L | Restart Grok after `./install.sh` |
| No sound | Check volume / Focus / Do Not Disturb; run `~/.grok/hooks/scripts/notify-done.sh` directly |
| `~/.grok` doesn't exist | Install Grok first: `curl -fsSL https://x.ai/cli/install.sh \| bash` |
| Too many sounds (every turn) | That's `Stop` firing per turn — edit installed `notify-on-stop.json` and remove the `Stop` block, or open an issue/PR |
| Uninstall didn't work | Confirm files are gone: `ls ~/.grok/hooks/notify-on-stop.json` |

---

## How it works

Grok supports [lifecycle hooks](https://x.ai/cli). This package registers passive hooks on `Stop` / `StopFailure` / `SessionEnd` that run a small shell script.

- No agent config changes
- No MCP server
- No background daemon

---

## Repo layout

```text
grok-notify/
├── install.sh                 # installer / --test / --uninstall
├── README.md
├── LICENSE
├── hooks/
│   └── notify-on-stop.json    # copied → ~/.grok/hooks/
└── scripts/
    └── notify-done.sh         # copied → ~/.grok/hooks/scripts/
```

---

## License

MIT — use and share freely.

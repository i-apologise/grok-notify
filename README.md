# grok-notify

**Hear when [Grok](https://x.ai/cli) finishes a response** — small install script that adds global hooks for sound + optional macOS notification.

No extra apps. No config files to hand-edit. One command.

---

## Install (30 seconds)

**Requires:** [Grok CLI](https://x.ai/cli) already installed (`grok` works in your terminal). Best experience on **macOS**.

### Option A — clone (recommended)

```bash
git clone https://github.com/i-apologise/grok-notify.git
cd grok-notify
chmod +x install.sh
./install.sh --test
```

`--test` installs hooks **and** plays three sample sounds so you know it works.

### Option B — one-liner (temp dir)

```bash
git clone --depth 1 https://github.com/i-apologise/grok-notify.git /tmp/grok-notify \
  && chmod +x /tmp/grok-notify/install.sh \
  && /tmp/grok-notify/install.sh --test
```

### Option C — GitHub CLI

```bash
gh repo clone i-apologise/grok-notify
cd grok-notify
./install.sh --test
```

Then:

1. **Restart Grok** (quit fully, or open a new session).
2. Press **Ctrl+L** → **Hooks** tab → confirm **`notify-on-stop`** is listed.
3. Send any prompt; when the agent **stops**, you should hear a sound (and optionally see a banner).

Install only (no sound test):

```bash
./install.sh
```

Uninstall:

```bash
./install.sh --uninstall
```

---

## What it does

Hooks are copied into **`~/.grok/hooks/`** (global — applies to **all projects**).

| Grok event | Default sound | When it fires |
|------------|---------------|---------------|
| `Stop` | Glass | Agent finished a turn/response |
| `StopFailure` | Basso | Turn ended with an API/error failure |
| `SessionEnd` | Hero | You quit the Grok session |

| File installed | Purpose |
|----------------|---------|
| `~/.grok/hooks/notify-on-stop.json` | Tells Grok which events to hook |
| `~/.grok/hooks/scripts/notify-done.sh` | Plays sound / shows notification |

Manual test after install:

```bash
~/.grok/hooks/scripts/notify-done.sh
```

---

## Customize (optional)

Set these in your shell profile (`~/.zshrc`, `~/.config/fish/config.fish`, etc.) **before** starting Grok:

| Variable | Default | Meaning |
|----------|---------|---------|
| `GROK_NOTIFY_SOUND` | `Glass` | macOS system sound name |
| `GROK_NOTIFY_BANNER` | `1` | `0` = sound only, no Notification Center banner |
| `GROK_NOTIFY_SPEAK` | `0` | `1` = speak “Grok done” (`say`) |

Examples:

```bash
# zsh / bash
export GROK_NOTIFY_SOUND=Ping
export GROK_NOTIFY_BANNER=0

# fish
set -x GROK_NOTIFY_SOUND Ping
set -x GROK_NOTIFY_BANNER 0
```

Other macOS sounds worth trying: `Ping`, `Hero`, `Purr`, `Sosumi`, `Funk`, `Tink`, `Basso`.

---

## Platform notes

| Platform | Behavior |
|----------|----------|
| **macOS** | `afplay` + Notification Center (`osascript`) — intended target |
| **Linux** | Tries `paplay` (complete.oga), else terminal bell |
| **Grok inside Docker only** | Hooks may run in the container; **host speakers usually won’t play** unless Grok runs on the Mac |

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| No hook in Ctrl+L | Restart Grok after `./install.sh` |
| No sound | Volume / Focus / Do Not Disturb; run `~/.grok/hooks/scripts/notify-done.sh` directly |
| `~/.grok` missing | Install Grok first: `curl -fsSL https://x.ai/cli/install.sh \| bash` |
| Sound every turn is noisy | That’s `Stop` (per turn). Only want quit? Edit installed `notify-on-stop.json` and remove the `Stop` block, or open an issue/PR |
| Uninstall didn’t help | Confirm files gone: `ls ~/.grok/hooks/notify-on-stop.json` |

---

## Repo layout

```text
grok-notify/
├── install.sh                 # installer / --test / --uninstall
├── README.md
├── LICENSE
├── hooks/
│   └── notify-on-stop.json    # → ~/.grok/hooks/
└── scripts/
    └── notify-done.sh         # → ~/.grok/hooks/scripts/
```

---

## How it works (short)

Grok supports [lifecycle hooks](https://x.ai/cli). This package registers passive hooks on `Stop` / `StopFailure` / `SessionEnd` that run a small shell script. No agent config changes, no MCP, no background daemon.

---

## License

MIT — use and share freely.

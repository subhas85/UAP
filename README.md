# UAP

> **UAP — out of this world.**
>
> A quiet, dark command center you log into from anywhere on your network. It's not a regular desktop. Instead of icons and pop-ups, you get a clean keyboard-driven workspace tuned for focus: terminal, browser, notes, file manager — and not much else. The whole thing is dark with a typewriter feel, so it stays out of the way while you work. You don't sit at this machine directly; you dial into it from your laptop or phone, do what you need to do, and step away.
>
> Under the hood it's Ubuntu — the same operating system that runs much of the production internet — so it can do everything a developer needs out of the box: code, containers, databases, automation, AI tooling. Microsoft Edge handles day-to-day work, Chrome handles AI browser automation, and the terminal stack is dialed in for real system work.
>
> What makes UAP different from a plain Ubuntu install is how it's set up to work *with AI*. The terminal is wired for Claude Code and other command-line coding agents, and projects follow a methodology where **the folder structure is the workflow itself**. Numbered stage folders (`01_intake/`, `02_clean/`, …) define the sequence; small markdown files at each level (`CLAUDE.md`, `CONTEXT.md`) tell the agent its current role — what to load, what to do, and where to write the result. One agent walks the filesystem and reads the right files at the right moment, instead of an orchestration framework juggling a fleet of specialized agents. Humans review the handoffs between stages. The OS treats AI as a real collaborator, not an afterthought.
>
> UAP is built to run as a virtual machine. One folder of configs and a runbook stand up an identical workstation for you, a teammate, or any new VM in minutes — a personal OS that's actually portable.

UAP is open source (MIT-licensed) and lives at `github.com/subhas85/uap`. Any operator can fork it, clone it, and stand up their own UAP machine; the framework is parameterized so your machine ends up with your name, your color palette, your project conventions, not the original author's. The pristine framework stays in the repo; everything that makes a specific deployment *yours* lives outside it at `~/uap.local/`. See `setup/DESIGN.md` for the template + identity + apply architecture.

This README is the runbook to recreate UAP from scratch on any hypervisor (Proxmox, ESXi, Hyper-V, libvirt) or on bare-metal hardware. Designed so an AI agent or operator can follow it linearly. Contributions, issues, and forks are welcome — see `CONTRIBUTING.md`.

## Quick Start

You have a fresh **Ubuntu Server 24.04 LTS** install (VM or bare metal) reachable over SSH or local console. UAP turns it into your AI-collaborator workstation.

**One-liner** (when the repo is published somewhere reachable):

```bash
curl -fsSL https://<your-host>/uap/bootstrap.sh | bash
```

**Or, with a manual clone first** (any time you've grabbed the repo from another machine via git/scp/USB):

```bash
git clone https://<your-host>/uap.git ~/uap     # or scp/rsync the folder to ~/uap
bash ~/uap/bootstrap.sh
```

What `bootstrap.sh` does:

1. Sanity-checks the OS, refuses root.
2. Installs minimal apt prereqs (`git`, `curl`, `ca-certificates`, `build-essential`).
3. Installs the Claude Code CLI (`curl https://claude.ai/install.sh | bash`).
4. Ensures the UAP repo is at `~/uap/` (clones from `REPO_URL` if not).
5. Launches `claude` in `~/uap/setup/` — at which point the **deployment wizard** takes over.

The wizard reads `setup/CLAUDE.md` (facilitator instructions) and walks you through `setup/QUESTIONNAIRE.md` conversationally. Every answer goes into `setup/answers.yaml`. When it's done, the wizard drives the rest of this runbook phase-by-phase, applying your customizations.

> **First-time deployers** — see `setup/references.md` for a plain-English intro to ICM (the folder-as-workflow methodology UAP uses) before answering Section 10 of the questionnaire.

Once the wizard finishes, RDP to the box from your laptop or phone over your tailnet and you should be on the UAP desktop.



## Minimum specs

| Tier | CPU | RAM | Disk | Real-world feel |
|---|---|---|---|---|
| Absolute min | 2 vCPU | 2 GB | 25 GB | Boots and RDP works; browsers swap heavily |
| Comfortable | 2 vCPU | 4 GB | 30 GB | Single browser, terminal, Typora — fine for sysadmin work |
| **Recommended** | 4 vCPU | 8 GB | 40 GB | Edge + Chrome both running, multiple terminals, Claude Code happy |
| Reference build | 4–8 vCPU | 16 GB | 60 GB+ | Headroom for AI tooling, containers, many tabs |

Browsers (especially Chrome with AI browser-automation extensions) are the dominant RAM consumer; if you'll use UAP as an AI-collaborator workstation, plan for 8 GB minimum.

## How AI-driven installs work

- **Hypervisor installs are fully AI-installable end-to-end.** The agent talks to the hypervisor API, creates the VM, attaches the Ubuntu ISO with an autoinstall (cloud-init) config, boots it, waits, then SSHes in and runs the rest of this runbook. Zero human keystrokes.
- **Bare-metal installs are AI-driven but human-assisted.** The agent builds an autoinstall USB image (or sets up PXE/netboot); a human plugs in the USB and powers the box on. The unattended install runs, the box phones home on first boot, and the agent takes over via SSH from there. (Enterprise gear with iDRAC/iLO/IPMI can skip the human step — the AI mounts the ISO over out-of-band, then proceeds as in the hypervisor flow.)

## What you get

- Ubuntu Server 24.04 LTS as the base
- xrdp + xorgxrdp for RDP access (Tailscale-friendly)
- i3 window manager (Tokyo Night theme, JetBrainsMono Nerd Font)
- Alacritty terminal, rofi launcher, flameshot screenshots, feh wallpaper, thunar file manager
- Browsers: Microsoft Edge, Google Chrome, Chromium (snap), Firefox (snap)
- Markdown editor: Typora (with Tokyo Night theme installed)
- Terminal tools: btop, bat, glow (markdown viewer)
- A small daemon that puts the active window title next to the workspace number on the i3 top bar
- System-wide dark mode (Adwaita-dark for GTK apps; Qt apps follow GTK)
- Custom Plymouth boot splash (UAP logo on Tokyo Night background — visible on hypervisor console / bare-metal display)

## Layout of this folder

```
configs/                        # Verbatim config files to deploy
  i3-config                     → ~/.config/i3/config
  i3status.conf                 → ~/.config/i3/i3status.conf
  alacritty.toml                → ~/.config/alacritty/alacritty.toml
  rofi-tokyo-night.rasi         → ~/.config/rofi/tokyo-night.rasi
  xinitrc                       → ~/.xinitrc (and symlink ~/.xsession → ~/.xinitrc)
  typora-themes/                → ~/.config/Typora/themes/  (Monospace Dark + Tokyo Night)
  gtk-3.0/settings.ini          → ~/.config/gtk-3.0/settings.ini  (Adwaita-dark)
  gtk-4.0/settings.ini          → ~/.config/gtk-4.0/settings.ini  (Adwaita-dark)
  plymouth/                     → /usr/share/plymouth/themes/uap/  (boot splash)
  xrdp-sesman.ini               → /etc/xrdp/sesman.ini  (Policy=UBD so reconnects reattach reliably)
  workspace/CLAUDE.md           → ~/workspace/CLAUDE.md  (UAP workspace hub router — ICM Layer 0)
  desktop-entries/              → ~/.local/share/applications/  (rofi/menu launchers, e.g. Claude workspace)
scripts/
  i3-workspace-title            → ~/.local/bin/i3-workspace-title
  reconnectwm.sh                → /etc/xrdp/reconnectwm.sh
setup/
  CLAUDE.md                     # facilitator instructions for the deployment wizard
  QUESTIONNAIRE.md              # source-of-truth list of questions to ask a new operator
  answers.example.yaml          # shape of the answers file produced by a wizard run
  references.md                 # links to ICM paper, upstream docs, known issues
bootstrap.sh                    # kickstart entry point — installs Claude, launches wizard
```

---

## Phase 1A — Hypervisor / VM (default path)

Create a VM on your hypervisor with at least:

- 4 vCPU, 8 GB RAM, 40 GB disk (see Minimum specs table above)
- One bridged or routed NIC
- Boot from `ubuntu-24.04.x-live-server-amd64.iso`

On Proxmox specifically: do NOT enable memory ballooning if you intend to set a fixed memory size — see Known Issues below.

## Phase 1B — Bare metal (alternative)

UAP is not VM-specific — nothing in the runbook depends on virtualization. To install on physical hardware:

- Burn `ubuntu-24.04.x-live-server-amd64.iso` to a USB stick (`dd`, Rufus, balenaEtcher).
- Boot the target machine, install Ubuntu Server normally, skip the snap server bundles.
- Make sure firmware for Wi-Fi / GPU / audio loads (server install usually handles this, but consumer hardware sometimes needs `apt install linux-firmware-extra` or vendor packages).
- For unattended AI-driven installs: build a custom autoinstall ISO (Ubuntu Server's `autoinstall.yaml` + `user-data`/`meta-data`), have the operator boot it once; the rest of this runbook resumes over SSH after first boot.

Skip Phase 1A entirely; the remaining phases are identical.

## Phase 2 — Install Ubuntu Server 24.04 LTS

Standard installation. When prompted:

- Profile: pick a username (this guide uses `<your-username>` as a placeholder — substitute your own)
- Install OpenSSH server: **yes**
- No featured server snaps (skip)

Reboot after install. Log in over SSH for the rest of the steps.

## Phase 3 — Network access (Tailscale)

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

Authenticate via the URL it prints. RDP from another Tailnet host will reach this VM by its Tailscale name.

## Phase 4 — Install all packages

```bash
sudo apt update && sudo apt full-upgrade -y

sudo apt install -y \
  xrdp xorgxrdp \
  i3 i3-wm i3status i3lock \
  alacritty rofi flameshot feh thunar \
  xdotool scrot \
  btop bat \
  vim \
  fonts-jetbrains-mono fonts-inconsolata \
  microsoft-edge-stable     # see note below if package not found

# Snap apps (browsers + glow markdown viewer)
sudo snap install chromium
sudo snap install firefox
sudo snap install glow
```

If `microsoft-edge-stable` is not in the default repos:

```bash
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
echo "deb [signed-by=/usr/share/keyrings/microsoft.gpg arch=amd64] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
sudo apt update && sudo apt install -y microsoft-edge-stable
```

### Google Chrome (used for AI browser automation)

```bash
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
echo "deb [signed-by=/usr/share/keyrings/google-chrome.gpg arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt update && sudo apt install -y google-chrome-stable
```

### Typora (markdown editor)

```bash
curl -fsSL https://typora.io/linux/public-key.asc | sudo gpg --dearmor -o /usr/share/keyrings/typora.gpg
echo "deb [signed-by=/usr/share/keyrings/typora.gpg] https://typora.io/linux ./" | sudo tee /etc/apt/sources.list.d/typora.list
sudo apt update && sudo apt install -y typora
```

`bat` is installed as `/usr/bin/batcat` on Ubuntu (binary name conflict). Optionally:

```bash
mkdir -p ~/.local/bin && ln -s /usr/bin/batcat ~/.local/bin/bat
```

## Phase 5 — JetBrainsMono Nerd Font

`fonts-jetbrains-mono` from apt provides the regular font, but the i3 / alacritty / rofi configs reference the **Nerd Font** patched variant. Install it:

```bash
mkdir -p ~/.local/share/fonts/JetBrainsMono
cd /tmp
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono/
fc-cache -fv
```

Verify: `fc-list | grep -i 'JetBrainsMono Nerd'` should print several entries.

## Phase 6 — Configure xrdp

Default xrdp puts you in a Xorg session. To make it launch i3 on connect:

1. Create the session glue (the X session executes `~/.xinitrc`, which `exec i3`s):
   ```bash
   cp configs/xinitrc ~/.xinitrc
   chmod +x ~/.xinitrc
   ln -sf ~/.xinitrc ~/.xsession
   ```
2. Install the reconnect hook (releases stuck modifier keys after RDP KeyboardSync — see notes):
   ```bash
   sudo cp scripts/reconnectwm.sh /etc/xrdp/reconnectwm.sh
   sudo chmod 755 /etc/xrdp/reconnectwm.sh
   sudo chown root:root /etc/xrdp/reconnectwm.sh
   ```
3. Enable and start xrdp:
   ```bash
   sudo systemctl enable --now xrdp
   ```
3b. Set sesman session policy so reconnects always reattach to the same session (regardless of client IP, resolution, or xrdp service restarts):
   ```bash
   sudo sed -i 's/^Policy=.*/Policy=UBD/' /etc/xrdp/sesman.ini
   sudo systemctl restart xrdp-sesman   # only safe before any user has logged in
   ```
   Alternatively, deploy the archived `configs/xrdp-sesman.ini` verbatim. `Policy=UBD` matches sessions by user+bpp+depth only — same user reconnecting from any client always reattaches.
4. Open the RDP port if a firewall is enabled:
   ```bash
   sudo ufw allow 3389/tcp || true
   ```
5. (Optional, security) Fix `/etc/xrdp/key.pem` permissions so xrdp can use TLS:
   ```bash
   sudo chmod 644 /etc/xrdp/key.pem
   ```
6. **If your RDP client uses a non-US English locale** (e.g. English-Canada `0x00001009`, English-UK `0x00000809`, English-Australia `0x00000c09`), xrdp won't have a matching keymap file and will fall back to US English imperfectly — some punctuation keys including `/` will be mis-translated. Drop in a copy of the US keymap under the matching locale name:
   ```bash
   # English-Canada (most common for North American users with Windows set to Canadian keyboard)
   sudo cp /etc/xrdp/km-00000409.ini /etc/xrdp/km-00001009.ini
   # English-UK
   sudo cp /etc/xrdp/km-00000409.ini /etc/xrdp/km-00000809.ini
   ```
   No xrdp restart needed; the next RDP connection picks up the new file. Diagnose via `sudo tail /var/log/xrdp.log` after a connect — look for `Cannot find keymap file /etc/xrdp/km-<LCID>.ini`.

## Phase 7 — Deploy i3 + app configs

```bash
# i3
mkdir -p ~/.config/i3
cp configs/i3-config        ~/.config/i3/config
cp configs/i3status.conf    ~/.config/i3/i3status.conf

# alacritty
mkdir -p ~/.config/alacritty
cp configs/alacritty.toml   ~/.config/alacritty/alacritty.toml

# rofi
mkdir -p ~/.config/rofi
cp configs/rofi-tokyo-night.rasi ~/.config/rofi/tokyo-night.rasi
```

Wallpaper: drop any 16:9 image at `~/.config/i3/background` (referenced by `feh --bg-fill` in `xinitrc`). If you don't, the line silently no-ops.

### Typora themes

Two installable themes are archived in `configs/typora-themes/`:

- **monospace** + **monospace-dark** — official Typora typewriter theme (uses Inconsolata for body text, PT Mono for code). The dark variant is the day-to-day default.
- **tokyo-night** + **tokyo-night+** — community Tokyo Night theme matching the rest of the desktop's color scheme (the `+` variant has richer syntax colors).

Install all of them at once:

```bash
mkdir -p ~/.config/Typora/themes
cp -r configs/typora-themes/* ~/.config/Typora/themes/
```

The monospace theme also needs **PT Mono** (PT Mono is not in apt — the apt-installed `fonts-inconsolata` covers Inconsolata):

```bash
mkdir -p ~/.local/share/fonts/PTMono
curl -fsSL "https://github.com/google/fonts/raw/main/ofl/ptmono/PTM55FT.ttf" \
  -o ~/.local/share/fonts/PTMono/PTM55FT.ttf
fc-cache -f
```

Then launch Typora once and select **Themes → Monospace Dark** (or **Tokyo Night** etc.). Typora stores the choice itself; no config edit needed.

For the typewriter feel, also enable **View → Typewriter Mode** (current line stays vertically centered as you type) and optionally **View → Focus Mode** (dims paragraphs other than the current one).

Sources: [typora/typora-monospace-theme](https://github.com/typora/typora-monospace-theme), [Aemiii91/typora-theme-tokyo-night](https://github.com/Aemiii91/typora-theme-tokyo-night).

## Phase 8 — Workspace-title daemon

The i3 config already references `~/.local/bin/i3-workspace-title`; this is what makes the focused window's title appear on the workspace button in the top bar.

```bash
mkdir -p ~/.local/bin
cp scripts/i3-workspace-title ~/.local/bin/i3-workspace-title
chmod +x ~/.local/bin/i3-workspace-title
```

It auto-starts via `exec_always --no-startup-id flock -n /tmp/i3-workspace-title.lock ~/.local/bin/i3-workspace-title` in the i3 config — `flock -n` makes it a singleton across i3 reloads.

## Phase 8.55 — Workspace hub (UAP standard)

UAP's standard for organizing user work is a single **workspace hub** at `~/workspace/` that holds symlinks to all real work folders, plus a top-level `CLAUDE.md` that acts as the ICM "Layer 0" routing the AI agent to the right subworkspace.

**Why a hub instead of `~/` directly:**
- `~/` contains `~/.ssh/`, `~/.config/`, browser profiles, `~/.claude.json`, etc. — none of which should be in an AI agent's casual scope, especially with `bypassPermissions` mode active.
- `~/workspace/` gives the agent a clean entry point that excludes dotfiles.
- It's git-trackable as a unit (the symlinks resolve naturally) — easy to replicate to a teammate or future VM.
- Symlinks (not folder moves) preserve all existing paths so nothing outside UAP breaks.

**Standard layout:**

```
~/workspace/
  CLAUDE.md          ← router (Layer 0): names each subworkspace and how to route tasks
  ops/      → ~/ops          team ops (meetings, tickets, runbooks)
  dev/      → ~/dev          code repos
    dev/dashboard/ → ~/dashboard   example: an in-house dashboard repo (lives under dev/ as a code repo)
  uap/      → ~/uap          this OS's runbook + configs
  <add more symlinks as new workspaces appear>
```

Sub-repos that are conceptually code (like `dashboard`) get symlinked under `~/dev/`, not at the top level of `~/workspace/`. Only top-level *workspaces* (ops, dev, uap) live at the hub root.

**Setup steps:**

```bash
mkdir -p ~/workspace
ln -sfn ~/ops       ~/workspace/ops
ln -sfn ~/dev       ~/workspace/dev
ln -sfn ~/uap       ~/workspace/uap
# (add any other top-level workspaces here)

# Code repos that live elsewhere in $HOME get symlinked under ~/dev/, not at the hub root:
ln -sfn ~/dashboard ~/dev/dashboard

cp configs/workspace/CLAUDE.md ~/workspace/CLAUDE.md
```

The archived `configs/workspace/CLAUDE.md` is a starter template — edit it on each deployment to describe that machine's actual subworkspaces and routing rules. The "Out-of-scope" section listing sensitive paths should be kept verbatim.

When a new top-level workspace is added later (e.g., a new project folder under `~/`), add it to `~/workspace/` as a symlink and to the router's layout table.

## Phase 8.6 — Claude Code autostart

UAP is built around AI-collaborator workflows, so a Claude Code session opens automatically on every login (in remote-control mode and with permission prompts bypassed):

```
# In ~/.config/i3/config:
exec --no-startup-id alacritty --working-directory /home/<your-username>/workspace -e claude --permission-mode=bypassPermissions
```

Launching from `~/workspace/` (not `~/`) is the UAP standard so Claude loads the hub's `CLAUDE.md` (Layer 0) on startup and routes to subworkspaces from there.

Remote-control is enabled at startup via `~/.claude/settings.json`:

```json
{
  "remoteControlAtStartup": true,
  "skipDangerousModePermissionPrompt": true
}
```

Together these mean every login spawns an alacritty running `claude` that's:
- Bypassing tool-permission prompts (`--permission-mode=bypassPermissions`).
- Already exposing its session via remote-control — the URL appears in the Claude mobile app immediately and you can also reach it at `https://claude.ai/code/session_<id>`.

If you don't want the autostart on a specific login, kill it after start (`pkill -f 'claude --permission-mode'`) or remove the `exec` line.

**Manual launch:** two ways beyond the autostart.

1. **Keybinding `Mod1+c`** — same i3 config:
   ```
   bindsym $mod+c exec --no-startup-id alacritty --working-directory /home/<your-username>/workspace -e claude --permission-mode=bypassPermissions
   ```
2. **Rofi launcher (`Mod1+d` → "Claude (workspace)")** — a `.desktop` file under `~/.local/share/applications/` + the official Claude icon:
   ```bash
   mkdir -p ~/.local/share/applications ~/.local/share/icons/claude
   cp configs/desktop-entries/claude-workspace.desktop ~/.local/share/applications/
   cp configs/icons/claude.png ~/.local/share/icons/claude/claude.png
   update-desktop-database ~/.local/share/applications
   ```
   The rofi theme `configs/rofi-tokyo-night.rasi` enables `sort: true` so entries are sorted by usage frequency. To make Claude show up first immediately after deploy (before any usage history accumulates), pre-seed the cache:
   ```bash
   echo "20 claude-workspace.desktop" > ~/.cache/rofi3.druncache
   ```

Both share the same command, so behavior is identical: alacritty in `~/workspace/`, Claude with `bypassPermissions` and remote-control on.

## Phase 8.5 — System-wide dark mode (GTK + Qt)

i3 doesn't bring a desktop environment, so GTK and Qt apps default to light themes (you'll see white menu bars in Typora, Thunar, Edge, Chrome, flameshot, etc.). Make them all dark:

```bash
sudo apt install -y gnome-themes-extra qt5-style-plugins

# GTK 3 / 4 settings (file-based — works without gsettings)
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
cp configs/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini
cp configs/gtk-4.0/settings.ini ~/.config/gtk-4.0/settings.ini

# gsettings (modern path, used by GNOME-aware apps)
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
```

The `xinitrc` deployed in Phase 6 already sets these env vars so they propagate to all apps started from i3:

```sh
export GTK_THEME=Adwaita:dark            # GTK 2 / Electron menus
export QT_STYLE_OVERRIDE=Adwaita-Dark    # Qt apps (e.g. flameshot)
export QT_QPA_PLATFORMTHEME=gtk2         # Qt → follow GTK theme via qt5-gtk2-platformtheme
```

Apps already running before this change (most importantly Typora and Edge) need to be restarted to pick up the dark theme. `pkill typora` then relaunch — same for any open browsers.

## Phase 8.7 — Plymouth boot splash

Replace the default Ubuntu splash with the UAP logo on a Tokyo Night background. Only visible on the hypervisor console / bare-metal display during boot (you won't see it via RDP since RDP only connects after boot finishes), but it brands the OS for anyone who does see the console.

```bash
sudo mkdir -p /usr/share/plymouth/themes/uap
sudo cp configs/plymouth/uap.plymouth configs/plymouth/uap.script configs/plymouth/logo.png /usr/share/plymouth/themes/uap/
sudo apt install -y plymouth-label   # silences a label-pango warning during initramfs build
sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth \
  /usr/share/plymouth/themes/uap/uap.plymouth 100
sudo update-alternatives --set default.plymouth /usr/share/plymouth/themes/uap/uap.plymouth
sudo update-initramfs -u
```

The logo is a static PNG; to rebrand, drop in a new `logo.png` (transparent background recommended, ~800×300) and re-run `sudo update-initramfs -u`.

## Phase 9 — First connect

From a remote machine on the same Tailnet, RDP to this VM (`mstsc`, Remmina, etc.). On login you should see:

- Tokyo Night-themed i3 with the bar at the top
- Workspaces labeled `1`, `2`, … with the active one prefixed by its window title
- `Mod1+Return` (Alt+Enter) opens alacritty
- `Mod1+d` opens rofi launcher (`drun`) — includes "Claude (workspace)" entry
- `Mod1+c` opens a fresh Claude Code session in `~/workspace/`
- `Mod1+n` opens thunar
- `Mod1+Shift+Return` opens firefox
- `Print` or `Mod1+Shift+s` opens flameshot
- `Mod1+1`..`9`,`0` switches workspaces; `Mod1+Shift+...` moves windows

If the bar is empty or the title doesn't update on focus change, check `~/.local/bin/i3-workspace-title` is running and that `i3 --get-socketpath` returns a path.

---

## Known issues & gotchas

These are all real things that have hit this setup. The fixes are baked into the configs/scripts, but you'll re-encounter them if you deviate.

### A. Alt+Enter "could not be successfully run"

i3-nagbar fires when an `exec` command's child exits non-zero quickly. An earlier version of the config wrapped the terminal launch in `exec sh -c 'if [ -n "$X2GO_SESSION" ]; then xterm; else alacritty; fi'`. The same string ran fine when invoked directly from a shell, but i3's exec/SIGCHLD path tripped the nagbar. Fix: bind `Mod1+Return` to a plain command (`exec --no-startup-id alacritty`) or to an external shell script — never inline `sh -c` with conditionals in a `bindsym` line.

### B. Alt+number bindings stop working after RDP reconnect

Microsoft RDP sends KeyboardSync PDUs on reconnect. On this xrdp+i3 stack, that sometimes leaves `ISO_Level5_Shift` (mapped to Mod3) stuck in pressed state. With Mod3 held, `Alt+1` becomes `Alt+ISO_Level5_Shift+1` and i3 won't fire its binding. Symptoms: workspace switch shortcuts silently die after a reconnect; a fresh login works fine.

Fix: `/etc/xrdp/reconnectwm.sh` (deployed in Phase 6 step 2) calls `xdotool keyup` for all common modifiers on every reconnect. Diagnose with `xinput test-xi2 --root` and look for `modifiers: base 0x20`; or compare `xdotool key alt+1` (broken) against `xdotool key --clearmodifiers alt+1` (works) to confirm the stuck-modifier theory.

### C. Black screen on RDP reconnect (chansrv socket held by stale xrdp)

Symptom: new RDP connection shows black screen, xrdp logs show `xrdp_mm_chansrv_connect: connect failed trying again...`. Cause: a previous xrdp child (from an unclean disconnect — sleep, network swap) still holds `xrdp_chansrv_socket_<DISPLAY>`.

Fix: `sudo lsof -p <chansrv-pid> | grep chansrv_socket` to find the stale child, then `sudo kill <stale-xrdp-pid>` — kill ONLY that specific child PID, not the whole xrdp service. The chansrv socket returns to LISTEN and new connects succeed.

### D. xrdp keymap warning ("local keymap file ... doesn't match built in keymap")

Cosmetic. The `.km` file works; removing it breaks key translation. Leave it alone.

### E. Non-US English RDP clients can't type `/` and a few other punctuation keys

xrdp ships only a handful of keymap files (`/etc/xrdp/km-*.ini`). If the Windows RDP client reports a locale not in that set (e.g. English-Canada `0x00001009`), xrdp falls back to US English imperfectly and a few keys including `/` get mis-translated. Fix: copy `km-00000409.ini` to `km-<your-locale>.ini`. See Phase 6 step 6.

### F. Punctuation keys (`/`, `?`, `'`, `"`, etc.) arrive as wrong characters on Microsoft Remote Desktop clients

Symptom: typing `/` produces `#`, `'` produces something else, etc. over RDP from Microsoft Remote Desktop on Android (and possibly mstsc on Windows). xdotool injection of `/` directly on the X server works fine, proving the bug is xrdp-side, not X-side.

Root cause: the Microsoft RD client defaults to **scancode mode**, which sends raw key scan codes. xrdp 0.9.24 looks up these scancodes in `/etc/xrdp/km-<LCID>.ini`. When the client reports a non-US English locale (e.g. `0x00001009` English-Canada) and no exact keymap file exists, xrdp falls back to the US keymap — but the client's *physical key layout* expectations may not match US, so punctuation arrives garbled.

**Fix (client-side toggle, no server change needed):** in the Microsoft Remote Desktop app, turn OFF "Use scancode input when available". This makes the client send each character as a Unicode event, which xrdp 0.9.24 handles correctly regardless of LCID/keymap.

- **Android:** Tap **☰ menu → General → "Use scancode input when available" → OFF**
- **iOS / macOS / Windows mstsc:** equivalent setting in the app's general/keyboard preferences. Look for "scancode" or "keyboard mode".

The xrdp 0.10+ upgrade (with better keymap handling) would also fix the underlying issue but isn't in Ubuntu 24.04 repos; see [neutrinolabs/xrdp#3339](https://github.com/neutrinolabs/xrdp/discussions/3339).

### G. xrdp-sesman creates a new session instead of reattaching after `xrdp.service` restart

Symptom: after `sudo systemctl restart xrdp.service` (e.g. for a config change), the next RDP reconnect lands the user on a fresh `:11` Xorg session instead of reattaching to the `:10` session they had before. The old session keeps running headless, but all its windows are stranded.

Root cause: the default `Policy=Default` in `sesman.ini` matches sessions by `(user, bpp, depth, ip-addr, connection-state)`. xrdp service restart invalidates the connection-state tracking, so sesman doesn't see a match and creates a new session.

Fix: set `Policy=UBD` in `/etc/xrdp/sesman.ini` and restart sesman. Reconnects then reattach by user+bpp+depth only. See Phase 6 step 3b. The archived `configs/xrdp-sesman.ini` already has this set.

Recovery when it happens: any Claude Code sessions in the stranded `:10` are still reachable via the Claude mobile app (because of `remoteControlAtStartup`); other windows are lost unless you can SSH in and find another way to access them.

### H. Proxmox memory ballooning

On Proxmox, set the VM's memory ballooning *off* if you allocate a specific RAM size. With ballooning on, the displayed "memory" metric is the balloon size, which makes monitoring confusing and can squeeze the VM under host pressure.

---

## Per-user state that is NOT in this folder

These are intentionally outside the runbook and need to be redone manually:

- Tailscale auth (one-time login URL)
- Microsoft Edge profile sync
- Snap auth (firefox / chromium login)
- SSH keys, dotfiles for shells, git config, etc.
- Any Claude Code / API tokens

---

## Verification checklist

After deploy, confirm in this order:

1. `systemctl is-active xrdp` → `active`
2. RDP from another host succeeds and lands on i3
3. `Mod1+Return` opens alacritty
4. Top bar shows workspace numbers; active one shows `N: <window title>`
5. `pgrep -f i3-workspace-title` returns one PID
6. `cat /etc/xrdp/reconnectwm.sh` matches `scripts/reconnectwm.sh`
7. `sudo update-alternatives --display default.plymouth` shows the UAP theme as the active link

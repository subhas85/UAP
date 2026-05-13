# UAP Template + Identity + Apply — Design

This is the locked design for how UAP separates the **pristine framework** (the GitHub repo, identical for everyone) from **per-machine state** (the operator's identity, secrets, choices). It is what makes UAP both reproducible and updatable.

## Architecture in one picture

```
┌────────────────────────────────────────────────────────────────────────┐
│  ~/uap/   ← framework (git-tracked at github.com/subhas85/uap)         │
│  ─────                                                                 │
│   os/                       ← OS / desktop-layer components            │
│     plymouth/                                                          │
│       uap.plymouth.tmpl   ← template with ${OS_NAME} ${TAGLINE} etc.   │
│       uap.script.tmpl                                                  │
│       logo.png            ← default asset (overridable per-machine)    │
│     i3/i3-config.tmpl                                                  │
│     alacritty/alacritty.toml.tmpl                                      │
│     …                                                                  │
│   ai/                       ← AI-layer components                      │
│     workspace-hub/CLAUDE.md.tmpl                                       │
│     desktop-entries/claude-workspace.desktop.tmpl                      │
│     …                                                                  │
│   workflows/                ← ICM starter pipelines (requirements,     │
│     requirements/             helpdesk, incidents, dev). Wizard seeds  │
│     helpdesk/                 selected ones into ~/ops/pipelines/.     │
│     incidents/                                                         │
│     dev/                                                               │
│   profiles/                 ← pre-canned identity.yaml files           │
│     personal.yaml           (skip the wizard if a profile fits)        │
│     production.yaml                                                    │
│   setup/                                                               │
│     QUESTIONNAIRE.md                                                   │
│     CLAUDE.md                                                          │
│     DESIGN.md             ← this file                                  │
│     apply.sh              ← THE renderer + deployer                    │
│   bootstrap.sh                                                         │
└────────────────────────────────────────────────────────────────────────┘
                            │  reads templates  │
                            ▼                    ▲
┌────────────────────────────────────────────────────────────────────────┐
│  ~/uap.local/   ← per-machine state (NOT in framework repo)            │
│  ───────────                                                           │
│   identity.yaml           ← OS_NAME, TAGLINE, operator, colors, …      │
│   answers.yaml            ← full wizard answers from this deployment   │
│   assets/                                                              │
│     logo.png              ← operator-provided override (optional)      │
│     wallpaper.png                                                      │
│   rendered/               ← apply.sh writes here, then installs from   │
│     plymouth/                                                          │
│       uap.plymouth                                                     │
│       uap.script                                                       │
│     i3/config                                                          │
│     alacritty/alacritty.toml                                           │
│     …                                                                  │
└────────────────────────────────────────────────────────────────────────┘
                            │  installs to      │
                            ▼                    ▲
┌────────────────────────────────────────────────────────────────────────┐
│  Live system locations  ← apply.sh writes/copies here                  │
│  ─────────────────────                                                 │
│    /usr/share/plymouth/themes/<theme>/                                 │
│    ~/.config/i3/config                                                 │
│    ~/.config/alacritty/alacritty.toml                                  │
│    /etc/xrdp/sesman.ini                                                │
│    …                                                                   │
└────────────────────────────────────────────────────────────────────────┘
```

Two rules to internalize:

1. **The framework never reads identity. Only `apply.sh` reads identity.** Templates are static text with `${VAR}` placeholders, no logic.
2. **Every deployed file has a render in `~/uap.local/rendered/` first.** `apply.sh` never writes directly to `/etc/...` from a template. It writes to the render dir, then installs from there. Easier to debug, easier to diff against the live file.

## Template syntax

**Choice: GNU `envsubst` with an explicit variable allow-list.**

Why:
- Zero dependencies — preinstalled in `gettext-base` on every Ubuntu.
- Familiar to anyone who's written a Docker entrypoint or a CI script.
- Allow-list mode (`envsubst 'VAR_LIST'`) prevents accidental substitution of unrelated `$PATH` etc. from the environment.

Syntax in template files: `${VAR_NAME}`. Curly braces are mandatory (avoids `$FOO` collisions with shell variables in scripts).

Usage in `apply.sh`:

```bash
export OS_NAME TAGLINE BG_R BG_G BG_B   # only the vars we want substituted
envsubst '${OS_NAME} ${TAGLINE} ${BG_R} ${BG_G} ${BG_B}' \
    < ~/uap/os/plymouth/uap.plymouth.tmpl \
    > ~/uap.local/rendered/plymouth/${OS_NAME_LOWER}.plymouth
```

**Escape hatch.** Templates without any `${…}` placeholders are still valid; envsubst is a no-op on them. This means a static config can be migrated by simply renaming `foo.conf` → `foo.conf.tmpl` even before any variables are extracted, and `apply.sh` will handle it uniformly. Mix-and-match migration during Phase 3 is fine.

**Files that can't be templated** (binaries: PNG icons, font files, etc.) are not renamed. `apply.sh` treats `.tmpl` files specially; everything else under a component's folder (`os/<component>/`, `ai/<component>/`, etc.) is copied through verbatim.

## `identity.yaml` schema

This is the *single source of truth* for what makes one UAP machine different from another. Everything else flows from it.

```yaml
# ~/uap.local/identity.yaml — example

schema_version: 1                # bump if breaking changes to schema; apply.sh checks

os:
  name: UAP                      # ${OS_NAME} — appears in Plymouth, README intro, hostnames suggestions
  name_lower: uap                # ${OS_NAME_LOWER} — used for theme dir names, package names
  tagline: out of this world     # ${TAGLINE} — Plymouth subtitle, README intro
  hostname: my-uap-box           # ${HOSTNAME} — set via hostnamectl

operator:
  username: operator             # the Linux user UAP is installed for
  email: operator@example.com    # for deployment record only; not used in any config
  role: it-sysadmin              # free-form; used by ops/bootstrap (separate track) for repo selection

theme:
  palette: tokyo-night           # one of: tokyo-night | dracula | nord | catppuccin | gruvbox | custom
  # Concrete colour values (the wizard picks these from the palette name; operator can override).
  bg_hex:     "#1a1b26"
  bg_r:       "0.102"            # ${BG_R} — used in Plymouth's RGB-float API
  bg_g:       "0.106"
  bg_b:       "0.149"
  fg_hex:     "#a9b1d6"
  accent_hex: "#7aa2f7"
  urgent_hex: "#f7768e"
  font: "JetBrainsMono Nerd Font"

network:
  remote_path: tailscale         # tailscale | wireguard | zerotier | direct
  rdp_scope: tailscale-only      # tailscale-only | all-interfaces

apps:
  browsers: [edge, chrome]       # multi-select from Q5.1
  markdown_editor: typora        # one of: typora | obsidian | marktext | vscode | none
  terminal_tools: [btop, bat, glow]
  file_manager: thunar
  screenshot: flameshot

wm:
  mod_key: Mod1
  workspace_count: 10
  workspace_title_daemon: true
  per_window_titles: false

ai:
  autostart_claude: true
  permission_mode: bypassPermissions
  remote_control_at_startup: true
  use_icm: true
  workspace_hub_name: workspace
  subworkspaces: [ops, dev, uap]
  concierge: true                # Q7.9 — autostart system-concierge Claude session
  chat_bridge: none              # Q7.8 — none | openacp-telegram | (others later)

boot:
  custom_plymouth: true
  wallpaper: tokyo-night-default # tokyo-night-default | <path> | solid-color
  system_dark_mode: true

locale:
  keyboard_layout: us
  rdp_lcid: "0x00001009"         # if non-US, apply.sh creates km-<lcid>.ini from km-00000409.ini

assets:
  # Optional overrides — if these files exist in ~/uap.local/assets/, they override defaults.
  logo: assets/logo.png          # path relative to ~/uap.local/
  wallpaper: assets/wallpaper.png

components_enabled:              # which apply.sh components to run; lets operator selectively disable
  - plymouth
  - i3
  - alacritty
  - rofi
  - typora-themes
  - gtk-theme
  - xrdp
  - workspace-hub
  - claude-autostart
  - workspace-title-daemon
  - concierge
```

**Schema version field is mandatory.** When apply.sh detects an unfamiliar schema_version, it must refuse to run and direct the operator to upgrade or downgrade UAP. This protects against running a new framework against an old identity file (or vice versa).

## `apply.sh` contract

### Invocation

```bash
~/uap/setup/apply.sh                 # apply everything in identity.yaml
~/uap/setup/apply.sh plymouth        # apply only the named component(s)
~/uap/setup/apply.sh --dry-run       # render templates, show diff vs live, install nothing
~/uap/setup/apply.sh --no-sudo       # skip steps that require root (useful for testing)
```

### Behavior

1. **Read** `~/uap.local/identity.yaml`. Validate `schema_version`. Export every leaf value as `${VAR}` (uppercased, dot-separated). E.g. `theme.bg_r` → `${THEME_BG_R}`. Also export some convenience shortcuts like `${OS_NAME}`, `${OS_NAME_LOWER}`, `${BG_R}`.

2. **Iterate** through `identity.components_enabled`. For each component:
   - Locate the source dir by searching `~/uap/os/<component>/`, then `~/uap/ai/<component>/`, then `~/uap/workflows/<component>/`. First match wins.
   - For every file in there:
     - If filename ends `.tmpl`: render with envsubst (allow-list mode) into `~/uap.local/rendered/<component>/<filename-without-.tmpl>`.
     - Otherwise (binary, asset, static): copy verbatim into the same render path.
   - Run the component's **install hook**: a function `install_<component>()` defined in `apply.sh` that knows where the rendered files belong on the live system (e.g. Plymouth's installer copies to `/usr/share/plymouth/themes/<theme>/` and runs `update-alternatives` + `update-initramfs`).

3. **Idempotency.** Every step must be safe to re-run. Use `install -m <mode> <src> <dst>` rather than naïve cp; use `update-alternatives --set` (replaces previous); diff before restarting services.

4. **Logging.** Output `[apply.sh] <component>: <action>` for each significant step. On error, exit non-zero with the failing component named.

5. **Error handling.** `set -euo pipefail` everywhere. A failed component aborts the run (no half-applied deployments). The operator can retry once they've fixed identity.yaml or the framework.

### Per-component install hook example

```bash
install_plymouth() {
    local render="$HOME/uap.local/rendered/plymouth"
    local theme="$OS_NAME_LOWER"
    local target="/usr/share/plymouth/themes/$theme"

    sudo install -d "$target"
    sudo install -m 644 "$render/$theme.plymouth" "$target/$theme.plymouth"
    sudo install -m 644 "$render/$theme.script"   "$target/$theme.script"
    sudo install -m 644 "$render/logo.png"        "$target/logo.png"

    sudo update-alternatives --install \
        /usr/share/plymouth/themes/default.plymouth default.plymouth \
        "$target/$theme.plymouth" 100
    sudo update-alternatives --set default.plymouth "$target/$theme.plymouth"

    sudo update-initramfs -u
    echo "[apply.sh] plymouth: installed theme '$theme'"
}
```

## Update workflow

```bash
cd ~/uap
git pull                                    # framework updates from github.com/subhas85/uap
~/uap/setup/apply.sh                        # re-render every component with EXISTING identity
```

The operator's `identity.yaml` is never touched by `git pull` (it's in `~/uap.local/`, outside the framework repo). After pull, `apply.sh` re-renders with the same identity and deploys.

If a framework update changes the schema (rare, requires schema_version bump), apply.sh detects the version mismatch, prints a clear migration message, and refuses to run until the operator follows it.

## Adding a new templatable component (instructions for the framework's future)

1. Place template + asset files at the right scope folder:
   - `~/uap/os/<component>/` for OS/desktop-layer things (plymouth, i3, alacritty, etc.)
   - `~/uap/ai/<component>/` for AI-layer things (workspace hub, Claude launcher, concierge)
   - `~/uap/workflows/<component>/` for ICM pipeline starters

   Templates end `.tmpl`.
2. Add the component name to the default `components_enabled` list in the `identity.yaml` example/schema.
3. Add an `install_<component>()` function in `apply.sh` that knows where rendered files belong on the live system.
4. Run `apply.sh <component>` to test.
5. Document under the matching Phase in `~/uap/README.md`.

## What this design rejects

- **In-place sed edits to deployed configs.** Always go through templates → rendered → install.
- **Identity values stored in environment files like `~/.uap.env`.** YAML's structure (lists, nested objects) is the right shape for what the wizard produces.
- **Configuration management tools (Ansible, Puppet).** Overkill for a single-machine OS workspace. Bash + envsubst + yq is enough and avoids any runtime/agent dependency.
- **Multiple identity files merged at apply time.** One file, one source of truth. Per-machine *overrides* are encoded as edits to that file, not as a layered override system.

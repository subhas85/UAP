# Wizard end-to-end test checklist

Use this when running `bootstrap.sh` on a fresh Ubuntu Server 24.04 VM. Copy to `wizard-test-YYYY-MM-DD.md` (or anywhere outside the repo) before filling in — keeps each test run as its own record.

Each phase has: the action, the expected outcome, and a slot for whatever actually happened. Replace `___` with values; check boxes as you go.

---

## Test environment

- Hypervisor: `___`
- VM specs: `___ vCPU / ___ GB RAM / ___ GB disk`
- Ubuntu release: `___`
- Linux user on VM: `___`
- Network: ☐ Tailscale ☐ LAN ☐ console only

---

## Phase 1 — bootstrap.sh

Command used (one-liner OR clone-then-run):
```
___
```

- [ ] Refuses root (or already running as non-root): no warning
- [ ] apt prereqs install or are detected as present
- [ ] Claude Code install succeeds (or detected as already installed)
- [ ] UAP repo lands at `~/uap` — commit SHA: `___`
- [ ] Final step: a `claude` session opens in `~/uap/setup/`

**If anything failed, paste the error block here:**
```
___
```

**Time elapsed from "ran the command" to "wizard prompt visible": `___`**

---

## Phase 2 — Wizard run

The wizard reads `setup/CLAUDE.md` (facilitator) and walks you through `setup/QUESTIONNAIRE.md`. Output: `~/uap.local/identity.yaml`.

- [ ] Facilitator instructions in `setup/CLAUDE.md` were clear (Claude knew what to do)
- [ ] Walked through every questionnaire section without getting stuck
- [ ] Produced `~/uap.local/identity.yaml`
- [ ] `yq '.schema_version' ~/uap.local/identity.yaml` returns `1`
- [ ] `yq '.components_enabled[]' ~/uap.local/identity.yaml` lists the expected components

**Questions that were confusing — quote them and what was unclear:**
```
Q: ___
Confusing because: ___
Suggested rewording: ___
```

**Sections that the wizard skipped or that Claude misinterpreted:**
```
___
```

---

## Phase 3 — apply.sh

- [ ] `~/uap/setup/apply.sh --dry-run` runs to completion
- [ ] Dry-run shows `DRY-RUN — would install …` for every enabled component (12 lines for a full profile)
- [ ] `~/uap.local/rendered/` populated with one subdirectory per component
- [ ] Real `~/uap/setup/apply.sh` runs to completion
- [ ] Each component reports `installed …` rather than `WARN` or error

**Component install failures (component name + error):**
```
___
```

---

## Phase 4 — Result

After apply.sh, reboot (optional) and verify:

- [ ] `systemctl is-active xrdp` → `active`
- [ ] RDP from another host lands on the i3 desktop
- [ ] Tokyo Night theme everywhere (i3 bar, alacritty, rofi, gtk apps, plymouth on console)
- [ ] `Mod1+Return` opens alacritty
- [ ] `Mod1+d` opens rofi launcher (drun)
- [ ] Top bar shows `1: <window title>` for the active workspace
- [ ] `pgrep -f i3-workspace-title` → single PID
- [ ] Claude autostarts in a fresh terminal (or `Mod1+c` opens one)
- [ ] No white menu bars in Thunar / Edge / Chrome (system-wide dark mode worked)
- [ ] `~/.claude/settings.json` either freshly installed OR `.uap-proposed` present
- [ ] `~/workspace/.claude/settings.json` (the workspace overlay) is present

---

## Verdict

Choose one:
- ☐ **Ship it.** End-to-end works; minor friction notes captured above.
- ☐ **Iterate.** Specific issues to fix before public release — list below.
- ☐ **Major rework.** Wizard or apply.sh has structural problems.

**Specific follow-up items (priority + suggested fix):**

1. `___`
2. `___`
3. `___`

---

## Optional: capture the produced identity.yaml

For followup discussion. Redact `operator.email` or `os.hostname` if you'd rather not share:

```yaml
___
```

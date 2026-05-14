# UAP Profiles

Pre-canned `identity.yaml` files that skip most of the wizard for common deployment shapes. The wizard's first question becomes "which profile do you want to start from?" — pick one, then override individual answers as needed.

## How an operator uses a profile

```bash
# After bootstrap.sh has cloned UAP and installed Claude Code:
cp ~/uap/profiles/personal-lab.yaml ~/uap.local/identity.yaml

# Edit any specific values (name, hostname, operator info)
vim ~/uap.local/identity.yaml

# Then apply
~/uap/setup/apply.sh
```

That's it — no wizard needed if the profile already matches what you want.

## Available profiles

Profiles are organized by **permission tier** — the posture Claude Code takes when the operator gives it a task. Pick the row that matches the blast radius of the machine.

| Profile | Permission mode | Autostart | Concierge / remote-control | Use case |
|---|---|---|---|---|
| `personal-lab.yaml`       | bypass allowed             | on  | on  | Your own isolated experiments. Trust the AI fully — only your VM is on the line. |
| `engineer.yaml`           | prompt before tool use     | on  | on  | Daily work with some sensitive context. Convenience features stay, but every tool call is gated by an explicit prompt. |
| `staff.yaml`              | prompt before tool use     | on  | off | Non-technical users. Launcher still convenient, but no background concierge actions, no mobile-app remote control. |
| `production-admin.yaml`   | prompt + manual launch     | off | off | M365, GitHub, servers, client data. Operator consciously launches each session — the right friction when state changes touch shared/production systems. |

The four profiles differ on ~5 fields under `ai.*` (and the `operator.role` label). Everything else — theme, fonts, window manager, xrdp policy, components installed — is identical across them. If you need to deviate on those, edit your copied `identity.yaml` after applying the profile.

A note on `production-admin`: Claude Code has no native "strict approvals" mode beyond `default`. True strictness for this tier should be layered on via a curated allowlist in `~/.claude/settings.json` (future work — `apply.sh` doesn't deploy that yet). Treat this profile as "default permission mode + manual launch" today.

Add new profiles by copying an existing one and editing. Submit a PR if it's broadly useful (org-specific deployments belong in your own ops/profiles/ folder, not in the public framework).

## What profiles do NOT include

- Operator name / email — always operator-specific, fill these in after copying.
- Hostname — same.
- Custom assets (logo, wallpaper) — drop those in `~/uap.local/assets/` after copying the profile.
- Anything that the wizard's Section 10 (operator profile / project types) would seed — profiles capture defaults, not your specific workflows.

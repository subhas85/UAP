# UAP Profiles

Pre-canned `identity.yaml` files that skip most of the wizard for common deployment shapes. The wizard's first question becomes "which profile do you want to start from?" — pick one, then override individual answers as needed.

## How an operator uses a profile

```bash
# After bootstrap.sh has cloned UAP and installed Claude Code:
cp ~/uap/profiles/personal.yaml ~/uap.local/identity.yaml

# Edit any specific values (name, hostname, operator info)
vim ~/uap.local/identity.yaml

# Then apply
~/uap/setup/apply.sh
```

That's it — no wizard needed if the profile already matches what you want.

## Available profiles

| Profile | When to use |
|---|---|
| `personal.yaml` | Single-operator homelab. All AI features on (`bypassPermissions`, autostart, concierge once shipped, remote-control). |
| `production.yaml` | Shared / production-ish deployment. Conservative defaults: permission prompts on, no autostart bypass, no concierge auto-launch. |

Add new profiles by copying an existing one and editing. Submit a PR if it's broadly useful (org-specific deployments belong in your own ops/profiles/ folder, not in the public framework).

## What profiles do NOT include

- Operator name / email — always operator-specific, fill these in after copying.
- Hostname — same.
- Custom assets (logo, wallpaper) — drop those in `~/uap.local/assets/` after copying the profile.
- Anything that the wizard's Section 10 (operator profile / project types) would seed — profiles capture defaults, not your specific workflows.

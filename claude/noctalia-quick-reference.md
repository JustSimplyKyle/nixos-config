# Noctalia Configuration - Quick Reference

## Daily Usage

### Configure Your Bar
- Open Noctalia settings GUI
- Make changes (colors, widgets, layout, etc.)
- Changes save and persist automatically
- No rebuild needed!

### Sync to Nix Template
**Keybind**: `Ctrl+Shift+S`
- Press anywhere on your desktop
- Get notification when done
- Backs up old config automatically

**Or run manually**:
```bash
cd modules/home/noctalia-shell
./sync-from-gui.py
```

## When to Rebuild

### You DON'T need to rebuild for:
- ❌ Changing bar colors/theme
- ❌ Rearranging widgets
- ❌ Adjusting bar position
- ❌ Any GUI setting changes

### You DO need to rebuild for:
- ✅ First-time setup (to enable writable config)
- ✅ Making template permanent for other hosts
- ✅ After syncing GUI → Nix (optional, for reproducibility)

## File Locations

| File | Purpose |
|------|---------|
| `~/.config/noctalia/settings.json` | Your active config (writable) |
| `modules/home/noctalia-shell/default.nix` | Nix template (managed by Git) |
| `modules/home/noctalia-shell/sync-from-gui.py` | Sync script |
| `modules/home/niri/keybinds.nix` | Keybind config |

## Quick Commands

```bash
# Configure bar
# → Use Noctalia GUI

# Sync to Nix
Ctrl+Shift+S                    # Keybind
./sync-from-gui.py              # Manual

# Test & apply
dcli build leno-desktop         # Test build
dcli rebuild                    # Apply changes

# Reset to defaults
rm ~/.config/noctalia/settings.json
dcli rebuild

# View settings
cat ~/.config/noctalia/settings.json | jq

# View backups
ls -lh modules/home/noctalia-shell/backups/
```

## Workflow Example

1. **Customize**: Open Noctalia GUI → Change colors to Catppuccin → Rearrange widgets
2. **Use it**: Changes work immediately, persist across reboots
3. **Sync** (optional): Press `Ctrl+Shift+S` to save template
4. **Rebuild** (optional): `dcli rebuild` to make permanent
5. **Commit** (optional): `git add . && git commit -m "Update Noctalia config"`

## Keybinds

| Keybind | Action |
|---------|--------|
| `Ctrl+Shift+S` | Sync Noctalia GUI settings to Nix template |

## Documentation

- Full guide: `modules/home/noctalia-shell/README-sync.md`
- Setup docs: `claude/noctalia-gui-editable-config.md`
- This reference: `claude/noctalia-quick-reference.md`

## Troubleshooting

**Settings not saving?**
- Check: `ls -lh ~/.config/noctalia/settings.json`
- Should be regular file, not symlink
- If symlink: `dcli rebuild` to fix

**Keybind not working?**
- Rebuild to apply: `dcli rebuild`
- Check keybinds loaded: `niri msg version`

**Want to reset?**
```bash
rm ~/.config/noctalia/settings.json
dcli rebuild
```

## Created
October 26, 2025

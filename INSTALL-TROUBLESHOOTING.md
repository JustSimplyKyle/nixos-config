# Black Don OS - Installation Troubleshooting Guide

This guide helps resolve common issues when installing Black Don OS.

## Quick Diagnosis

### Check Your Installation Method

**✅ Correct way (recommended):**
```bash
bash <(curl -s https://gitlab.com/theblackdon/black-don-os/-/raw/main/install-black-don-os.sh)
```

**❌ Wrong way (will fail):**
```bash
# Don't use the old install-zaneyos.sh script - it points to the wrong repo!
bash <(curl -s https://gitlab.com/theblackdon/black-don-os/-/raw/main/install-zaneyos.sh)
```

## Common Issues and Solutions

### 1. Repository Clone Failures

**Error:** `fatal: repository 'https://gitlab.com/zaney/zaneyos.git' not found`

**Cause:** Using the old install script that points to the wrong repository.

**Solution:** Use the correct installation script:
```bash
bash <(curl -s https://gitlab.com/theblackdon/black-don-os/-/raw/main/install-black-don-os.sh)
```

### 2. Build Failures

**Error:** `error: getting status of '/nix/store/.../nixos-system-HOSTNAME': No such file or directory`

**Possible Causes:**
- Network connectivity issues
- Flake configuration errors
- Hardware detection problems

**Solutions:**

1. **Check network connectivity:**
   ```bash
   ping google.com
   nix-shell -p curl
   curl -I https://cache.nixos.org
   ```

2. **Retry the build manually:**
   ```bash
   cd ~/black-don-os
   sudo nixos-rebuild build --flake .#your-hostname
   ```

3. **Check your hostname configuration:**
   ```bash
   # Verify your hostname exists in the flake
   grep -r "your-hostname" flake.nix
   ls hosts/your-hostname/
   ```

### 3. Hardware Detection Issues

**Error:** GPU profile not working correctly or display issues after reboot.

**Solution:** Update your hardware configuration manually:

1. **For NVIDIA systems:**
   ```bash
   # Find your actual GPU bus IDs
   lspci | grep VGA
   
   # Edit your host variables
   nano hosts/your-hostname/variables.nix
   
   # Update these lines with your actual IDs:
   intelID = "PCI:0:2:0";   # Your integrated GPU
   nvidiaID = "PCI:1:0:0";  # Your NVIDIA GPU
   ```

2. **Regenerate hardware configuration:**
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/your-hostname/hardware.nix
   ```

### 4. Permission Errors

**Error:** `permission denied` or `operation not permitted`

**Solutions:**
1. **Make sure you're running with sudo for system operations:**
   ```bash
   sudo nixos-rebuild switch --flake .#your-hostname
   ```

2. **Check file ownership:**
   ```bash
   sudo chown -R $USER:users ~/black-don-os
   ```

### 5. Flake Lock Issues

**Error:** `error: unable to download` or flake input issues

**Solution:** Update flake inputs:
```bash
cd ~/black-don-os
nix flake update
sudo nixos-rebuild switch --flake .#your-hostname
```

### 6. Missing Dependencies

**Error:** `command not found: git` or `command not found: lspci`

**Solution:** Install required tools:
```bash
nix-shell -p git pciutils
# Then re-run the installation script
```

### 7. Hostname Conflicts

**Error:** Configuration exists but builds fail

**Possible Issues:**
- Used "default" as hostname (this will cause problems!)
- Hostname contains invalid characters
- Hostname conflicts with existing configuration

**Solution:**
```bash
# Check for problematic hostnames
ls hosts/
grep -r "default" hosts/your-hostname/

# If you used "default", create a proper hostname:
./setup-new-host.sh
```

### 8. Branch/Version Issues

**Error:** `error: unable to find flake 'git+https://gitlab.com/theblackdon/black-don-os'`

**Cause:** Trying to use wrong branch or old references

**Solution:** Ensure you're using the main branch:
```bash
cd ~/black-don-os
git checkout main
git pull origin main
```

## Advanced Troubleshooting

### Enable Verbose Logging

For detailed build information:
```bash
sudo nixos-rebuild switch --flake .#your-hostname --verbose --show-trace
```

### Check System Logs

After a failed installation:
```bash
journalctl -xeu nixos-rebuild
journalctl -f  # Follow live logs
```

### Manual Installation Steps

If the automated script fails completely, you can install manually:

1. **Clone the repository:**
   ```bash
   git clone https://gitlab.com/theblackdon/black-don-os.git ~/black-don-os
   cd ~/black-don-os
   ```

2. **Create a new host configuration:**
   ```bash
   ./setup-new-host.sh
   ```

3. **Generate hardware configuration:**
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/your-hostname/hardware.nix
   ```

4. **Build and install:**
   ```bash
   export NIX_CONFIG="experimental-features = nix-command flakes"
   sudo nixos-rebuild boot --flake .#your-hostname
   ```

### Recovery from Failed Installation

If your system won't boot after installation:

1. **Boot from NixOS ISO**
2. **Mount your system:**
   ```bash
   sudo mount /dev/your-root-partition /mnt
   sudo mount /dev/your-boot-partition /mnt/boot
   ```

3. **Roll back using generations:**
   ```bash
   sudo nixos-enter --root /mnt
   nixos-rebuild list-generations
   nixos-rebuild switch --rollback
   ```

## Getting Help

### Before Asking for Help

Please gather this information:

1. **System Information:**
   ```bash
   uname -a
   lspci | grep VGA
   df -h
   free -h
   ```

2. **Black Don OS Information:**
   ```bash
   cd ~/black-don-os
   git log --oneline -5
   git status
   ls hosts/
   ```

3. **Error Logs:**
   Save the complete error output and any relevant log files.

### Where to Get Help

1. **Check the main documentation:**
   - `README-BLACK-DON-OS.md`
   - `dcli.md`

2. **Review your configuration:**
   - Check `hosts/your-hostname/variables.nix`
   - Verify `hosts/your-hostname/hardware.nix`

3. **Original ZaneyOS documentation:**
   Since Black Don OS is based on ZaneyOS, their documentation may also help:
   - [ZaneyOS GitLab](https://gitlab.com/zaney/zaneyos)

## Success Checklist

After installation, verify these items:

- [ ] System boots into Hyprland desktop
- [ ] Network connectivity works
- [ ] Graphics acceleration is working (check `nvidia-smi` for NVIDIA)
- [ ] Audio works
- [ ] Your user account is set up correctly
- [ ] Configuration directory exists at `~/black-don-os`
- [ ] `dcli` command works: `dcli status`

## Prevention Tips

To avoid issues in future installations:

1. **Never use "default" as a hostname**
2. **Always verify hardware detection before building**
3. **Keep your flake.lock updated regularly**
4. **Back up working configurations before major changes**
5. **Test builds before switching**: `nixos-rebuild build` instead of `switch`

---

*This troubleshooting guide is maintained alongside Black Don OS. If you discover new issues or solutions, consider contributing improvements.*
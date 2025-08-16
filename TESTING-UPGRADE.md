# Testing ZaneyOS 2.3 → 2.4 Upgrade Scripts

## 🧪 Testing Environment Setup

This branch (`ddubs-dev`) contains the upgrade scripts for safe testing before merging to main.

### Prerequisites for Testing:
- A ZaneyOS 2.3 system (stable-2.3 branch)
- Access to the ddubs-dev branch files
- Backup of your existing system (the script creates one, but manual backup recommended too)

## 📋 Test Plan

### Phase 1: Script Validation
1. **Syntax Check**: Verify scripts run without syntax errors
2. **Dry Run**: Test version detection and backup creation
3. **Permission Check**: Ensure scripts are executable and have proper permissions

### Phase 2: Backup Testing  
1. **Backup Creation**: Verify complete backup is created
2. **Backup Integrity**: Confirm backup contains all necessary files
3. **Revert Testing**: Test revert functionality without upgrade

### Phase 3: Upgrade Testing
1. **Full Upgrade**: Complete 2.3 → 2.4 upgrade process
2. **Configuration Migration**: Verify all settings are preserved
3. **Terminal Handling**: Confirm terminal enables work correctly
4. **SDDM Transition**: Test display manager change safety

### Phase 4: Post-Upgrade Validation
1. **System Boot**: Verify system boots correctly with SDDM
2. **Application Functionality**: Test all applications work as expected
3. **Configuration Persistence**: Confirm all custom settings preserved

## 🔧 Testing Commands

### To Get ddubs-dev Branch:
```bash
cd ~/zaneyos
git fetch origin
git checkout ddubs-dev
git pull origin ddubs-dev
```

### Test Script Syntax:
```bash
bash -n upgrade-2.3-to-2.4.sh
bash -n revert-to-2.3.sh
```

### Test Version Detection (Safe):
```bash
# This will only check version and create backup, then exit
./upgrade-2.3-to-2.4.sh
# Answer 'N' when asked to continue
```

### Test Revert Functionality:
```bash
# After creating a backup, test revert
./upgrade-2.3-to-2.4.sh --revert
# Or use the wrapper
./revert-to-2.3.sh
```

## 📊 Test Results Template

### System Configuration:
- **Current Version**: 2.3 (branch: stable-2.3)
- **Terminal Used**: [kitty/alacritty/wezterm/ghostty]
- **Custom Settings**: [list any special configurations]
- **Hardware**: [brief hardware description]

### Test Results:

#### ✅ Pre-Flight Checks:
- [ ] Script syntax validation passes
- [ ] Version detection works correctly
- [ ] Backup creation succeeds
- [ ] Required tools (git, nh, etc.) detected

#### ✅ Backup & Revert:
- [ ] Complete backup created successfully
- [ ] Backup location clearly displayed
- [ ] Revert script works correctly
- [ ] System restored to 2.3 after revert
- [ ] All original settings preserved after revert

#### ✅ Upgrade Process:
- [ ] Configuration migration completes
- [ ] Terminal handling works correctly
- [ ] Build process succeeds with 'boot' option
- [ ] No error messages during upgrade

#### ✅ Post-Upgrade System:
- [ ] System reboots successfully
- [ ] SDDM displays correctly (no blank screen)
- [ ] Desktop environment loads
- [ ] Preferred terminal opens and works
- [ ] All applications function correctly
- [ ] Custom settings preserved (theme, wallpaper, etc.)

### Issues Found:
[Describe any issues encountered during testing]

### Recommendations:
[Any suggestions for script improvements]

## 🚨 Testing Safety Notes

1. **VM Testing Recommended**: Test in a VM first if possible
2. **External Backup**: Create manual backup outside of script
3. **Recovery Plan**: Have NixOS live USB available
4. **Time Allocation**: Allow 1-2 hours for complete testing
5. **Network Connection**: Ensure stable internet for downloads

## 📝 Reporting Results

When reporting test results, include:
1. System specifications
2. Starting configuration (2.3 branch and custom settings)
3. Complete test results using the template above
4. Any error messages or log file excerpts
5. Screenshots of any issues

## 🔄 Iteration Process

After testing:
1. Report results and any issues found
2. Script improvements will be made on ddubs-dev
3. Re-test updated scripts
4. Once stable, merge to main branch

## 📞 Support During Testing

If you encounter issues during testing:
1. Check the log file (location shown in script output)
2. Try the revert option to restore 2.3
3. Report the issue with log file contents
4. Your backup is always available for manual recovery

Remember: This is testing software - always have a recovery plan!

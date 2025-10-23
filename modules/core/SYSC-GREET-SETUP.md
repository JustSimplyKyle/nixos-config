# sysc-greet Setup Instructions

## What was created:

1. **New module**: `modules/core/sysc-greet.nix`
2. **Module imported** in `modules/core/default.nix`

## How to enable per host:

In any host's `default.nix` (e.g., `hosts/nixos-leno/default.nix`), add:

```nix
services.sysc-greet.enable = true;
```

## Configuration options:

```nix
services.sysc-greet = {
  enable = true;
  compositor = "Hyprland";  # Auto-detected, or specify: "niri", "sway"
  theme = null;             # Optional theme
  border = null;            # Optional border style
  screensaver = true;       # Enable/disable screensaver
};
```

## Initial build requirement:

The module needs hash values to be filled in. On first build attempt, you'll see errors like:

```
error: hash mismatch in fixed-output derivation
```

**To fix:**

1. First build will fail and show the correct `sha256` hash
2. Copy that hash and update line 15 in `modules/core/sysc-greet.nix`
3. Build again, it will fail showing the correct `vendorHash`
4. Copy that hash and update line 18 in `modules/core/sysc-greet.nix`
5. Rebuild and it should work!

Alternatively, you can use `lib.fakeHash` initially, then replace with real hashes:

```nix
sha256 = lib.fakeHash;
vendorHash = lib.fakeHash;
```

## Notes:

- When sysc-greet is enabled, it automatically disables greetd, ly, and sddm
- The module auto-detects your compositor (Hyprland, niri, or sway)
- Required dependencies (kitty, swww) are automatically installed
- A `greeter` user is created automatically

#!/usr/bin/env bash
# =============================================================================
# NixOS Portable Install Script
# Run from the flake root: ~/black-don-os
# Usage: ./install-portable.sh [target_mount] [flake_target]
# Example: ./install-portable.sh /mnt/nvme2 nixos-portable
# =============================================================================
set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────
TARGET="${1:-/mnt/nvme2}"
FLAKE_TARGET="${2:-nixos-portable}"
HOST_KEY="/tmp/${FLAKE_TARGET}-host-key"
SOPS_YAML=".sops.yaml"
SECRETS_DIR="secrets"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}==>${NC} ${BOLD}$*${NC}"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warn()    { echo -e "${YELLOW}⚠${NC}  $*"; }
die()     { echo -e "${RED}✗ ERROR:${NC} $*" >&2; exit 1; }
ask()     { echo -e "${BOLD}$*${NC}"; }

# ── Preflight checks ──────────────────────────────────────────────────────────
info "Preflight checks..."

[[ -f "flake.nix" ]] || die "Must be run from the flake root (flake.nix not found)"
mountpoint -q "$TARGET" || die "$TARGET is not mounted. Partition, format, and mount it first."

# Check required tools
for tool in ssh-keygen sops age-keygen git; do
  command -v "$tool" &>/dev/null || die "'$tool' not found. Add it to your shell environment."
done

# Check ssh-to-age is available
nix-shell -p ssh-to-age --run "ssh-to-age --help" &>/dev/null 2>&1 || \
  die "ssh-to-age unavailable via nix-shell"

success "All preflight checks passed"
echo

# ── Step 1: Host key ──────────────────────────────────────────────────────────
info "Step 1/6: SSH host key"

if [[ -f "$HOST_KEY" ]]; then
  warn "Host key already exists at $HOST_KEY"
  ask "Use existing key? [Y/n]"
  read -r REPLY
  if [[ "${REPLY,,}" == "n" ]]; then
    rm -f "$HOST_KEY" "$HOST_KEY.pub"
    ssh-keygen -t ed25519 -f "$HOST_KEY" -N "" -C "${FLAKE_TARGET}-host-key"
    success "Generated new host key at $HOST_KEY"
  else
    success "Using existing host key"
  fi
else
  ssh-keygen -t ed25519 -f "$HOST_KEY" -N "" -C "${FLAKE_TARGET}-host-key"
  success "Generated host key at $HOST_KEY"
fi

# Derive age public key from host key
AGE_PUBKEY=$(nix-shell -p ssh-to-age --run "cat ${HOST_KEY}.pub | ssh-to-age")
success "Age public key: ${AGE_PUBKEY}"
echo

# ── Step 2: .sops.yaml ────────────────────────────────────────────────────────
info "Step 2/6: .sops.yaml configuration"

if grep -q "$AGE_PUBKEY" "$SOPS_YAML" 2>/dev/null; then
  success "${FLAKE_TARGET} age key already present in .sops.yaml"
else
  warn "${FLAKE_TARGET} key NOT found in .sops.yaml"
  echo
  echo "  Add this to your .sops.yaml keys section:"
  echo
  echo "    - &${FLAKE_TARGET} ${AGE_PUBKEY}"
  echo
  echo "  And add '*${FLAKE_TARGET}' under every creation_rules age group."
  echo
  ask "Press ENTER once you've updated .sops.yaml, or Ctrl+C to abort..."
  read -r

  # Re-encrypt all secrets files
  info "Re-encrypting all secrets with updated keys..."
  for f in "$SECRETS_DIR"/*.yaml "$SECRETS_DIR"/*.json "$SECRETS_DIR"/*.env "$SECRETS_DIR"/*.ini; do
    [[ -f "$f" ]] || continue
    info "  sops updatekeys $f"
    sops updatekeys --yes "$f" || warn "  Failed to updatekeys on $f — check manually"
  done

  git add -A
  git commit -m "feat: add ${FLAKE_TARGET} sops age key and re-encrypt secrets" || \
    warn "Git commit failed (maybe nothing to commit)"
  success "Secrets re-encrypted and committed"
fi
echo

# ── Step 3: Passwords ─────────────────────────────────────────────────────────
info "Step 3/6: Password hashes"

SECRETS_FILE="$SECRETS_DIR/secrets.yaml"
[[ -f "$SECRETS_FILE" ]] || die "Secrets file not found at $SECRETS_FILE"

# Check if password keys already exist in secrets
if sops --decrypt "$SECRETS_FILE" 2>/dev/null | grep -q "passwords:"; then
  success "Password hashes already present in $SECRETS_FILE"
  warn "If you want to reset them, edit $SECRETS_FILE manually with: sops $SECRETS_FILE"
else
  echo
  warn "No password hashes found in $SECRETS_FILE"
  info "Generating password hashes (you will be prompted twice — once for user, once for root)"
  echo

  ask "Enter password for user 'kyle':"
  KYLE_HASH=$(mkpasswd -m yescrypt)

  ask "Enter password for root (or press ENTER to use same as kyle):"
  read -r -s ROOT_PW
  echo
  if [[ -z "$ROOT_PW" ]]; then
    ROOT_HASH="$KYLE_HASH"
    success "Using same hash for root"
  else
    ROOT_HASH=$(echo "$ROOT_PW" | mkpasswd -m yescrypt -s)
  fi

  # Inject into secrets file
  info "Writing hashes into $SECRETS_FILE..."
  TMPFILE=$(mktemp)
  sops --decrypt "$SECRETS_FILE" > "$TMPFILE"

  # Append passwords block if not present
  cat >> "$TMPFILE" <<EOF

passwords:
  kyle: "${KYLE_HASH}"
  root: "${ROOT_HASH}"
EOF

  sops --encrypt "$TMPFILE" > "$SECRETS_FILE"
  rm "$TMPFILE"

  git add "$SECRETS_FILE"
  git commit -m "feat: add declarative password hashes for ${FLAKE_TARGET}"
  success "Password hashes written and committed"
fi
echo

# ── Step 4: Place keys on target ──────────────────────────────────────────────
info "Step 4/6: Placing keys on target drive ($TARGET)"

# SSH host key (for openssh on the installed system)
sudo mkdir -p "$TARGET/etc/ssh"
sudo install -m 600 "$HOST_KEY"      "$TARGET/etc/ssh/ssh_host_ed25519_key"
sudo install -m 644 "$HOST_KEY.pub"  "$TARGET/etc/ssh/ssh_host_ed25519_key.pub"
sudo chown root:root "$TARGET/etc/ssh/ssh_host_ed25519_key"
sudo chown root:root "$TARGET/etc/ssh/ssh_host_ed25519_key.pub"
success "SSH host key placed at $TARGET/etc/ssh/"

# Also place in .rw-etc for system.etc.overlay.enable = true
sudo mkdir -p "$TARGET/.rw-etc/upper/ssh"
sudo install -m 600 "$HOST_KEY"      "$TARGET/.rw-etc/upper/ssh/ssh_host_ed25519_key"
sudo install -m 644 "$HOST_KEY.pub"  "$TARGET/.rw-etc/upper/ssh/ssh_host_ed25519_key.pub"
sudo chown root:root "$TARGET/.rw-etc/upper/ssh/ssh_host_ed25519_key"
sudo chown root:root "$TARGET/.rw-etc/upper/ssh/ssh_host_ed25519_key.pub"
success "SSH host key also placed at $TARGET/.rw-etc/upper/ssh/ (etc overlay)"

# Age key derived from SSH key (placed outside /etc so overlay remount doesn't break it)
AGE_PRIVKEY=$(nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ${HOST_KEY}")
sudo mkdir -p "$TARGET/var/lib/sops-nix"
echo "$AGE_PRIVKEY" | sudo tee "$TARGET/var/lib/sops-nix/key.txt" > /dev/null
sudo chmod 600 "$TARGET/var/lib/sops-nix/key.txt"
sudo chown root:root "$TARGET/var/lib/sops-nix/key.txt"
success "Age private key placed at $TARGET/var/lib/sops-nix/key.txt"
echo

# ── Step 5: nixos-install ─────────────────────────────────────────────────────
info "Step 5/6: Running nixos-install..."
echo

sudo nixos-install \
  --root "$TARGET" \
  --flake ".#${FLAKE_TARGET}" \
  --no-root-passwd \
  --no-channel-copy

echo
success "nixos-install completed"
echo

# ── Step 6: Summary ───────────────────────────────────────────────────────────
info "Step 6/6: Done!"
echo
echo -e "  ${BOLD}Target:${NC}       $TARGET"
echo -e "  ${BOLD}Flake host:${NC}   $FLAKE_TARGET"
echo -e "  ${BOLD}Host key:${NC}     $HOST_KEY"
echo -e "  ${BOLD}Age pubkey:${NC}   $AGE_PUBKEY"
echo
echo -e "  ${GREEN}Safe to reboot into $TARGET.${NC}"
echo -e "  Passwords are fully declarative — no manual ${BOLD}passwd${NC} needed."
echo
warn "Keep $HOST_KEY safe — you'll need it if you ever reinstall."
warn "Or re-run this script; it will reuse the existing key."

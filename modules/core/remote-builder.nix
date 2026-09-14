# nixos/shared/remote-builder.nix
#
# Import this on any machine that should be able to opt in to:
#   • Offloading builds to the desktop
#   • Pulling pre-built derivations from the desktop's nix-serve
#
# Prerequisites (run once per client, see README):
#   1. Tailscale up and routable to `nixos-desktop`
#   2. Desktop has this machine's host public key in nix-serve.nix
#   3. Root SSH known-hosts bootstrapped (see README)
{ ... }:

let
  # ── Adjust these two values ───────────────────────────────────────────────
  # Tailscale hostname of the desktop (or its stable TS IP, e.g. 100.x.y.z)
  buildHost = "nixos-desktop";

  # Public key that matches the private key in secrets/nix-serve.yaml.
  # After nix-serve first starts on the desktop, run:
  #   curl http://nixos-desktop:5000/nix-cache-info    ← sanity check
  #   cat /run/secrets/nix-serve/private-key | nix-store --query-signature
  # OR just read it from the .pub file you generated during setup (see README).
  cachePublicKey = "nixos-desktop-cache:QCxE9ysJzEpeRVi255uyCSEPrOkYY16jTG97I43zdJk=";
  # ─────────────────────────────────────────────────────────────────────────
in
{
  # ── Remote build configuration ────────────────────────────────────────────
  # SSH config so Nix can reach the builder when RBN is enabled in a shell.
  programs.ssh.extraConfig = ''
    Host ${buildHost}
      User            nix-ssh
      IdentityFile    /etc/ssh/ssh_host_ed25519_key
      # Accept the host key automatically on first connection;
      # after bootstrap you can tighten this to `yes`.
      StrictHostKeyChecking accept-new
  '';

  # ── Binary cache ──────────────────────────────────────────────────────────
  # Trust the desktop cache without enabling it by default. This permits an
  # unprivileged shell to opt in via RBN.
  nix.settings.trusted-substituters = [ "http://${buildHost}:5000" ];

  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    cachePublicKey
  ];
}

# nixos/shared/remote-builder.nix
#
# Import this on any machine that should:
#   • Offload builds to the desktop
#   • Pull pre-built derivations from the desktop's nix-serve
#
# Prerequisites (run once per client, see README):
#   1. Tailscale up and routable to `nixos-desktop`
#   2. Desktop has this machine's host public key in nix-serve.nix
#   3. Root SSH known-hosts bootstrapped (see README)
{ config, lib, pkgs, ... }:

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
  nix.distributedBuilds = true;

  nix.buildMachines = [{
    hostName = buildHost;
    protocol = "ssh-ng";

    # Authenticate using this machine's SSH host key (no extra key management)
    sshUser  = "nix-ssh";
    sshKey   = "/etc/ssh/ssh_host_ed25519_key";

    # Adjust to the desktop's actual architecture
    systems  = [ "x86_64-linux" "aarch64-linux" ];

    # How many parallel Nix jobs the desktop will accept from this client
    maxJobs     = 4;
    speedFactor = 4;   # prefer desktop over localhost for heavy builds

    supportedFeatures = [
      "nixos-test"
      "benchmark"
      "big-parallel"
      "kvm"
    ];
  }];

  # SSH config so the Nix daemon (running as root) can reach the builder
  programs.ssh.extraConfig = ''
    Host ${buildHost}
      User            nix-ssh
      IdentityFile    /etc/ssh/ssh_host_ed25519_key
      # Accept the host key automatically on first connection;
      # after bootstrap you can tighten this to `yes`.
      StrictHostKeyChecking accept-new
  '';

  # ── Binary cache ──────────────────────────────────────────────────────────
  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "http://${buildHost}:5000"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      cachePublicKey
    ];

    # Fetch from the cache before falling back to building
    builders-use-substitutes = true;
  };
}

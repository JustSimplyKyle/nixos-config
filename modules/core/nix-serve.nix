# nixos/hosts/desktop/nix-serve.nix
#
# Turns the desktop into:
#   1. A self-hosted Nix binary cache  (nix-serve on :5000)
#   2. A remote build machine          (SSH + trusted nix daemon)
#
# Both services are firewalled to the Tailscale interface only.
# Import this file from your desktop's configuration.nix.
{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  # ── Secrets ──────────────────────────────────────────────────────────────
  # The signing key lives encrypted in secrets/nix-serve.yaml.
  # See secrets/nix-serve.yaml and the README for how to generate & encrypt it.
  sops.secrets."nix-serve/private-key" = {
    owner = "nix-serve"; # works because we declare the user below
    restartUnits = [ "nix-serve.service" ];
  };

  # ── nix-serve user / group (declared explicitly) ──────────────────────────
  # services.nix-serve uses DynamicUser = true by default, which means the
  # user never appears in config.users.users and sops-nix fails at eval time
  # with "attribute 'nix-serve' missing".
  # Solution: declare a real system user and disable DynamicUser.
  users.users.nix-serve = {
    isSystemUser = true;
    group = "nix-serve";
    description = "nix-serve binary cache daemon";
  };
  users.groups.nix-serve = { };

  systemd.services.nix-serve.serviceConfig.DynamicUser = lib.mkForce false;

  # ── Binary cache (nix-serve) ──────────────────────────────────────────────
  services.nix-serve = {
    enable = true;
    package = pkgs.nix-serve-ng;
    secretKeyFile = config.sops.secrets."nix-serve/private-key".path;
    port = 5000;
    bindAddress = "0.0.0.0"; # firewall below restricts to tailscale0
    openFirewall = false;
  };

  # ── Remote build user ─────────────────────────────────────────────────────
  # Client Nix daemons SSH in as `nix-ssh` to submit builds.
  # Add each client's SSH *host* public key here.
  # Retrieve from a client with: cat /etc/ssh/ssh_host_ed25519_key.pub
  users.users.nix-ssh = {
    isSystemUser = true;
    group = "nix-ssh";
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMSM+xdHn2QGOB0W1l4j5uRmi/9rTxIBDKPbZXPz5Pm nixos-portable-host-key"
      # "ssh-ed25519 AAAA... nixos-portable"
      # "ssh-ed25519 AAAA... any-other-client"
    ];
  };
  users.groups.nix-ssh = { };

  # Trust the nix-ssh user so it can use the local Nix daemon
  nix.settings.trusted-users = [
    "root"
    "nix-ssh"
    "@wheel"
    "${username}"
  ];

  # ── SSH daemon ────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    openFirewall = false; # restricted to tailscale0 below
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # ── Firewall: Tailscale only ──────────────────────────────────────────────
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    22 # SSH  — remote build submissions
    5000 # HTTP — nix-serve binary cache
  ];
}

{
  pkgs,
  inputs,
  username,
  host,
  profile,
  config,
  nixpkgs-stable,
  ...
}:
let
  variables = import ../../hosts/${host}/variables.nix;
  inherit (variables) gitUsername;
  defaultShell = variables.defaultShell or "zsh";
  shellPackage = if defaultShell == "fish" then pkgs.fish else pkgs.zsh;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  # Enable Fish and Zsh system-wide for vendor completions
  programs.fish.enable = true;
  programs.zsh.enable = true;

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit
        inputs
        username
        host
        profile
        ;
    };
    users.${username} = {
      imports = [ ./../home ];
      home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
        stateVersion = "23.11";
      };
    };
  };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets = {
    "passwords/${username}" = {
      sopsFile = ../../secrets/passwords.yaml;
      neededForUsers = true;
    };
    "passwords/root" = {
      sopsFile = ../../secrets/passwords.yaml;
      neededForUsers = true;
    };
  };

  users.mutableUsers = false;

  users.users.${username} = {
    isNormalUser = true;
    description = "${gitUsername}";
    extraGroups = [
      "adbusers"
      "docker"
      "libvirtd" # For VirtManager
      "lp"
      "networkmanager"
      "scanner"
      "wheel" # sudo access
      "vboxusers" # For VirtualBox
      "dialout" # usb writing
    ];
    # Use configured shell based on defaultShell variable
    shell = shellPackage;
    ignoreShellProgramCheck = true;
    hashedPasswordFile = config.sops.secrets."passwords/${username}".path;
  };

  users.users.root = {
    hashedPasswordFile = config.sops.secrets."passwords/root".path;
  };

  nix.settings.allowed-users = [ "${username}" ];
  nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
  nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
}

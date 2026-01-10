{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.direnv-instant.homeModules.direnv-instant
  ];

  programs.direnv-instant.enable = true;
  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };
  };
}

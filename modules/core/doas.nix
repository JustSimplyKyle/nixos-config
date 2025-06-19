{
  security.doas.enable = true;

  security.doas.extraRules = [
    {
      users = ["adminUser"]; # Replace with your username
      keepEnv = true; # Retains environment variables
      noPass = true;
    }
    {
      groups = ["wheel"]; # Allows all users in 'wheel' group
      noPass = true; # Enables passwordless execution
    }
  ];
}

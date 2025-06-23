{
  security.doas.enable = true;

  security.doas.extraRules = [
    {
      users = ["adminUser"]; # Replace with your username
      keepEnv = true; # Retains environment variables
      noPass = false;
    }
    {
      groups = ["wheel"]; # Allows all users in 'wheel' group
      noPass = false; # Enables passwordless execution
    }
  ];
}

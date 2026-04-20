{ pkgs, ... } : {
  
  services.sunshine = {
    enable = true;
    autoStart = true;  # optional: starts Sunshine automatically on login
    capSysAdmin = true;
    openFirewall = true;
  };
}

{ config, ... }: {

  programs.ssh = {
    enable = true;
    
    enableDefaultConfig = false;

    matchBlocks = {
      opc = {
        hostname = "100.117.138.27";
        user = "opc";
        identityFile = "/run/secrets/opc-ssh";
        
        extraOptions = {
          RequestTTY = "yes";
          RemoteCommand = "TERM=xterm-256color /usr/bin/bash -l";
        };
      };

      remarkable = {
        hostname = "10.11.99.1";
        user = "root";
      };
    };
  };

}

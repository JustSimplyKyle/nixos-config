{ config, ... }: {

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host opc
        HostName 100.117.138.27
        User opc
        IdentityFile /run/secrets/opc-ssh
        RequestTTY yes
        RemoteCommand TERM=xterm-256color /usr/bin/bash -l
    '';
  };
}

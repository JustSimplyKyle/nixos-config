{pkgs, ...}: {
  home.packages = with pkgs; [
    # Additional VM management tools
    spice-gtk # Better VM display performance
    virtio-win # Windows guest drivers (for testing Windows)
  ];

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };

    # Virt-manager preferences for better distro testing
    "org/virt-manager/virt-manager" = {
      xmleditor-enabled = true; # Enable XML editing for advanced configs
      stats-update-interval = 1; # Update stats every second
      console-accels = true; # Enable console accelerators
    };

    # VM viewer settings for better performance
    "org/virt-manager/virt-manager/console" = {
      resize-guest = 1; # Automatically resize guest display
      scaling = 1; # Scale to fit window
    };

    # Default VM settings optimized for distro testing
    "org/virt-manager/virt-manager/new-vm" = {
      graphics-type = "spice"; # Use SPICE for better performance
      cpu-default = "host-passthrough"; # Better CPU performance
      storage-format = "qcow2"; # Efficient disk format with snapshots
    };

    # Console settings
    "org/virt-manager/virt-manager/urls" = {
      isos = ["/var/lib/libvirt/isos"]; # Default ISO location
    };
  };
}

{...}: {
  services.auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
           governor = "powersave";
           # default performance balance_performance balance_power power
           energy_performance_preference = "balance_power";
           turbo = "auto";
           # low-power balanced performance
           platform_profile = "low-power";
        };
        charger = {
           governor = "performance";
           energy_performance_preference = "power";
           turbo = "auto";
           platform_profile = "performance";
        };
      };
  };
}

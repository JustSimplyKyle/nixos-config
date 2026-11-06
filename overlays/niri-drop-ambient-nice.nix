final: prev: {
  # niri runs through a cap_sys_nice wrapper (hosts/nixos-portable) for a high-priority GPU context.
  # The wrapper makes the capability ambient, so every app niri launches inherits it, which breaks
  # bwrap (Steam, Flatpak). Drop it from the ambient set at startup, like kwin_wayland does.
  # If this fails to build after an update, the anchor line in src/main.rs changed upstream.
  niri = prev.niri.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/main.rs --replace-fail \
        'fn main() -> Result<(), Box<dyn std::error::Error>> {' \
        'fn main() -> Result<(), Box<dyn std::error::Error>> {
          // 47 = PR_CAP_AMBIENT, 3 = PR_CAP_AMBIENT_LOWER, 23 = CAP_SYS_NICE
          unsafe { libc::prctl(47, 3 as libc::c_ulong, 23 as libc::c_ulong, 0 as libc::c_ulong, 0 as libc::c_ulong) };'
    '';
  });
}

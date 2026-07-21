final: prev: {
  jellarr = prev.jellarr.override {
    pkgs = final // {
      pnpm = prev.pnpm_10;

      fetchPnpmDeps =
        args:
        prev.fetchPnpmDeps (
          args
          // {
            pnpm = prev.pnpm_10;
          }
        );
    };
  };
}

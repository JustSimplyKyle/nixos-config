_final: prev:
let
  pnpm = prev.pnpm_10;
in
{
  inherit pnpm;

  fetchPnpmDeps =
    args:
    prev.fetchPnpmDeps (
      args
      // {
        inherit pnpm;
      }
      // prev.lib.optionalAttrs ((args.pname or null) == "jellarr") {
        hash = "sha256-mGxHtQa2UOft4HkI0EE2WmtkgzIqY8dDl5MlC79nhVE=";
      }
    );
}

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
        hash = "sha256-DA4PFpH+CZRHtreOlRHz0S3/93LdqlHVvsUyw9WAwII=";
      }
    );
}

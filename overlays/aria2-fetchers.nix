final: prev:
let
  # aria2 and its dependencies must not use the fetcher they are bootstrapping.
  bootstrap = import prev.path {
    system = prev.stdenv.buildPlatform.system;
    overlays = [ ];
  };
  originalBuilder = prev.path + "/pkgs/build-support/fetchurl/builder.sh";
  originalText = builtins.readFile originalBuilder;
  marker = "    local curlexit=18;";
  builder = builtins.toFile "fetchurl-aria2-builder.sh" (
    assert prev.lib.hasInfix marker originalText;
    builtins.replaceStrings
      [ marker ]
      [
        ((builtins.readFile ../pkgs/aria2-nix-proxy/fetchurl-download.sh) + "\n" + marker)
      ]
      originalText
  );
  aria2Stdenv = prev.stdenvNoCC // {
    mkDerivation = prev.lib.extendMkDerivation {
      constructDrv = prev.stdenvNoCC.mkDerivation;
      extendDrvArgs = _: args: {
        builder = if args.builder == originalBuilder then builder else args.builder;
        nativeBuildInputs = (args.nativeBuildInputs or [ ]) ++ [ bootstrap.aria2 ];
      };
    };
  };
in
{
  fetchurl = prev.fetchurl.override { stdenvNoCC = aria2Stdenv; };
  fetchzip = prev.fetchzip.override { fetchurl = final.fetchurl; };
}

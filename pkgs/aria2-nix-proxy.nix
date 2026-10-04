{
  lib,
  stdenvNoCC,
  python3,
  aria2,
  makeWrapper,
}:
stdenvNoCC.mkDerivation {
  pname = "aria2-nix-proxy";
  version = "0.1.0";
  src = ./aria2-nix-proxy;
  nativeBuildInputs = [ makeWrapper ];
  dontBuild = true;
  doCheck = true;
  nativeCheckInputs = [
    python3
    aria2
  ];
  checkPhase = ''
    runHook preCheck
    python3 -m unittest discover -s tests -v
    runHook postCheck
  '';
  installPhase = ''
    runHook preInstall
    install -Dm644 proxy.py "$out/lib/aria2-nix-proxy/proxy.py"
    install -Dm644 README.md "$out/share/doc/aria2-nix-proxy/README.md"
    makeWrapper ${python3}/bin/python3 "$out/bin/aria2-nix-proxy" \
      --add-flags "$out/lib/aria2-nix-proxy/proxy.py" \
      --set ARIA2_NIX_PROXY_ARIA2 ${aria2}/bin/aria2c
    runHook postInstall
  '';
  meta = {
    description = "Local Nix binary-cache proxy with parallel aria2 NAR downloads";
    mainProgram = "aria2-nix-proxy";
    platforms = lib.platforms.unix;
  };
}

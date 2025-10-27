{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  gobject-introspection,
  wrapGAppsHook,
  glib,
  gdk-pixbuf,
  gtk3,
  xapp,
  dconf,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "webapp-manager";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "webapp-manager";
    rev = version;
    sha256 = "sha256-aYamk1DIo2nRx4IWZY23sA3Icp3AXfzi2pKrrTPxx8M=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook
    makeWrapper
  ];

  buildInputs = [
    glib
    gdk-pixbuf
    gtk3
    xapp
    dconf
    (python3.withPackages (
      ps: with ps; [
        beautifulsoup4
        configobj
        pygobject3
        pillow
        setproctitle
        tldextract
      ]
    ))
  ];

  prePatch = ''
    substituteInPlace usr/lib/webapp-manager/webapp-manager.py \
      --replace '__DEB_VERSION__' '${version}'
  '';

  makeFlags = [
    "prefix=$(out)"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/* $out/
    cp -r etc $out/

    # Fix the binary wrapper
    mkdir -p $out/bin
    makeWrapper ${python3}/bin/python3 $out/bin/webapp-manager \
      --add-flags "$out/lib/webapp-manager/webapp-manager.py" \
      --prefix PYTHONPATH : "$PYTHONPATH" \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Run websites as if they were apps";
    longDescription = ''
      Web App Manager allows you to run websites as if they were apps.
      It supports running in different browsers, and having multiple instances
      of the same site as different apps.
    '';
    homepage = "https://github.com/linuxmint/webapp-manager";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}

final: prev: {
  manrope = prev.stdenvNoCC.mkDerivation rec {
    pname = "otf-manrope";
    version = "4.5";

    src = prev.fetchurl {
      url = "https://www.shimmer.cloud/assets/manrope/manrope.zip";
      sha256 = "sha256-M/mVhc0nyFiScfZ5CoJefIMtHGV+FChy30PDpNgmBuA=";
    };

    nativeBuildInputs = [ prev.unzip ];

    sourceRoot = "."; 

    installPhase = ''
      runHook preInstall

      # Create the fonts directory
      install -d $out/share/fonts/opentype

      # 1. Use `find` to locate any OTF files, case-insensitively, anywhere inside the zip.
      # This completely bypasses folder structure/casing issues.
      find . -type f -iname "*.otf" -exec install -m644 {} $out/share/fonts/opentype/ \;

      # 2. Safety check: Abort if `find` couldn't locate any fonts
      if [ -z "$(ls -A $out/share/fonts/opentype/)" ]; then
        echo "Error: No .otf files were found inside the zip!"
        exit 1
      fi

      # 3. Handle the license file (if it exists within the zip)
      find . -type f -iname "ofl.txt" -exec install -Dm644 {} $out/share/licenses/${pname}/LICENCE \;

      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "Manrope font – modern geometric sans-serif";
      homepage = "https://www.shimmer.cloud/manrope";
      license = licenses.ofl;
      platforms = platforms.all;
    };
  };
}

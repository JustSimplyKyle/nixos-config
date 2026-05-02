final: prev: {
  instrument-sans = prev.stdenvNoCC.mkDerivation rec {
    pname = "instrument-sans";
    version = "2024-03-20";

    src = prev.fetchFromGitHub {
      owner = "Instrument";
      repo = "instrument-sans";
      rev = "master"; 
      hash = "sha256-F68VaS0baIo/NjhCiUU/zhchWIysgohaySqADYSemx0="; # Update this!
    };

    installPhase = ''
      runHook preInstall

      # Install only the Variable TTF files
      install -d $out/share/fonts/truetype
      find fonts/variable -type f -iname "*.ttf" -exec install -m644 {} $out/share/fonts/truetype/ \;

      # Safety check
      if [ -z "$(ls -A $out/share/fonts/truetype/)" ]; then
        echo "Error: No variable TTF files found!"
        exit 1
      fi

      install -Dm644 OFL.txt $out/share/licenses/${pname}/LICENSE
      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "Instrument Sans – Variable Font version";
      homepage = "https://github.com/Instrument/instrument-sans";
      license = licenses.ofl;
      platforms = platforms.all;
    };
  };
}

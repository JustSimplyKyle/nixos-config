final: prev: {
  instrument-sans = prev.stdenvNoCC.mkDerivation rec {
    pname = "open-huninn";
    version = "2024-09-19";

    src = prev.fetchFromGitHub {
      owner = "justfont";
      repo = "open-huninn-font";
      rev = "98d53b3dac1730889edf548359c326c53624fa80";
      hash = "sha256-F68VaS0baIo/NjhCiUU/zhchWIysgohaySqADYSemx0="; # Update this!
    };

    installPhase = ''
      runHook preInstall

      # Install only the Variable TTF files
      install -d $out/share/fonts/truetype
      install -m644 font/jf-openhuninn-2.1.tff $out/share/fonts/truetype

      install -Dm644 LICENSE $out/share/licenses/${pname}/LICENSE
      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "jf open-huninn (jf open 粉圓) is an Open-Source Traditional Chinese Rounded Typeface specially designed for better use in Taiwan.";
      homepage = "https://github.com/Instrument/instrument-sans";
      license = licenses.ofl;
      platforms = platforms.all;
    };
  };
}

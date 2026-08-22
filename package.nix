{
  lib,
  stdenv,
  fetchurl,
}:
let
  sources = builtins.fromJSON (builtins.readFile ./sources.json);
  platform =
    sources.platforms.${stdenv.hostPlatform.system}
      or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "herdr";
  version = sources.version;

  src = fetchurl {
    url = platform.url;
    hash = platform.hash;
  };

  dontUnpack = true;

  # The Linux artifacts are static PIE binaries (no PT_INTERP), so nothing has
  # to be patched; keeping them byte-identical also preserves the macOS
  # signature on the Mach-O builds.
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -m755 -D $src $out/bin/herdr
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    HOME="$TMPDIR" $out/bin/herdr --version | grep -q "${sources.version}"
    runHook postInstallCheck
  '';

  meta = {
    description = "Terminal multiplexer built for AI coding agents";
    homepage = "https://herdr.dev";
    changelog = "https://github.com/herdrdev/herdr/releases/tag/v${sources.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "herdr";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}

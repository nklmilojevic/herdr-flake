{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.herdr;
in
{
  options.programs.herdr = {
    enable = lib.mkEnableOption "herdr - terminal multiplexer for AI coding agents";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ./package.nix { }";
      description = "The herdr package to use.";
    };

    enableBinSymlink = lib.mkOption {
      type = lib.types.bool;
      default = pkgs.stdenv.isLinux;
      description = ''
        Whether to create a symlink at ~/.local/bin/herdr.
        Enabled by default on Linux to ensure the binary is in a standard location.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.file.".local/bin/herdr" = lib.mkIf cfg.enableBinSymlink {
      source = "${cfg.package}/bin/herdr";
    };
  };
}

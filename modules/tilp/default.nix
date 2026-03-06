{ pkgs, lib, config, ... }: {
    options = {
        tilp.enable = lib.mkEnableOption "Enables tilp";
    };
    config = lib.mkIf config.tilp.enable {
        environment.systemPackages = [
            (pkgs.callPackage ./package.nix {})
        ];
    };
}

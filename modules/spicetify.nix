{ pkgs, lib, inputs, config, ...}: {
    options = {
        spicetify.enable = lib.mkEnableOption "Enables spicetify";
    };
    imports = [
        inputs.spicetify-nix.nixosModules.default
    ];
    config = lib.mkIf config.spicetify.enable {
        programs.spicetify =
        let
            spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
        in
        {
            enable = true;
            enabledExtensions = with spicePkgs.extensions; [
                adblock
                hidePodcasts
                shuffle
            ];
            enabledCustomApps = with spicePkgs.apps; [
                newReleases
            ];
            enabledSnippets = with spicePkgs.snippets; [
                pointer
            ];
        };
    };
}

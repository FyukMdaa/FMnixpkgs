{
  description = "FyukMdaa's personal package collection";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      # パッケージ単体としての提供
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true; # ローカルパッケージビルド用
          };
        in
        {
          beutl = pkgs.callPackage ./packages/beutl/default.nix { };
          sfmono-square = pkgs.callPackage ./packages/sfmono-square/default.nix { inherit inputs; };
          keyroost = pkgs.callPackage ./packages/keyroost/default.nix { };
        }
      );

      # Overlayの定義
      overlays.default = final: prev: {
        beutl = final.callPackage ./packages/beutl/default.nix { };
        sfmono-square = final.callPackage ./packages/sfmono-square/default.nix { inherit inputs; };
        keyroost = final.callPackage ./packages/keyroost/default.nix { };
      };
    };
}

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
          beutl = pkgs.callPackage ./packages/beutl/beutl.nix { inherit inputs; };
          sfmono-square = pkgs.callPackage ./packages/sfmono-square/sfmono-square.nix { inherit inputs; };
        }
      );

      # Overlayの定義
      overlays.default = final: prev: {
        local = {
          beutl = final.callPackage ./packages/beutl/beutl.nix { inherit inputs; };
          sfmono-square = final.callPackage ./packages/sfmono-square/sfmono-square.nix { inherit inputs; };
        };
      };
    };
}

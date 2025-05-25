{
  description = "Flake configuration for my systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, utils, rust-overlay, ... }:
    utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; overlays = [ (import rust-overlay) ]; };
      in {
        devShells.default = pkgs.mkShell {
          {% case flash_method -%}
  {%- when "probe-rs" -%}
          propagatedBuildInputs = [ pkgs.probe-rs ];
  {%- when "picotool" -%}
          propagatedBuildInputs = [ pkgs.picotool ];
  {%- when "none" -%}
  {%- else -%}
{%- endcase %}

          buildInputs = [
            (pkgs.rust-bin.stable.latest.default.override {
              extensions = [
                "rust-src"
                "clippy"
                "rust-analyzer"
              ];
              targets = [
                "thumbv8m.main-none-eabihf"
              ];
            })
          ];
        };
      });
}

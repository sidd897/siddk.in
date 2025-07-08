{
  description = "Personal portfolio website development using Hugo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells = rec {
          default = pkgs.mkShell {
            packages = [ pkgs.hugo ];
          };
        };
        packages = {
          hugo-build = pkgs.writeShellScriptBin "hugo-build" ''
            echo -e "\e[1;32mdeleting 'public' directory if it exists\e[0m"
            if [ -d "src/public" ]; then
              echo "Directory exists. Deleting it..."
              rm -rI src/public
            else
              echo "Directory does not exist."
            fi
            ${pkgs.hugo}/bin/hugo --source src/
            echo -e "\e[1;32mconverting 404.html to 404.shtml\e[0m"
            mv src/public/404.html src/public/404.shtml
            echo -e "\e[1;32muploading to godaddy server\e[0m"
            ${pkgs.rsync}/bin/rsync -avz --delete src/public sidd897@184.168.106.13:~/public_html
          '';

        };
      }
    );
}

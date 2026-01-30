{
  description = "YouGile MCP Server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python3; # Uses the default Python 3 in nixpkgs

        # Define the package
        yougile-mcp = python.pkgs.buildPythonApplication {
          pname = "yougile-mcp";
          version = "1.0.0";
          src = pkgs.lib.cleanSourceWith {
            src = ./.;
            filter =
              path: type:
              let
                baseName = baseNameOf path;
                # relative path from the root of the source
                relPath = pkgs.lib.removePrefix (toString ./.) (toString path);
              in
              (pkgs.lib.hasPrefix "/src" relPath) || (baseName == "pyproject.toml") || (baseName == "README.md");
          };
          format = "pyproject";

          nativeBuildInputs = [
            python.pkgs.setuptools
          ];

          propagatedBuildInputs = with python.pkgs; [
            mcp
            httpx
            pydantic
            pydantic-settings
            python-dotenv
            typer
          ];

          # Skip tests as none are defined yet
          doCheck = false;
        };
      in
      {
        packages.default = yougile-mcp;
        packages.yougile-mcp = yougile-mcp;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            (python.withPackages (
              ps: with ps; [
                mcp
                httpx
                pydantic
                pydantic-settings
                python-dotenv
                typer
                setuptools
                pip
                pytest
                ruff
                pyright
              ]
            ))
          ];

          shellHook = ''
            export PYTHONPATH="$PWD/src:$PYTHONPATH"
            echo "--- YouGile MCP Development Shell ---"
            echo "Python $(python --version)"
            echo "PYTHONPATH set to include ./src"
            echo ""
            echo "Available commands:"
            echo "  yougile-mcp          - Run the installed server"
            echo "  python -m yougile_mcp.server - Run the server module"
            echo "------------------------------------"
          '';
        };
      }
    );
}

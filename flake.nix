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
          src = ./.;
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
            echo "--- YouGile MCP Development Shell ---"
            echo "Python $(python --version)"
            echo ""
            echo "DEVELOPMENT HINT:"
            echo "The 'src' directory is in your current path. To use it as an 'editable' install,"
            echo "simply ensure it's in your PYTHONPATH:"
            echo "  export PYTHONPATH=\$PWD:\$PYTHONPATH"
            echo ""
            echo "Available commands:"
            echo "  yougile-mcp          - Run the installed server"
            echo "  python run_server.py - Run the server via wrapper"
            echo "------------------------------------"
          '';
        };
      }
    );
}

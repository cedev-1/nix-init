#!/bin/bash

# nix-init: Initialize Nix Flake + Direnv environment

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FLAKE_TEMPLATE='{
  description = "Flake template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ] (system: function nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            hello
            git
            # Add other packages you need here
          ];

          shellHook = ''
            echo "[✔] OK"
          '';
        };
      });
    };
}'

echo -e "${GREEN}Initializing Nix Flake + Direnv environment...${NC}"

if [ -f "flake.nix" ]; then
    echo -e "${YELLOW}flake.nix already exists. Skipped.${NC}"
else
    echo "$FLAKE_TEMPLATE" > flake.nix
    echo -e "${GREEN}✔ flake.nix created${NC}"
fi

if [ -f ".envrc" ]; then
    if ! grep -q "use flake" .envrc; then
        echo "use flake" >> .envrc
        echo -e "${GREEN}✔ 'use flake' added to .envrc${NC}"
    else
        echo -e "${YELLOW}'use flake' already in .envrc. Skipped.${NC}"
    fi
else
    echo "use flake" > .envrc
    echo -e "${GREEN}✔ .envrc created with 'use flake'${NC}"
fi

if [ -f ".gitignore" ]; then
    if ! grep -q "^\.direnv$" .gitignore; then
        echo ".direnv" >> .gitignore
        echo -e "${GREEN}✔ .direnv added to .gitignore${NC}"
    else
        echo -e "${YELLOW}.direnv already in .gitignore. Skipped.${NC}"
    fi
else
    echo ".direnv" > .gitignore
    echo -e "${GREEN}✔ .gitignore created with .direnv${NC}"
fi

if command -v direnv >/dev/null 2>&1; then
    echo -e "${YELLOW}Running direnv allow...${NC}"
    if direnv allow 2>/dev/null; then
        echo -e "${GREEN}✔ direnv allowed${NC}"
    else
        echo -e "${RED}✗ 'direnv allow' failed (maybe not in a git directory?)${NC}"
    fi
else
    echo -e "${YELLOW}direnv is not installed, consider installing it for automation.${NC}"
fi

echo -e "${GREEN}✓ Nix environment initialized!${NC}"
echo -e "${YELLOW}Run 'direnv allow' to activate the environment (if not done automatically).${NC}"
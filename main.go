package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

const flakeTemplate = `{
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
}
`

func main() {
	if _, err := os.Stat("flake.nix"); err == nil {
		fmt.Println("flake.nix already exists. Skipped.")
	} else {
		err := os.WriteFile("flake.nix", []byte(flakeTemplate), 0644)
		if err != nil {
			fmt.Printf("✗ Error creating flake.nix: %v\n", err)
			os.Exit(1)
		}
		fmt.Println("✔ flake.nix created")
	}

	f, err := os.OpenFile(".envrc", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		fmt.Printf("✗ Error opening .envrc: %v\n", err)
	}
	defer f.Close()

	content, _ := os.ReadFile(".envrc")
	if !strings.Contains(string(content), "use flake") {
		if _, err := f.WriteString("use flake\n"); err == nil {
			fmt.Println("✔ 'use flake' added to .envrc")
		}
	}

	g, err := os.OpenFile(".gitignore", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err == nil {
		defer g.Close()
		gContent, _ := os.ReadFile(".gitignore")
		if !strings.Contains(string(gContent), ".direnv") {
			g.WriteString(".direnv\n")
			fmt.Println("✔ .direnv added to .gitignore")
		}
	}

	if _, err := exec.LookPath("direnv"); err == nil {
		cmd := exec.Command("direnv", "allow")
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		fmt.Println("Running direnv allow...")
		if err := cmd.Run(); err != nil {
			fmt.Println("✗ 'direnv allow' failed (maybe not in a git directory?)")
		} else {
			fmt.Println("✔ direnv allowed")
		}
	} else {
		fmt.Println("direnv is not installed, consider installing it for automation.")
	}
}
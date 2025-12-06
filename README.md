# nix-init

**Zero-boilerplate Nix development environments.**

`nix-init` is a tiny CLI tool designed to bootstrap a **Nix Flake + Direnv** configuration in your current project folder instantly. Stop copy-pasting the same `flake.nix` over and over again.

## Quick Start

Go to your project directory and run:

    nix run github:cedev-1/nix-init


Done! Your environment is ready.

**What does it generate?**

When you run nix-init, it creates the following structure:

- **flake.nix**: A standard flake with a devShell containing git and hello (as a test). It uses a helper function to support multiple architectures automatically.
- **.envrc**: Contains use flake to hook into direnv.
- **.gitignore**: Appends .direnv to keep your git repo clean.

Use `direnv allow` to activate the environment (if you have direnv installed).

License

MIT

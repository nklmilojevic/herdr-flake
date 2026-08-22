# herdr Nix Flake

A Nix flake that packages [herdr](https://herdr.dev), a terminal multiplexer built
for AI coding agents.

## Features

- Pre-built binaries from official GitHub releases — no Rust compile
- Multi-platform support: Linux (x86_64, aarch64) and macOS (x86_64, aarch64)
- Automatic hourly updates via GitHub Actions
- Only tracks stable releases (upstream also publishes `preview-*` prereleases)
- Home Manager module support

## Why not the upstream flake?

`github:herdrdev/herdr` builds herdr from source with its own pinned nixpkgs and
`rust-overlay`, and its CI only runs `nix flake check` — nothing is ever pushed to
a binary cache, so every version bump costs a full local Rust build. This flake
wraps the official release artifact instead.

The Linux artifacts are static PIE binaries, so no interpreter patching is needed.

## Usage

### Run directly

```bash
nix run github:nklmilojevic/herdr-flake -- --version
```

### Install with nix profile

```bash
nix profile install github:nklmilojevic/herdr-flake
```

### Use the overlay

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    herdr.url = "github:nklmilojevic/herdr-flake";
  };

  outputs = { nixpkgs, herdr, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ herdr.overlays.default ];
          environment.systemPackages = [ pkgs.herdr ];
        })
      ];
    };
  };
}
```

### Home Manager module

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    herdr.url = "github:nklmilojevic/herdr-flake";
  };

  outputs = { nixpkgs, home-manager, herdr, ... }: {
    homeConfigurations.myuser = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        herdr.homeManagerModules.default
        {
          programs.herdr.enable = true;
        }
      ];
    };
  };
}
```

## Version Updates

This flake is automatically updated hourly via GitHub Actions. The workflow:

1. Checks GitHub releases for new stable versions
2. Downloads binaries for all platforms
3. Computes SHA256 hashes
4. Updates `sources.json` and commits

Current version is tracked in [sources.json](./sources.json).

## Manual Update

To manually trigger an update:

1. Go to Actions > "Update herdr version" > "Run workflow"
2. Or run locally: `bash update.sh`

## Development

Enter the dev shell:

```bash
cd dev && nix develop
```

## License

The Nix code in this repository is provided under the MIT license.
herdr itself is licensed under the [Apache License 2.0](https://github.com/herdrdev/herdr/blob/master/LICENSE).

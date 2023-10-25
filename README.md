# Element Development Environments

A series of per-project development environments, implemented via [Nix
Flakes](https://zero-to-nix.com/concepts/flakes) and
[devenv](https://devenv.sh/).

Supported systems: Linux, MacOS (darwin) and Windows (via WSL2) each on x86 and
ARM64.

## What is a "development environment"?

This repository contains "development environments" for a number of projects
that are relevant to Element, the company.

A development environment is a shell with all native and language dependencies
pre-installed. You may also find that running `devenv up` starts a local
instance of the project, along with any necessary helper processes (i.e.
postgres).

## Usage

The developer environments in this repository can be used in two ways:

* Run `nix develop` in your shell to immediately drop into one (or more)
  of the defined development environments.
* Reference the development shells as an input in your own nix flake.

See the [project-flakes](./project-flakes) directory to see what projects
are currently supported (contributions welcome!).

### Development shell

Say you want to load up a development environment for
[Synapse](https://github.com/matrix-org/synapse). Before you start, make sure
you have the [nix](https://nixos.org/download) package manager installed and
have both the `nix-command` and `flakes` experimental features enabled (tl;dr
install nix via [this
installer](https://github.com/DeterminateSystems/nix-installer?tab=readme-ov-file#the-determinate-nix-installer))

Then at the root of your local Synapse checkout, run the following command:

```shell
nix develop impure github:vector-im/nix-flakes#synapse
```

Dependencies will be downloaded and installed for you, and you'll be dropped
into a new shell with everything installed. You can then run:

```shell
devenv up
```

to start a local instance of Synapse, along with a PostgreSQL and Redis already
configured.

#### Automating the process

If typing `nix develop --impure ...` gets tiring, you can automatically enter
the desired project development environment by installing `direnv` and creating
a `.envrc` file with the following contents:

```
use flake --impure github:vector-im/nix-flakes#synapse
```

Place that file at the root of your Synapse checkout, and run `direnv allow`.
Now whenever you `cd` into that directory, the developer environment will be
activated automatically!

Hint: you can actually add multiple `use flake --impure ...` lines to your
`.envrc` to *combine* development environments, thus building one shell
with the dependencies of multiple projects available in it.

### Referencing in a downstream flake

As an alternative to telling your users to write out
`github:vector-im/nix-flakes#synapse`, you can create your own nix flake
(`flake.nix` file) that references it instead. Then, you need only do `nix
develop --impure` in your project's directory; which by default looks for a
flake at `./flake.nix`.

Downstream projects will find it easiest to use the `composeShell` function
provided by this flake's outputs:

```nix
{
  inputs = {
    # A repository of nix development environment flakes.
    element-nix-flakes.url = "github:vector-im/nix-flakes";
  };

  outputs = { self, element-nix-flakes, ... }:
    {
      # Use the `composeShell` function provided by nix-flakes
      # and specify the projects we'd like dependencies for.
      devShells = element-nix-flakes.outputs.composeShell [
        "synapse"
      ];
    };
}
```

Note that `composeShell` takes a list as an argument. You can provide multiple
project names in this list, and `composeShell` will build a development shell
dependencies from all projects combined together.

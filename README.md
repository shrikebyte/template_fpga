# Shrikebyte Template FPGA Project

This repository holds Shrikebyte's public, open source FPGA project template.

## Getting Started

### Get the Source Code

This repository is hosted on [GitHub](https://github.com/shrikebyte/template_fpga) and can be directly cloned using this command:

`git clone https://github.com/shrikebyte/template_fpga.git`

### Install Project Tools

- Vivado 2025.2
- Python

#### Install Vivado

Vivado can be [downloaded here](https://www.xilinx.com/support/download.html).

For detailed instructions, including hardware and OS requirements, see [Xilinx UG973](https://docs.amd.com/r/en-US/ug973-vivado-release-notes-install-license).

#### Install NVC

NVC is an open-source VHDL simulator.

The latest version can be compiled from source and manually installed by cloning, building, and installing the open-source repo (recommended):

`git clone https://github.com/nickg/nvc.git`

Alternatively, a pre-compiled release can be downloaded from [Github](https://github.com/nickg/nvc/releases), however, this is a rapidly evolving project so compiling the most up-to-date code yourself is the recommended approach.

### Test

`make sim`

## Release Process

This project uses Github actions to manage releases. Once a new version of the code is ready to be tagged and released:

1. Run `make style-fix` from the repo's root to run the code style tool over the new code. This ensures style consistency across the codebase without the need for manual code reviews.
2. Update the version number at the top of the [Makefile](Makefile), following Semantic Versioning.
3. Update the [changelog](CHANGELOG.md) with a summary the changes for the release.
4. Add, commit, and push the changes using git.
5. Run the following command, which creates a new git tag, triggering a Github action to build the output products and create a new Github release.

   `make release`

### Versioning

This project uses [Semantic Versioning](http://semver.org/).
For a list of available versions and the design change history see the
[changelog](CHANGELOG.md).

Semantic versioning shall be used with respect to the module's HDL interfaces.
A major changes breaks at least one module interface. A minor change can add
a new interface and/or feature to a module without breaking compatibility.
A patch change fixes a bug without breaking compatibility.

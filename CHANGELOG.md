# Changelog

All notable changes to this project will be documented in this file.

## [0.1.1] - Unreleased

### Changed

- Bump Python tool versions.
- Bump sblib library version.
- Replace board.mk with board.tcl. This makes it cleaner to add board-specific build script customizations.
- Rename platforms directory to boards directory.
- Rename tools directory to scripts directory.
- Switch from GHDL to NVC simulator for VHDL'19 support.
- Improve build scripts to add more options hooks.
- Update CI script to fix a python build bug related to VUnit. This should only be a temporary fix until the next version of VUnit is released. See this [Github issue](https://github.com/VUnit/vunit/issues/1158) for further details.
- Update CI script to use NVC instead of GHDL.

## [0.1.0] - 2025-10-17

### Added

- Initial release

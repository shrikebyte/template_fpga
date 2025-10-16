# HDL Modules External Dependency

Some files from the [HDL-Modules](https://github.com/hdl-modules/hdl-modules) library have been added as a dependency to sblib-open because they are used by the register file generator scripts.

Only the register-related files have been copied over. Since only three files from this library are needed, it made more sense to simply copy and paste them into this repo rather than introducing the complexity of git submodules.

These files have been minimally changed so that they are not tied to specific
vhdl library namespaces.

The hdlm_conv_pkg was added by sblib as a converter interface between the hdl modules axi lite interface and the sblib interface.

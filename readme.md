# bash qemu helpers

_I like [QEMU](https://www.qemu.org/) and I like to use it directly from the [CLI](https://qemu.readthedocs.io/) to run tests with virtual machines : these helpers save me typing time._

download `.qemu-helpers.rc` and source it after checking in your current bash shell or in your `~/.bashrc`.



## qemu

### alias

quick call to `qemu-system-x86_64` with a few default parameters that can naturally (for the most part) be overridden by the command line.
`-serial mon:stdio` avoids an unfortunate Ctrl-C.

> _`qemu` function and `qemu` alias cannot coexist._
> _this latter is commented/deactivated in favor of the function._


### function

this helper executes `qemu-system-x86_64` with the parameters stored in the `qemu.cfg` configuration file (if present and executable) and the parameters passed on the command line (which supplement or overwrite those previously defined in the configuration file or in the function).
symbolic link can be used for `qemu.cfg` configuration file (eg. multiple settings).
`chmod +x qemu.cfg` to activate the configuration and `chmod -x qemu.cfg` to deactivate it.

> _`qemu` function and `qemu` alias cannot coexist._



## qemu-img

### qemu-img create

this helper allows you to create a new image (qcow2 if not specified) based on a previous one, whose format will be automatically detected.
it stops if the base image supplied is not read-only.

> _`qemu-img create -b previous next` will run `/usr/bin/qemu-img create -b previous -F qcow2 -f qcow2 next` if `previous` base is a qcow2 file (magic string `QFI\xfb`) and `/usr/bin/qemu-img create -b previous -F raw -f qcow2 next` otherwise._


### qemu-img tree

this helper displays base images (eg. dependencies) in tree form, highlighting those that are not read-only.



## qemu-usbhost

this helper makes it easy to find the usb port where a smartphone is plugged in, so that it can be _fully_ transferred to the virtual machine.


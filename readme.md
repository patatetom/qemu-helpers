# bash qemu helpers

download `qemu-helpers.sh` and source it in your current bash shell or in your `~/.bashrc`.


## alias

quick call to `qemu-system-x86_64` with a few default parameters that can naturally be overridden by the command line.
`-serial mon:stdio` avoids an unfortunate Ctrl-C.


## qemu-img

this helper follows a [discussion](https://mail.gnu.org./archive/html/qemu-discuss/2024-04/msg00017.html) on the qemu-discuss forum.
it allows you to create a new image (qcow2 if not specified) based on a previous one, whose format will be automatically detected.
it stops if the base image is not read-only.

`qemu-img create -b previous next` will run `/usr/bin/qemu-img create -b previous -F qcow2 -f qcow2 next` if `previous` base is a qcow2 file (magic string `QFI\xfb`) and `/usr/bin/qemu-img create -b previous -F raw -f qcow2 next` otherwise.


## qemu-usbhost

this helper makes it easy to find the usb port where a smartphone is plugged in, so that it can be _fully_ transferred to the virtual machine.

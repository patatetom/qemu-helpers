# qemu alias
alias qemu='qemu-system-x86_64 -accel kvm -machine q35 -m 3072 -device VGA,edid=on,xres=1280,yres=720 -device qemu-xhci -device usb-tablet -serial mon:stdio'

# qemu-img create helper (bash function)
# no need to specify backing file format (auto-detected)
# and/or desired file format (qcow2 by default)
qemu-img () {
    local verb=$1
    shift
    local base baseFormat format
    [[ "$verb" == "create" ]] &&
    {
        local opt OPTARG OPTIND
        while getopts 'b:F:f:' opt
        do
            case $opt in
                b) base=$OPTARG;;
                F) baseFormat=$OPTARG;;
                f) format=$OPTARG;;
            esac
        done
        shift $((OPTIND-1))
        [[ "$base" ]] &&
        {
            [[ ! -e "$base" ]] && echo 'Base image: no such file or directory' >/dev/stderr && return 1
            [[ ! -r "$base" ]] && echo 'Base image: no read permission' >/dev/stderr && return 1
            [[ -w "$base" ]] && echo 'Base image: base image is writable' >/dev/stderr && return 1
            [[ "$baseFormat" ]] || baseFormat=$( [[ "$( head -c4 "$base" )" == "QFI\xFB" ]] && echo qcow2 || echo raw )
            [[ "$format" ]] || format='qcow2'
        }
    }
    /usr/bin/qemu-img "$verb" -b "$base" -F "$baseFormat" -f "$format" $@
}

# qemu USB helper (bash function)
qemu-usbhost() {
    for usb in $( find /sys/bus/usb/devices/ | grep -E '/[0-9]+-[0-9]+$' )
    do
        cat $usb/product 2>/dev/null || echo "unknown device"
        busport=$( basename $usb )
        echo $(
            sed -e 's/-/,hostport=/' \
                -e 's/^/device_add usb-host,hostbus=/' \
                -e 's/$/,id=usb-host-'$busport/ <<< $busport
        )
        read vendor < $usb/idVendor
        read product < $usb/idProduct
        echo device_add usb-host,vendorid=0x$vendor,productid=0x$product,id=usb-host-$vendor-$product
        echo
    done | tr '[:upper:]' '[:lower:]'
}

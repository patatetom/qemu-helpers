#!/usr/bin/false

# qemu alias
#alias qemu='qemu-system-x86_64 -accel kvm -machine q35 -m 2048 -cpu Nehalem,kvm=off -smp 2 -device qemu-xhci -device usb-tablet -parallel null -serial mon:stdio'

# qemu command line helper (function)
#  use configuration file if exists AND executable
#  otherwise call qemu with defined/prefered parameters
#  additional parameters (override) are forwarded in both cases
#  (use #!/usr/bin/false as shebang in configuration file to avoid execution)
qemu() {
    local config=qemu.cfg
    local qemu=qemu-system-x86_64
    if [ -s "$config" ] && [ -x "$config" ]
    then
        TMPDIR=/tmp/ "$qemu" $( grep -v '#.*' "$config" ) $@
    else
        TMPDIR=/tmp/ "$qemu" \
        -accel kvm \
        -machine q35 -m 2048 \
        -cpu Nehalem,kvm=off -smp 2 \
        -device qemu-xhci -device usb-tablet \
        -parallel null -serial mon:stdio \
        $@
    fi
}

# qemu-img create helper (bash function)
#  no need to specify backing file format (auto-detected)
#  and/or desired file format (qcow2 by default)
# qemu-img tree helper (bash function)
#  display dependencies (base images) in tree form
qemu-img () {
	local bin=/usr/bin/qemu-img
	local verb=$1
	shift
	local base baseFormat format
	if [ "$verb" == "create" ]
	then
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
		[ "$format" ] ||
			format='qcow2'
		if [ "$base" ]
		then
			[ ! -e "$base" ] &&
				echo 'Base image: no such file or directory' >/dev/stderr &&
					return 1
			[ ! -r "$base" ] &&
				echo 'Base image: no read permission' >/dev/stderr &&
					return 1
			[ -w "$base" ] &&
				echo 'Base image: base image is writable' >/dev/stderr &&
					return 1
			[ "$baseFormat" ] ||
				baseFormat=$(
					[ "$( head -c4 "$base" | base64 )" == "UUZJ+w==" ] &&
						echo qcow2 ||
							echo raw
				)
			"$bin" "$verb" -b "$base" -F "$baseFormat" -f "$format" $@
		else
			"$bin" "$verb" -f "$format" $@
		fi
	elif [ "$verb" == "tree" ]
	then
		local info=$( qemu-img info --force-share --output=json "$1" )
		if [ "$info" ]
		then
			local virtualSize diskSize fileFormat backingFile
			IFS=$'\n' read -srd '' virtualSize diskSize fileFormat backingFile < <(
				jq -r '."virtual-size",."actual-size",."format",."full-backing-filename"' <<< $info
			)
			IFS=$'\n' read -srd '' virtualSize diskSize < <(
				numfmt --to=iec $virtualSize $diskSize
			)
			[ "$2" ] && [ -w "$1" ] && tput setaf 3
			echo "$2$1 (${fileFormat^^} - $diskSize / $virtualSize)" && tput sgr0
			[ "$backingFile" != "null" ] && qemu-img tree "$( readlink -e "$backingFile" )" " ${2:-└─ }"
		fi
	else
		[ ! "$verb" ] && "$bin" --help || "$bin" "$verb" $@
	fi
}

# qemu USB helper (bash function)
qemu-usbhost() {
    local busport product vendor
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

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

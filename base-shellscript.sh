#
#
#
#

PROG=`basename $0`

usage() {
cat << EOF


    $PROG [flags]

    Flags that take arguments:
    -h|--help:

    Usage:

        $PROG 


EOF
}

while [ $# -ge 1 ]
do
   case "$1" in
    -h|--help)
       usage
       exit 0
       ;;
    -*)
       echo "Not implemented: $1" >&2
       exit 1
       ;;
    *)
       break
       exit 0
       ;;
   esac
   shift
done

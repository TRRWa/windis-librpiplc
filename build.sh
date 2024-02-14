ROOT_DIR=$(dirname $(realpath "$0"))
BUILD_DIR=$ROOT_DIR/build
INSTALL_DIR=/tmp/librpiplc

INSTALL=""
DEBUG=""
PLC_VERSION=""
PLC_MODEL=""

for i in "$@"; do
    case $i in
	"-i"|"--install")
	    INSTALL="install"
	    shift
	    ;;
	"-d"|"--debug")
	    DEBUG="-d"
	    shift
	    ;;
	"-V"[0-9])
	    if [[ "$1" =~ -V[3-4] ]]; then
		PLC_VERSION="RPIPLC_${1#-}"
		shift
	    else
		echo "Error: Version number is missing or incorrectly formatted. It must be -V4 or -V3"
		exit 1
	    fi
	    ;;
	"-M")
	    shift
	    if [[ $1 == "ALL" ]]; then
		PLC_MODEL="ALL"
	    else
		PLC_MODEL="RPIPLC_$1"
	    fi
	    shift
	    ;;
	"-VALL")
	    PLC_VERSION="ALL";
	    shift
	    ;;
	-*|--*)
	    echo "Unknown option $i. Usage: $0 [--install | --debug] PLC_VERSION PLC_MODEL"
	    exit 1
	    ;;
	*)
	    ;;
    esac
done



# Prepare CMake build infrastructure
"$ROOT_DIR/prepare_cmake.sh" "$PLC_VERSION" "$PLC_MODEL" "$DEBUG"

# Build the install target
make -j$(nproc --all) -C "$BUILD_DIR" $INSTALL

# Copy all new files
if [ -n "$INSTALL" ]; then
    if [ -d "$INSTALL_DIR" ]; then
	sudo cp -r "$INSTALL_DIR/lib" /usr/local/
	sudo cp -r "$INSTALL_DIR/include" /usr/local/
	cp -r $INSTALL_DIR/test ~
    else
	echo "Could not locate installation files. Aborting..."
	exit 1
    fi
fi

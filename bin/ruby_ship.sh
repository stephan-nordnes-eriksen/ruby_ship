OS="unknown"
if [[ "$OSTYPE" == "linux-gnu" ]]; then
	OS="linux-gnu"
elif [[ "$OSTYPE" == "darwin"* ]]; then
	OS="darwin"
elif [[ "$OSTYPE" == "cygwin" ]]; then
	OS="cygwin"
elif [[ "$OSTYPE" == "win32" ]]; then
	OS="win32"
elif [[ "$OSTYPE" == "freebsd"* ]]; then
	OS="freebsd"
fi

./${OS}_ruby.sh "$@"
if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo "Usage: nix_compile_ruby.sh /path/to/ruby_source.tar.gz"
    exit 1
fi

#DETECT_OS
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


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Compiling and installing ruby"

#PRE INSTALL CLEANUP
rm -rf $DIR/extracted_ruby
mkdir $DIR/extracted_ruby
tar -xzf $1 -C $DIR/extracted_ruby

RUBYDIR="$(ls $DIR/extracted_ruby)"
RUBY_VERSION="$(echo $RUBYDIR | cut -d'-' -f 2)"

echo "Installing ruby version $RUBY_VERSION"


#BUILDING RUBY
cd $DIR/extracted_ruby/$RUBYDIR
$DIR/extracted_ruby/$RUBYDIR/configure --prefix=$DIR/../bin/${OS}_ruby
make
make install



#MAKING THE SCRIPT:
RUBY_INSTALL_DIR="$(ls $DIR/../bin/${OS}_ruby/include)"
RUBY_VERSION_DIR="$(echo $RUBY_INSTALL_DIR | cut -d'-' -f 2)"

echo "DIR=\"\$( cd \"\$( dirname \"\${BASH_SOURCE[0]}\" )\" && pwd )\"" > $DIR/../bin/${OS}_ruby.sh

echo "\$DIR/${OS}_ruby/bin/ruby \"\$@\" -I \$DIR/${OS}_ruby/lib/ruby/gems/$RUBY_VERSION_DIR/ -I \$DIR/${OS}_ruby/lib/ruby/$RUBY_VERSION_DIR/ -I \$DIR/${OS}_ruby/bin/ -I \$DIR/${OS}_ruby/lib/ruby/$RUBY_VERSION_DIR/x86_64-darwin13.0/" >> $DIR/../bin/${OS}_ruby.sh


chmod a+x $DIR/../bin/ruby_ship.sh
chmod a+x $DIR/../bin/${OS}_ruby.sh




#Clean up:
rm -rf $DIR/extracted_ruby


#
echo "Ruby Ship finished installing Ruby $RUBY_VERSION!"
echo "Run scripts by using the bin/ruby_ship.sh as you would use the normal ruby command."
echo "Eg.: bin/ruby_ship.sh -v"
echo "=> ruby $RUBY_VERSION..."
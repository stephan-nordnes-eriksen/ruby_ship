if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo "Usage: nix_compile_ruby.sh /path/to/ruby_source.tar.gz"
    exit 1
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
$DIR/extracted_ruby/$RUBYDIR/configure --prefix=$DIR/../bin/osx_ruby
make
make install



#MAKING THE SCRIPT:
RUBY_INSTALL_DIR="$(ls $DIR/../bin/osx_ruby/include)"
RUBY_VERSION_DIR="$(echo $RUBY_INSTALL_DIR | cut -d'-' -f 2)"

echo "DIR=\"\$( cd \"\$( dirname \"\${BASH_SOURCE[0]}\" )\" && pwd )\"" > $DIR/../bin/osx_ruby.sh

echo "\$DIR/osx_ruby/bin/ruby \"\$@\" -I \$DIR/osx_ruby/lib/ruby/gems/$RUBY_VERSION_DIR/ -I \$DIR/osx_ruby/lib/ruby/$RUBY_VERSION_DIR/ -I \$DIR/osx_ruby/bin/ -I \$DIR/osx_ruby/lib/ruby/$RUBY_VERSION_DIR/x86_64-darwin13.0/" >> $DIR/../bin/osx_ruby.sh




#Clean up:
rm -rf $DIR/extracted_ruby
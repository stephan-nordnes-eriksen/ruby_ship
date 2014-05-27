DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "'$DIR'"
$DIR/osx_ruby/bin/ruby "$@" -I $DIR/osx_ruby/lib/ruby/gems/2.1.0/ -I $DIR/osx_ruby/lib/ruby/2.1.0/ -I $DIR/osx_ruby/bin/ -I $DIR/osx_ruby/lib/ruby/2.1.0/x86_64-darwin13.0/


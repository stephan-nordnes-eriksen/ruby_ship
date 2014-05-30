DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
$DIR/darwin_ruby/bin/ruby "$@" -I $DIR/darwin_ruby/lib/ruby/gems/2.1.0/ -I $DIR/darwin_ruby/lib/ruby/2.1.0/ -I $DIR/darwin_ruby/bin/ -I $DIR/darwin_ruby/lib/ruby/2.1.0/x86_64-darwin13.0/

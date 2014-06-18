DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
$DIR/linux-gnu_ruby/bin/ruby "$@" -I $DIR/linux-gnu_ruby/lib/ruby/gems/2.1.0/ -I $DIR/linux-gnu_ruby/lib/ruby/2.1.0/ -I $DIR/linux-gnu_ruby/bin/ -I $DIR/linux-gnu_ruby/lib/ruby/2.1.0/x86_64-darwin13.0/

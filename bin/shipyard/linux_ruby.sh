DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
$DIR/linux_ruby/bin/ruby "$@" -I $DIR/shipyard/linux_ruby/lib/ruby/gems/2.1.0/ -I $DIR/shipyard/linux_ruby/lib/ruby/2.1.0/ -I $DIR/shipyard/linux_ruby/bin/ -I $DIR/shipyard/linux_ruby/lib/ruby/2.1.0/i686-linux/

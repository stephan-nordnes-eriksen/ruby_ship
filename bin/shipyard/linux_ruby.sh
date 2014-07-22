DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GEM_PATH=$DIR/linux_ruby/lib/ruby/gems/2.1.0/:$DIR/linux_ruby/lib/ruby/2.1.0/:$DIR/linux_ruby/bin/:$DIR/linux_ruby/lib/ruby/2.1.0/i686-linux/
GEM_HOME=$DIR/linux_ruby/lib/ruby/gems/2.1.0/
$DIR/linux_ruby/bin/ruby "$@" -I $DIR/shipyard/linux_ruby/lib/ruby/gems/2.1.0/ -I $DIR/shipyard/linux_ruby/lib/ruby/2.1.0/ -I $DIR/shipyard/linux_ruby/bin/ -I $DIR/shipyard/linux_ruby/lib/ruby/2.1.0/i686-linux/

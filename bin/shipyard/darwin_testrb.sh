DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GEM_PATH="${DIR}/darwin_ruby/lib/ruby/gems/2.1.0/:${DIR}/darwin_ruby/lib/ruby/2.1.0/:${DIR}/darwin_ruby/bin/:${DIR}/darwin_ruby/lib/ruby/2.1.0/x86_64-darwin14.0/"
GEM_HOME="${DIR}/darwin_ruby/lib/ruby/gems/2.1.0/"
"${DIR}/darwin_ruby/bin/testrb" "$@"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GEM_PATH="${DIR}/freebsd_ruby/lib/ruby/gems/2.2.0/:${DIR}/freebsd_ruby/lib/ruby/2.2.0/:${DIR}/freebsd_ruby/bin/:${DIR}/freebsd_ruby/lib/ruby/2.2.0/x86_64-freebsd11.0/"
GEM_HOME="${DIR}/freebsd_ruby/lib/ruby/gems/2.2.0/"
"${DIR}/freebsd_ruby/bin/erb" "$@"

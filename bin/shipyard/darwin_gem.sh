DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GEM_PATH="${DIR}/darwin_ruby/lib/ruby/gems/2.1.0 ruby/:${DIR}/darwin_ruby/lib/ruby/2.1.0 ruby/:${DIR}/darwin_ruby/bin/:${DIR}/darwin_ruby/lib/ruby/2.1.0 ruby//Users/stephan/Documents/github/ruby_ship/tools/../bin/shipyard/darwin_ruby/lib/ruby/2.1.0:
x86_64-darwin14.0/"
GEM_HOME="${DIR}/darwin_ruby/lib/ruby/gems/2.1.0 ruby/"
"${DIR}/darwin_ruby/bin/gem" "$@"
if [[ "$1" == "install" ]]; then
  cd "${DIR}/../../"
  ruby "./tools/auto_relink_dylibs.rb"
fi

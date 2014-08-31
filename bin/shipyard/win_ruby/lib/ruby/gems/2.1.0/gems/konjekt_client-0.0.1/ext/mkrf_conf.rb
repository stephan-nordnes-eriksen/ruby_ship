require 'rubygems'
require 'rubygems/command.rb'
require 'rubygems/dependency.rb'
require 'rubygems/dependency_installer.rb'
require 'rbconfig'

begin
	Gem::Command.build_args = ARGV
rescue NoMethodError
end

deps = []
if RbConfig::CONFIG['target_os'] =~ /freebsd/i
	deps << Gem::Dependency.new("rb-kqueue", '>=0.2')
end

#Try to find a solution for windows. This only works in newer versions of ruby. Also: try to make the whole fucking thing work on windows.
# if RbConfig::CONFIG['target_os'] =~ /mswin|mingw|cygwin/i
# 	deps << Gem::Dependency.new("wdm", '>=0.1.0') #This only works on ruby 1.9.2+
# end

# inst = Gem::DependencyInstaller.new
# begin
# 	inst.install 'rb-kqueue', '>= 0.2' if RbConfig::CONFIG['target_os'] =~ /freebsd/i
# 	inst.install 'wdm', '>= 0.1.0'     if RbConfig::CONFIG['target_os'] =~ /mswin|mingw|cygwin/i
# rescue
# 	exit(1)
# end


begin 
    inst = Gem::DependencyInstaller.new
    deps.each do |dep|
	    inst.install dep
	end
rescue
	exit(1)
end

# create dummy rakefile to indicate success
f = File.open(File.join(File.dirname(__FILE__), "Rakefile"), "w")
f.write("task :default\n")
f.close

@echo off
@if not "%~d0" == "~d0" goto WinNT
C:\Users\Stephan_2\Documents\GitHub\ruby_ship\tools\\..\bin\win_ruby\bin\ruby -x "C:/Users/Stephan_2/Documents/GitHub/ruby_ship/tools//../bin/win_ruby/bin/gem.bat" %1 %2 %3 %4 %5 %6 %7 %8 %9
@goto endofruby
:WinNT
"%~dp0ruby" -x "%~f0" %*
@goto endofruby
#!C:/Users/Stephan_2/Documents/GitHub/ruby_ship/tools//../bin/win_ruby/bin/ruby
#--
# Copyright 2006 by Chad Fowler, Rich Kilmer, Jim Weirich and others.
# All rights reserved.
# See LICENSE.txt for permissions.
#++

require 'rubygems'
require 'rubygems/gem_runner'
require 'rubygems/exceptions'

required_version = Gem::Requirement.new ">= 1.8.7"

unless required_version.satisfied_by? Gem.ruby_version then
  abort "Expected Ruby Version #{required_version}, is #{Gem.ruby_version}"
end

args = ARGV.clone

begin
  Gem::GemRunner.new.run args
rescue Gem::SystemExitException => e
  exit e.exit_code
end

__END__
:endofruby

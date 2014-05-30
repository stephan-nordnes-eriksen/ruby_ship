@echo off
@if not "%~d0" == "~d0" goto WinNT
C:\Users\Stephan_2\Documents\GitHub\ruby_ship\tools\\..\bin\win_ruby\bin\ruby -x "C:/Users/Stephan_2/Documents/GitHub/ruby_ship/tools//../bin/win_ruby/bin/irb.bat" %1 %2 %3 %4 %5 %6 %7 %8 %9
@goto endofruby
:WinNT
"%~dp0ruby" -x "%~f0" %*
@goto endofruby
#!C:/Users/Stephan_2/Documents/GitHub/ruby_ship/tools//../bin/win_ruby/bin/ruby
#
#   irb.rb - interactive ruby
#   	$Release Version: 0.9.6 $
#   	$Revision: 40560 $
#   	by Keiju ISHITSUKA(keiju@ruby-lang.org)
#

require "irb"

IRB.start(__FILE__)
__END__
:endofruby

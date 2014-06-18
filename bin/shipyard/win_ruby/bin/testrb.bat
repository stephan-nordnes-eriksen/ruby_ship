@echo off
@if not "%~d0" == "~d0" goto WinNT
C:\Users\Stephan_2\Documents\GitHub\ruby_ship\tools\\..\bin\win_ruby\bin\ruby -x "C:/Users/Stephan_2/Documents/GitHub/ruby_ship/tools//../bin/win_ruby/bin/testrb.bat" %1 %2 %3 %4 %5 %6 %7 %8 %9
@goto endofruby
:WinNT
"%~dp0ruby" -x "%~f0" %*
@goto endofruby
#!C:/Users/Stephan_2/Documents/GitHub/ruby_ship/tools//../bin/win_ruby/bin/ruby
require 'test/unit'
exit Test::Unit::AutoRunner.run(true)
__END__
:endofruby

@echo off
@if not "%~d0" == "~d0" goto WinNT
C:\Users\Stephan_2\Documents\GitHub\ruby_ship\tools\\..\bin\win_ruby\bin\ruby -x "C:/Users/Stephan_2/Documents/GitHub/ruby_ship/tools//../bin/win_ruby/bin/rdoc.bat" %1 %2 %3 %4 %5 %6 %7 %8 %9
@goto endofruby
:WinNT
"%~dp0ruby" -x "%~f0" %*
@goto endofruby
#!C:/Users/Stephan_2/Documents/GitHub/ruby_ship/tools//../bin/win_ruby/bin/ruby
#
#  RDoc: Documentation tool for source code
#        (see lib/rdoc/rdoc.rb for more information)
#
#  Copyright (c) 2003 Dave Thomas
#  Released under the same terms as Ruby

begin
  gem 'rdoc'
rescue NameError => e # --disable-gems
  raise unless e.name == :gem
rescue Gem::LoadError
end

require 'rdoc/rdoc'

begin
  r = RDoc::RDoc.new
  r.document ARGV
rescue Errno::ENOSPC
  $stderr.puts 'Ran out of space creating documentation'
  $stderr.puts
  $stderr.puts 'Please free up some space and try again'
rescue SystemExit
  raise
rescue Exception => e
  if $DEBUG_RDOC then
    $stderr.puts e.message
    $stderr.puts "#{e.backtrace.join "\n\t"}"
    $stderr.puts
  elsif Interrupt === e then
    $stderr.puts
    $stderr.puts 'Interrupted'
  else
    $stderr.puts "uh-oh! RDoc had a problem:"
    $stderr.puts e.message
    $stderr.puts
    $stderr.puts "run with --debug for full backtrace"
  end

  exit 1
end

__END__
:endofruby

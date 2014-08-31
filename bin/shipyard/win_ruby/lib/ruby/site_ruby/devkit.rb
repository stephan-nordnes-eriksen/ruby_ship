# enable RubyInstaller DevKit usage as a vendorable helper library
unless ENV['PATH'].include?('C:\\Users\\Stephan_2\\Documents\\GitHub\\rubyinstaller\\pkg\\mingw\\bin') then
  phrase = 'Temporarily enhancing PATH to include DevKit...'
  if defined?(Gem)
    Gem.ui.say(phrase) if Gem.configuration.verbose
  else
    puts phrase
  end
  puts "Prepending ENV['PATH'] to include DevKit..." if $DEBUG
  ENV['PATH'] = 'C:\\Users\\Stephan_2\\Documents\\GitHub\\rubyinstaller\\pkg\\bin;C:\\Users\\Stephan_2\\Documents\\GitHub\\rubyinstaller\\pkg\\mingw\\bin;' + ENV['PATH']
end
ENV['RI_DEVKIT'] = 'C:\\Users\\Stephan_2\\Documents\\GitHub\\rubyinstaller\\pkg'
ENV['CC'] = 'gcc'
ENV['CXX'] = 'g++'
ENV['CPP'] = 'cpp'

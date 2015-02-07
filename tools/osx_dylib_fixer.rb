require "fileutils"
require "pry"

@current_dir = FileUtils.pwd


def fix_dylib_for_file(file)
	puts `tools/dylibbundler -x #{file} -b -d bin/shipyard/darwin_ruby/libs -of`
	# results = `otool -L #{file}` #Will get information about which dylibs to link
	# if results.is_a?(String) && results != "" && !results.include?("is not an object file")  && !results.include?("Assertion failed:")
	# 	#This magical tool should fix everything for us
		
	# end
end

puts File.dirname(File.expand_path($0))

folders = [File.expand_path(File.join(File.dirname(File.expand_path($0)), "..", "bin", "shipyard", "darwin_ruby"))]

full = folders.map{|f| Dir[File.join(f, '**', '*')]}
actual_files = full.flatten(1).uniq.select{|e| File.file? e}


actual_files.each do |file|
	fix_dylib_for_file(file)
end

puts "Relinking of dylib done"

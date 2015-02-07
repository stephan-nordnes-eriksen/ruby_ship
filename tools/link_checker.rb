#Meant for debugging only. It will traverse all Mach-O files and check if there are any invalid links. 
#Warning: Not an exhaustive search. There can be many other issues than what this script finds

require "fileutils"
@new_dylib_path = File.join("shipyard", "darwin_ruby", "dylibs")

def check_dylib(file)
	results = `otool -L #{file}` #Will get information about which dylibs to link
	
	if results.is_a?(String) && results != "" && !results.include?("is not an object file") && !results.include?("Assertion failed:")
		# puts "checking #{file}"
		if !results.split("\n").select{|e| e.include?(File.join("usr","local"))}.empty?
			puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			puts "Invalid link in: #{file}"
			puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		end
		# results.split("\n").each_with_index{|e, i| puts "#{i}: #{e.strip}"}
	end
end


folders = [File.expand_path(File.join(File.dirname(File.expand_path($0)), "..", "bin", "shipyard", "darwin_ruby"))]

full = folders.map{|f| Dir[File.join(f, '**', '*')]}
actual_files = full.flatten(1).uniq.select{|e| File.file? e}


actual_files.each do |file|
	check_dylib(file)
end

puts "Dylib check done"

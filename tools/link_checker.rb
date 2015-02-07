require "fileutils"
@new_dylib_path = File.join("shipyard", "darwin_ruby", "dylibs")



def check_dylib(file)
	
	results = `otool -L #{file}` #Will get information about which dylibs to link
	
	if results.is_a?(String) && results != "" && !results.include?("is not an object file") && !results.include?("Assertion failed:")
		# puts "checking #{file}"
		if !results.split("\n").select{|e| e.include?(File.join("usr","local"))}.empty?
			puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			puts "2: #{file}"
			puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		end
		return
		results.split("\n").each_with_index{|e, i| puts "#{i}: #{e.strip}"}

		#Setting new ID for this if needed
		id_path = File.join("shipyard", file.split(File.join("shipyard"))[-1])
		# id_reset_results = `sudo install_name_tool -id #{id_path} #{file} 2> /dev/null` #Will link the current file to itself
		

		lines = results.split("\n")
		lines = [] unless lines
		itterate = lines[1..-1]
		itterate = [] unless itterate


		itterate.each do |libfile_line|
			puts "Something wrong with: #{file}" if libfile_line.include?("/usr/")
		end
	end
end


folders = [File.expand_path(File.join(File.dirname(File.expand_path($0)), "..", "bin", "shipyard", "darwin_ruby"))]

full = folders.map{|f| Dir[File.join(f, '**', '*')]}
actual_files = full.flatten(1).uniq.select{|e| File.file? e}


actual_files.each do |file|
	check_dylib(file)
end

puts "Dylib check done"

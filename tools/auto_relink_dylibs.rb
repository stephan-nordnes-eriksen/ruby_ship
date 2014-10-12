require "fileutils"
new_dylib_path = File.join("..","bin","shipyard","darwin_ruby","ruby_ship_dylibs")
FileUtils.mkdir_p(new_dylib_path)

folders = ["../bin/shipyard/darwin_ruby"]

full = folders.map{|f| Dir[File.join(f, '**', '*')]}
actual_files = full.flatten(1).uniq.select{|e| File.file? e}

actual_files.each do |file|
	results = `otool -L #{file}`

	if results.is_a?(String) && !results.include?("#{file}: is not an object file")
		puts "---------------------------------"
		puts "relinking: #{file}"
		puts "---------------------------------"

		lines = results.split("\n")
		
		lines[1..-1].each do |libfile_line|
			libfile = libfile_line.split(" (compatibility version")[0].strip
			libfile = libfile.split("(")[0]
			next if libfile.include?(new_dylib_path)
			
			new_libfile = File.join(new_dylib_path, libfile.split(File.join("",""))[-1])
	
			unless File.file?(new_libfile)
				FileUtils.copy(libfile, new_libfile)
				puts "Copied #{new_libfile}"
			end
			relink_command_results = `sudo install_name_tool -change #{libfile} #{new_libfile} #{file} 2> /dev/null`

			if relink_command_results != "" && !relink_command_results.include?("error:")
				puts "relinked in #{file} link: #{libfile} to #{new_libfile}"
			end
		end
	end
end
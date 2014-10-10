
folders = ["../bin/shipyard/darwin_ruby"]

full = folders.map{|f| Dir[File.join(f, '**', '*')]}
actual_files = full.flatten(1).uniq.select{|e| File.file? e}

actual_files.each do |file|
	results = `otool -L #{file}`

	unless results.include?("#{file}: is not an object file")
		lines = results.split("\n")
		lines[1..-1].each do |libfile_line|
			libfile = libfile.split(".dylib (compatibility version")[0] + ".dylib"
			
			new_libfile = File.join("..","bin","shipyard","darwin_ruby","ruby_ship_dylibs",libfile.split(File.join("",""))[-1])
			unless File.file?(new_libfile)
				FileUtils.copy(libfile, new_libfile)
			end
			relink_command_results = `sudo install_name_tool -change #{libfile} #{new_libfile} #{file}`
			#TODO: check what is returned in case this is erroneus
		end
	end
end
module KonjektClient::Core
	# public: FileRegister translates between file paths on the client's disk and the file ids on the server.
	# It loads and stores these relationships to disk.
	class FileRegister
		include EventAggregator::Listener

		def initialize
			@@mutex = Mutex.new
			
			#TODO: Refactor to own method all this directory-ninjaing.
			homes = ["HOME", "HOMEPATH"]
			@realHome = homes.detect {|h| ENV[h] != nil}
			f = File.join(ENV[@realHome], "Konjekt")
			f.untaint
			FileUtils.mkdir_p(f) unless File.directory?(f)

			f = File.join(ENV[@realHome], "Konjekt", ".cache")
			f.untaint
			FileUtils.mkdir_p(f) unless File.directory?(f)

			@@konjekt_file_register_store = File.join(f, 'konjekt_file_register.store')

			#EventAggregator::Message.new("debug","Store location: #{@@konjekt_file_register_store}").publish
			@@file_register_pstorer = PStore.new(@@konjekt_file_register_store)

			@@mutex.synchronize{
				@@file_register_pstorer.transaction do
					@@file_register_pstorer[:file_to_id_hash]    = {} unless defined?(@@file_register_pstorer[:file_to_id_hash]   ) && @@file_register_pstorer[:file_to_id_hash]   .is_a?(Hash)
					@@file_register_pstorer[:index_cache]        = {} unless defined?(@@file_register_pstorer[:index_cache]       ) && @@file_register_pstorer[:index_cache]       .is_a?(Hash)
					@@file_register_pstorer[:file_to_utime_hash] = {} unless defined?(@@file_register_pstorer[:file_to_utime_hash]) && @@file_register_pstorer[:file_to_utime_hash].is_a?(Hash)
				end
			}

			map_message_types_to_producers
			setup_listeners
		end

		#
		# API
		#
		# Actions
		def update_or_create_entry_with_file_and_id!(file, id, modification_time)
			return unless file.is_a?(String) && id.is_a?(Numeric) && modification_time.is_a?(Time)
			@@mutex.synchronize{
				@@file_register_pstorer.transaction do
					@@file_register_pstorer[:file_to_id_hash][file] = id
					@@file_register_pstorer[:file_to_utime_hash][file] = modification_time
				end
			}
			return id
		end

		def update_or_create_entry_with_file_and_id_array!(array)			
			@@mutex.synchronize{
				@@file_register_pstorer.transaction do
					array.each do |data|
						next unless data[0][:file_path].is_a?(String) && data[1].is_a?(Numeric) && data[0][:mtime].is_a?(Time)
						@@file_register_pstorer[:file_to_id_hash][data[0][:file_path]] = data[1]
						@@file_register_pstorer[:file_to_utime_hash][data[0][:file_path]] = data[0][:mtime]
					end
				end
			}
			return true
		end

		def delete_entry_with_file!(file)
			@@mutex.synchronize{
				@@file_register_pstorer.transaction do
					@@file_register_pstorer[:file_to_id_hash].delete(file)
				end
			}
		end

		def delete_entry_with_id!(id)
			old_file_name = id_to_file(id)
			@@mutex.synchronize{
				@@file_register_pstorer.transaction do
					@@file_register_pstorer[:file_to_id_hash].delete(old_file_name)
				end
			}
		end

		def rename_file_to_new_file!(old_file, new_file)
			old_id = file_to_id(old_file)
			@@mutex.synchronize{
				@@file_register_pstorer.transaction do
					@@file_register_pstorer[:file_to_id_hash][new_file] = old_id
				end
			}
			delete_entry_with_file!(old_file)
		end

		# Queries
		def file_to_id(file)
			@@mutex.synchronize{
				@@file_register_pstorer.transaction do
					@@file_register_pstorer[:file_to_id_hash][file]
				end
			}
		end

		def id_to_file(id)
			file_name = nil
			@@mutex.synchronize{
				@@file_register_pstorer.transaction do
					file_name = @@file_register_pstorer[:file_to_id_hash].index(id) # file key from id
				end
			}
			return file_name
		end

		def check_storage_concistency(file_list)
			#TODO: add a check that scans the files and sees if the hash is valid
		end



		#
		# Producers
		#
		def producer_file_name_to_id(file_path)
			file_to_id(file_path)
		end
		def producer_file_lookup_id(id)
			#TODO: Implement whatever this should be.
			id_to_file(id)
		end
		def producer_file_lookup_id_array(array)
			file_names = []
			@@mutex.synchronize{
				@@file_register_pstorer.transaction do
					array.each do |file_id|
						temp = @@file_register_pstorer[:file_to_id_hash].index(file_id)
						file_names << temp if temp
					end
				end
			}
			file_names
		end
		def producer_file_lookup_name(data)
			#TODO: Implement whatever this should be.

		end
		def producer_file_updated?(data)
			return is_file_outdated?(data)
		end


		def producer_files_index_select_needed_from_folders(folders)
			full = folders.map{|f| Dir[File.join(f, '**', '*')]}
			actual_files = full.flatten(1).uniq.select{|e| File.file? e}

			need_indexing = []
			ap = File.join(".app","")
			ke = File.join(ENV[@realHome], "Konjekt","konjekt_errors")
			kc = File.join(ENV[@realHome], "Konjekt",".cache")
			regex = Regexp.new("#{Regexp.escape(ap)}|#{Regexp.escape(ke)}|#{Regexp.escape(kc)}")

			#This is a long one :( well-well-well.
			@@mutex.synchronize{
				@@file_register_pstorer.transaction do
					need_indexing = actual_files.select{ |file_path|
						!file_path[regex] && (!@@file_register_pstorer[:file_to_utime_hash][file_path] ||
						File.mtime(file_path) > @@file_register_pstorer[:file_to_utime_hash][file_path])
					}.map{|file_path| [file_path.untaint, @@file_register_pstorer[:file_to_id_hash][file_path]]}
				end
			}
			return bulk_by_size(need_indexing)#.shuffle #don't do shuffle..
		end

		#The data that comes in is: [file_name, ID]
		def receive_file_id_add(data)
			return nil unless data && defined?(data[0]) && defined?(data[1]) && data[0].is_a?(String) && data[1].is_a?(Numeric)
			@@mutex.synchronize{
				@@file_register_pstorer.transaction do
					@@file_register_pstorer[:file_to_id_hash][data[0]] = data[1]
				end
			}
		end
		#Data should equal [old_path, new_path]
		def receive_file_moved(data)
			return nil unless data && defined?(data[0]) && defined?(data[1]) && data[0].is_a?(String) && data[1].is_a?(String)
			@@mutex.synchronize{
				@@file_register_pstorer.transaction do
					#swaping positions
					@@file_register_pstorer[:file_to_id_hash][data[0]], @@file_register_pstorer[:file_to_id_hash][data[1]] = nil, @@file_register_pstorer[:file_to_id_hash][data[0]]          if @@file_register_pstorer[:file_to_id_hash][data[0]]
					@@file_register_pstorer[:index_cache][data[0]], @@file_register_pstorer[:index_cache][data[1]] = nil, @@file_register_pstorer[:index_cache][data[0]]                      if @@file_register_pstorer[:index_cache][data[0]]
					@@file_register_pstorer[:file_to_utime_hash][data[0]], @@file_register_pstorer[:file_to_utime_hash][data[1]] = nil, @@file_register_pstorer[:file_to_utime_hash][data[0]] if @@file_register_pstorer[:file_to_utime_hash][data[0]]
				end
			}
		end
		def receive_file_renamed(data)
			receive_file_moved(data) #Does the same
		end
		def receive_file_deleted(removed_file_path)
			#TODO: Implement whatever this should be.
			return nil unless removed_file_path && removed_file_path.is_a?(String)
			@@mutex.synchronize{
				@@file_register_pstorer.transaction do
					@@file_register_pstorer[:file_to_id_hash][removed_file_path]    = nil
					@@file_register_pstorer[:index_cache][removed_file_path]        = nil
					@@file_register_pstorer[:file_to_utime_hash][removed_file_path] = nil
				end
			}
		end

		def receive_file_index_stored_to_server(data)
			unless data && defined?(data[0]) &&
             data[0].is_a?(Hash) && data[0].has_key?(:file_path) && data[0].has_key?(:mtime) &&
             defined?(data[1]) && data[1].is_a?(Numeric)
				#EventAggregator::Message.new("debug", "What is this none sense: #{data.inspect}").publish
				return nil
			else
			  update_or_create_entry_with_file_and_id!(data[0][:file_path], data[1], data[0][:mtime])
      end
		end

		def receive_file_index_stored_to_server_array(data)
			unless data 
				EventAggregator::Message.new("debug", "What is this none sense: #{data.inspect}").publish
				return nil 
			end

			
			update_or_create_entry_with_file_and_id_array!(data)
		end

		def receive_file_index_not_stored_to_server(index)
			if index && index.is_a?(Hash)
				store_file_index(index)
			end
		end
		
		def receive_file_index_not_stored_to_server_array(index_array)
			if index_array
				store_file_index_array(index_array)	
			end
		end

		
		def receive_logged_in(data)
			indecies = pop_all_stored_indecies.map{|i| i[:dirty] = true; i}
			EventAggregator::Message.new("FileIndexedArray", indecies).publish if indecies && indecies.length > 0
			#OLD:
			# indecies.each do |index|
			# 	index[:dirty] = true
			# 	# puts "File: #{file}"
			# 	# puts "Index: #{index}"
			# 	EventAggregator::Message.new("FileIndexed", index).publish
			# end
		end

		def receive_file_index_all_check(data)
			directories = EventAggregator::Message.new("StorageDirectoriesGet", nil).request
			directories.each do |fold|
				Dir[File.join(fold, '**', '*')].each do |file|
					file.untaint
					if File.file?(file)
						EventAggregator::Message.new("FileIndex", file).publish if is_file_outdated?(file)
					end
				end
			end
		end


		



		private
		def map_message_types_to_producers
			#TODO: producer_register("GetGeoLocation", lambda{|e| get_geo_location(e)})
			producer_register("FileNameToID"  , lambda {|e| producer_file_name_to_id(e)})
			producer_register("FileLookupID"  , lambda {|e| producer_file_lookup_id(e)})
			producer_register("FileLookupName", lambda {|e| producer_file_lookup_name(e)}) #TODO: WTF is this?
			producer_register("FileUpdated?"  , lambda {|e| producer_file_updated?(e)})

			producer_register("FilesIndexSelectNeededFromFolders", lambda {|e| producer_files_index_select_needed_from_folders(e)}) #TODO: Not tested yet
			producer_register("FileLookupIDArray", lambda {|e| producer_file_lookup_id_array(e)})#TODO: Not tested yet
		end
		def setup_listeners
			message_type_register("FileIDAdd"                      , method(:receive_file_id_add))
			message_type_register("FileMoved"                      , method(:receive_file_moved))
			message_type_register("FileRenamed"                    , method(:receive_file_renamed))
			message_type_register("FileDeleted"                    , method(:receive_file_deleted))
			message_type_register("FileIndexStoredToServer"        , method(:receive_file_index_stored_to_server))
			message_type_register("FileIndexStoredToServerArray"   , method(:receive_file_index_stored_to_server_array))
			message_type_register("FileIndexNotStoredToServer"     , method(:receive_file_index_not_stored_to_server))
			message_type_register("FileIndexNotStoredToServerArray", method(:receive_file_index_not_stored_to_server_array))
			message_type_register("LoggedIn"                       , method(:receive_logged_in))
			message_type_register("FileIndexAllCheck"              , method(:receive_file_index_all_check))

			message_type_register("FileRegisterDump"               , method(:dump))
			message_type_register("StorageReset"                   , method(:reset))
		end
		
		
# Public: Duplicate some text an arbitrary number of times.
#
# file_paths - Array of array with this layout: [ ["file_path", fixnum/nil (ID)], [...] ]
#
# Returns Array of Arrays of arrays with this layout: [ [ ["file_path", fixnum/nil (ID)], [...] ], [...] ]. Split by file size (1GB / bulk (unless large file.))
		def bulk_by_size(file_paths)
			return_bulk = []
			return_bulk_tmp = []
			curr_size = 0
			max_size = 2**30
			file_paths.each do |f|
				if curr_size > max_size  || return_bulk_tmp.count > 500 # > 1GB || too many files.
					return_bulk << return_bulk_tmp 
					return_bulk_tmp = []
					curr_size = 0
				end
				return_bulk_tmp << f
				curr_size += File.size(f[0])
			end
			
			if return_bulk_tmp.length > 0
				return_bulk << return_bulk_tmp
			end

			return return_bulk
		end

		def dump(data)
			data = nil
			@@mutex.synchronize{
				@@file_register_pstorer.transaction do
					data = @@file_register_pstorer.inspect
				end
			}
			EventAggregator::Message.new("debug",data).publish
		end
		def store_file_index(index)
			return if index[:dirty] == true
			@@mutex.synchronize{
				@@file_register_pstorer.transaction do
					@@file_register_pstorer[:index_cache][index[:file_path]] = index
				end
			}
		end
		def store_file_index_array(index_array)
			@@mutex.synchronize{
				@@file_register_pstorer.transaction do
					index_array.each do |index|
						next if !index.is_a?(Hash) || index[:dirty] == true
						@@file_register_pstorer[:index_cache][index[:file_path]] = index
					end
				end
			}
		end

		def pop_all_stored_indecies
			indecies = []
			@@mutex.synchronize{
				@@file_register_pstorer.transaction do
					@@file_register_pstorer[:index_cache].each do |k,v|
						indecies<< @@file_register_pstorer[:index_cache].delete(k)
					end
				end
			}
			return indecies
		end


		#Not used:
		def get_all_stored_indecies
			indecies = []
			@@mutex.synchronize{
				@@file_register_pstorer.transaction do
					indecies = @@file_register_pstorer[:index_cache]
				end
			}
			return indecies
		end
		#Not used:
		def delete_from_stored_indecies(indecies)
			@@mutex.synchronize{
				@@file_register_pstorer.transaction do
					indecies.each do |i|
						k = @@file_register_pstorer[:index_cache].index(i)
						@@file_register_pstorer[:index_cache].delete(k) if k
					end
				end
			}
		end

		def is_file_outdated?(file_path)
			ret = false
			@@mutex.synchronize{
				@@file_register_pstorer.transaction do
					ret = true unless @@file_register_pstorer[:file_to_utime_hash][file_path]
					ret = ret || File.mtime(file_path) > @@file_register_pstorer[:file_to_utime_hash][file_path]
				end
			}
			return ret
		end

		def reset(data)
			if data == "HARD"
				@@mutex.synchronize{
					@@file_register_pstorer.transaction do
						rooties = @@file_register_pstorer.roots
						rooties.each do |root|
							@@file_register_pstorer.delete(root)
						end
						# @@file_register_pstorer.delete(:file_to_id_hash)
						# @@file_register_pstorer.delete(:index_cache)
						# @@file_register_pstorer.delete(:file_to_utime_hash)
					end
				}
			end
		end
	end
end

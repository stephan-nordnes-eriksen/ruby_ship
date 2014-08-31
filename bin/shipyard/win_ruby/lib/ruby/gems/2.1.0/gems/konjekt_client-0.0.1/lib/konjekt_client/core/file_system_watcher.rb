module KonjektClient::Core
	class FileSystemWatcher
		include EventAggregator::Listener
		attr_accessor :listener

		@directories_to_watch = nil
		#@listener = nil
		@file_scanner = nil

		# Public: Initializes the file watcher
		#
		# directories  - An array of strings indicating directories or files to watch for file activities.
		#
		# Returns A FileSystemWatcher instance
		#TODO: Maybe accept array as well as single string.
		def initialize

			#This is no longer needed:
			# directories_to_watch = EventAggregator::Message.new("StorageDirectoriesGet", nil).request
			# raise "illegal directory" unless directories_to_watch.respond_to?(:each)
			# raise "illegal directory" unless directories_to_watch.count > 0

			message_type_register("FolderWatchAdd"   , method(:folder_watch_add))
			message_type_register("FolderWatchRemove", method(:folder_watch_remove))
			message_type_register("LogOut"           , method(:log_out))


			#TODO: This is temp, until we can set up the auto-indexing stuff propperly.
			message_type_register("FileIndexAll"        , method(:receive_file_index_all))
			
			# directories_to_watch.each do |dir|
			# 	raise "illegal directory" unless File.exists? dir
			# end

			#puts "Watching folder(s): #{directories_to_watch}"

			#set_up_listener(directories_to_watch) #TODO: this is temporarily removed.
		end

		def file_modified(file_path)
			EventAggregator::Message.new("FileModified", file_path).publish
		end

		def file_added(file_path)
			EventAggregator::Message.new("FileAdded", file_path).publish
		end

		def file_removed(file_path)
			EventAggregator::Message.new("FileRemoved", file_path).publish
		end

		def folder_watch_add(folder)#TODO: This is not done. We need to add it to the actual listener.
			dirs = EventAggregator::Message.new("StorageDirectoriesGet", nil).request

			dirs = [] unless dirs.is_a? Array

			new_ones = []
			if folder.respond_to?(:each)
				folder.each do |fold|
					fold.untaint
					if !dirs.include?(fold) && File.exists?(fold)
						dirs << fold
						new_ones << fold
					end
				end
			else
				if !dirs.include?(folder) && File.exists?(folder)
					dirs << folder
					new_ones << folder
				end
			end

			EventAggregator::Message.new("StorageDirectoriesSet", dirs).publish

			set_up_listener(dirs)

			index_folders(new_ones)
		end

		def folder_watch_remove(folder)
			dirs = EventAggregator::Message.new("StorageDirectoriesGet", nil).request
			dirs = [] unless dirs.is_a? Array

			removed = nil
			if folder.is_a? Array
				removed = []
				folder.each do |f|
					removed << dirs.delete(f)
				end
				removed == nil if removed.length <= 0
			else
				removed = dirs.delete(folder)
			end
			if removed != nil
				EventAggregator::Message.new("StorageDirectoriesSet", dirs).publish

				set_up_listener(dirs)

				Dir[File.join(removed, '**', '*')].each do |file|
					EventAggregator::Message.new("FileRemove", file).publish if File.file?(file)
				end
			end
		end

		def log_out(user)
			self.stop
		end

		#TODO: See the File.atime. It is the "access time". Maybe we can use this to see what files has been open at the same time.


		# Public: Starts the file watcher. After running this method the file watcher will start producing messages
		# 		  that will be sent to the event aggregator. Non-blocking.
		#
		# Returns True if listening is successfully started. False otherwise.
		def start
			self.listener.start   if self.listener # not blocking
		end
		def listen?
			self.listener.listen? if self.listener
		end
		def pause
			self.listener.pause   if self.listener
		end
		def paused?
			self.listener.paused? if self.listener
		end
		def unpause
			self.listener.unpause if self.listener
		end
		def stop
			self.listener.stop    if self.listener
		end

		def file_added(file_path)
			EventAggregator::Message.new("FileAdded", file_path).publish
		end
		def file_changed(file_path)
			EventAggregator::Message.new("FileChanged", file_path).publish
		end
		def file_moved(file_path)
			EventAggregator::Message.new("FileMoved", file_path).publish
		end
		def file_deleted(file_path)
			EventAggregator::Message.new("FileDeleted", file_path).publish
		end
		def file_renamed(file_path)
			EventAggregator::Message.new("FileRenamed", file_path).publish
		end
		def receive_file_index_all(data)
			directories = EventAggregator::Message.new("StorageDirectoriesGet", nil).request
			if directories && directories.respond_to?(:each)
				index_folders(directories)
				# directories.each do |dir|
				# 	EventAggregator::Message.new("debug", "Got this dir: #{dir}").publish

				# end
			else
				#wtf..
				#EventAggregator::Message.new("FolderWatchAdd", ENV[@realHome]).publish
				#EventAggregator::Message.new("debug", "No directory found: #{directories.inspect}").publish
			end
		end

		private
		def set_up_listener(directories)
			#TODO: Temp hack to stop the listeners:
			return nil

			stop if self.listener && listen? #?

			self.listener = Listen.to(*directories) do |modified, added, removed|
				# puts "modified absolute path: #{modified}" if modified
				# puts "added absolute path: #{added}"       if added
				# puts "removed absolute path: #{removed}"   if removed

				file_modified(modified) if modified
				file_added(added)       if added
				file_removed(removed)   if removed
			end
		end

		def index_folders(folders)
			# EventAggregator::Message.new("FileIndex", "/Users/stephannordneseriksen/android-sdks/add-ons/addon-google_apis-google_inc_-7/docs/reference/com/google/android/maps/GeoPoint.html").publish
			# return
			folders.each do |f|
				f.untaint
			end
			#full = folders.map{|f| Dir[File.join(f, '**', '*')]}
			processed = EventAggregator::Message.new("FilesIndexSelectNeededFromFolders", folders).request

			#number_of_files = processed.inject(0) {|res, f| res + f.count}

			EventAggregator::Message.new("IndexingFilesStartedCount", processed.inject(0){|sum,x| sum + x.count}).publish
			EventAggregator::Message.new("FileIndexArray", processed).publish
			# begin
			# 	processed.each do |file|
			# 		file.untaint
					
			# 		EventAggregator::Message.new("FileIndex", file, false).publish  #Doing async false so that it will start indexing of the first file first.
			# 	end
			# rescue Exception => e
			# 	EventAggregator::Message.new("debug", "Error:#{e.message}").publish
			# end
		end
	end
end
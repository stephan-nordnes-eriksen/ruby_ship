module KonjektClient::Core
	class GUI
		include EventAggregator::Listener
		
		def shutdown
			begin
				EventAggregator::Message.new("Shutdown", nil).publish
			rescue Exception => e
				EventAggregator::Message.new("ERROR", "#{e.message}:"+'def shutdown'+" #{e.backtrace.inspect}").publish
			end
		end
		def log_in(user_name, password)
			begin
				EventAggregator::Message.new("LogIn", {:user_name => user_name, :password => password}).publish 
			rescue Exception => e
				EventAggregator::Message.new("ERROR", "#{e.message}:"+'def log_in(user_name, password)'+" #{e.backtrace.inspect}").publish
			end
		end
		def log_in_token(user_name, token)
			begin
				EventAggregator::Message.new("LogInToken", {:user_name => user_name, :token => token}).publish
			rescue Exception => e
				EventAggregator::Message.new("ERROR", "#{e.message}:"+'def log_in_token(user_name, token)'+" #{e.backtrace.inspect}").publish
			end
		end
		def log_out
			begin
				EventAggregator::Message.new("LogOut", nil).publish	
			rescue Exception => e
				EventAggregator::Message.new("ERROR", "#{e.message}:"+'def log_out'+" #{e.backtrace.inspect}").publish
			end
		end
		def recommend_files()
			begin
				EventAggregator::Message.new("RecommendFilesRequest", nil).publish	
			rescue Exception => e
				EventAggregator::Message.new("ERROR", "#{e.message}:"+'def recommend_files()'+" #{e.backtrace.inspect}").publish
			end
		end
		def string_search(query)
			begin
				EventAggregator::Message.new("StringSearch", query, false).publish #Make it sync so it does not have to wait forever on the indexer
			rescue Exception => e
				EventAggregator::Message.new("ERROR", "#{e.message}:"+'def string_search(query)'+" #{e.backtrace.inspect}").publish
			end
		end
		def folder_watch_add(folder)
			begin
				EventAggregator::Message.new("FolderWatchAdd", folder).publish	
			rescue Exception => e
				EventAggregator::Message.new("ERROR", "#{e.message}:"+'def folder_watch_add(folder)'+" #{e.backtrace.inspect}").publish
			end
		end
		def folder_watch_remove(folder)
			begin
				EventAggregator::Message.new("FolderWatchRemove", folder).publish	
			rescue Exception => e

				EventAggregator::Message.new("ERROR", "#{e.message}:"+'def folder_watch_remove(folder)'+" #{e.backtrace.inspect}").publish
			end
		end
		def file_index(path)
			begin
				path.untaint
				EventAggregator::Message.new("FileIndex", path).publish	
			rescue Exception => e
				EventAggregator::Message.new("ERROR", "#{e.message}:"+'def file_index(path)'+" #{e.backtrace.inspect}").publish
			end
		end
		def file_index_all()
			#TODO: Find a way to return before the FileIndexAll is sent. It locks up the gui because it waits for a response.
			#return "started" #this does not work for some reason.
			begin
				EventAggregator::Message.new("FileIndexAll", nil).publish
			rescue Exception => e
				EventAggregator::Message.new("ERROR", "#{e.message}:"+'def file_index_all()'+" #{e.backtrace.inspect}").publish
			end
		end

		def user_get
			begin
				EventAggregator::Message.new("StorageUserGet", nil).request
			rescue Exception => e
				EventAggregator::Message.new("ERROR", "#{e.message}:"+'def user_get'+" #{e.backtrace.inspect}").publish
			end
		end
		def token_get #TODO: Consider removing this. I do not think it is needed ever in the gui. At least not if we move the login-stuff to the gem in stead of in the tide-sdk js frontend
			begin
				EventAggregator::Message.new("StorageTokenGet", nil).request	
			rescue Exception => e
				EventAggregator::Message.new("ERROR", "#{e.message}:"+'def token_get'+" #{e.backtrace.inspect}").publish
			end
		end

		def user_set(user)
			begin
				EventAggregator::Message.new("StorageUserSet", user).publish
			rescue Exception => e
				EventAggregator::Message.new("ERROR", "#{e.message}:"+'def user_set(user)'+" #{e.backtrace.inspect}").publish
			end
		end
		def token_set(token)
			begin
				EventAggregator::Message.new("StorageTokenSet", token).publish
			rescue Exception => e
				EventAggregator::Message.new("ERROR", "#{e.message}:"+'def token_set(token)'+" #{e.backtrace.inspect}").publish
			end
		end

		def storage_reset(data)
			begin
				EventAggregator::Message.new("StorageReset", data).publish
			rescue Exception => e
				EventAggregator::Message.new("ERROR", "#{e.message}:"+'def storage_reset(token)'+" #{e.backtrace.inspect}").publish
			end
		end

		def dump
			EventAggregator::Message.new("FileRegisterDump", nil).publish
			EventAggregator::Message.new("StorageDump"     , nil).publish
		end
		# #TODO: look into http://libcodes.com/codes/jquery-document-viewerjavascript for previewing documents

		def open_file(path)
			EventAggregator::Message.new("FileOpen", path).publish
		end
	end
end
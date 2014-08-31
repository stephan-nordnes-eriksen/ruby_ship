module KonjektClient::Core
	class Startup
		include EventAggregator::Listener

		@file_indexer             = nil
		@file_register            = nil
		@file_system_watcher      = nil
		@gui                      = nil
		@recommendation_generator = nil
		@server_connector         = nil
		@storage                  = nil
		@utils                    = nil
		@logger                   = nil

		#TODO: consider getting a parameter here which is the stuff that is needed to talk to the JS frontend.
		def initialize
			@utils                    = KonjektClient::Core::Utils                   .new
			@storage                  = KonjektClient::Core::Storage                 .new
			@file_indexer             = KonjektClient::Core::FileIndexer             .new
			@file_register            = KonjektClient::Core::FileRegister            .new
			@file_system_watcher      = KonjektClient::Core::FileSystemWatcher       .new #TODO: This component is not ready yet.
			@gui                      = KonjektClient::Core::GUI                     .new
			@recommendation_generator = KonjektClient::Core::RecommendationGenerator .new
			@server_connector         = KonjektClient::Core::ServerConnector         .new
			@message_router           = KonjektClient::Core::MessageRouter           .new
			#@logger                   = KonjektClient::Core::Logger                  .new
			
			message_type_register("TestFirstTimeStartup" , method(:first_time_startup))
			
			homes = ["HOME", "HOMEPATH"]
			@realHome = homes.detect {|h| ENV[h] != nil}

			EventAggregator::Message.new("LogInTry", nil).publish
		end


		def file_indexer
			@file_indexer
		end
		def file_register
			@file_register
		end
		def file_system_watcher
			@file_system_watcher
		end
		def gui
			@gui
		end
		def recommendation_generator
			@recommendation_generator
		end
		def server_connector
			@server_connector
		end
		def storage
			@storage
		end
		def utils
			@utils
		end
		def message_router
			@message_router
		end
		def logger
			@logger
		end


		def first_time_startup(data)
			if EventAggregator::Message.new("StorageFirstTimeStartup?", nil).request
				add_initial_directories
				EventAggregator::Message.new("IndexAllFiles", nil).publish
				EventAggregator::Message.new("StorageFirstTimeStartupSet", true).publish
				#Little bit of hack to auto-add the home dir if no dir is found.
			elsif EventAggregator::Message.new("StorageDirectoriesGet", nil).request == nil
				add_initial_directories
			end
			#TODO: Add shit here to continue a half-finished index.
		end

		def add_initial_directories
			#TODO: This could be done more intelligently in the case where the user has more than one drive. For now, it's ok.
			folders = []
			f = ""
			
			f = File.join(ENV[@realHome], "Konjekt")
			f.untaint
			FileUtils.mkdir_p(f) unless File.directory?(f)
			#iconize_konjekt_folder(f)
			folders << f
			folders << f if File.directory?((f = File.join(ENV[@realHome], "Downloads")).untaint)
			folders << f if File.directory?((f = File.join(ENV[@realHome], "Movies")).untaint) #osx
			folders << f if File.directory?((f = File.join(ENV[@realHome], "Videos")).untaint) #win
			folders << f if File.directory?((f = File.join(ENV[@realHome], "Pictures")).untaint) #Win + osx
			folders << f if File.directory?((f = File.join(ENV[@realHome], "Desktop")).untaint) #win + osx
			folders << f if File.directory?((f = File.join(ENV[@realHome], "Documents")).untaint) # win + osx
			folders << f if File.directory?((f = File.join(ENV[@realHome], "Music")).untaint) # win + osx

			folders << f if File.directory?((f = File.join(ENV[@realHome], "Dropbox")).untaint)
			folders << f if File.directory?((f = File.join(ENV[@realHome], "SkyDrive")).untaint)
			folders << f if File.directory?((f = File.join(ENV[@realHome], "OneDrive")).untaint)
			folders << f if File.directory?((f = File.join(ENV[@realHome], "Box Documents")).untaint)
			
			EventAggregator::Message.new("FolderWatchAdd", folders).publish
		end
		def iconize_konjekt_folder(path)
			if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
				#Don't know yet.
			elsif RbConfig::CONFIG['host_os'] =~ /darwin/
				Kernel.system %{Rez -append Resources/tmpicns.rsrc -o $'#{path}\\r'} #Or something. not working yet.
				Kernel.system %{SetFile -a C #{path}}
			elsif RbConfig::CONFIG['host_os'] =~ /linux|bsd/
				#Don't know yet.
			end
			# # Append a resource to the folder you want to icon-ize.
			# Rez -append tmpicns.rsrc -o $'myfolder/Icon\r'

			# # Use the resource to set the icon.
			# SetFile -a C myfolder/

			# # Hide the Icon\r file from Finder.
			# SetFile -a V $'myfolder/Icon\r'
		end
	end
end

module KonjektClient::Core
	class Storage
		include EventAggregator::Listener

		@@konjekt_store = nil
		@@pstorer = nil
		def initialize
			@@mutex = Mutex.new
			
			homes = ["HOME", "HOMEPATH"]
			@realHome = homes.detect {|h| ENV[h] != nil}

			f = File.join(ENV[@realHome], "Konjekt")
			f.untaint
			FileUtils.mkdir_p(f) unless File.directory?(f)

			f = File.join(ENV[@realHome], "Konjekt", ".cache")
			f.untaint
			FileUtils.mkdir_p(f) unless File.directory?(f)

			@@konjekt_store = File.join(f, 'konjekt.store') #"konjekt.store"

			@@pstorer = PStore.new(@@konjekt_store)
			message_type_register("StorageTokenSet"           , method(:token_set))
			message_type_register("StorageUserSet"            , method(:user_set))
			message_type_register("StorageDirectoriesSet"     , method(:directories_set))
			message_type_register("StorageVersionSet"         , method(:version_set))
			message_type_register("StorageFirstTimeStartupSet", method(:first_time_set))
			message_type_register("StorageReset"              , method(:reset))
			message_type_register("StorageDump"               , method(:dump))

			producer_register("StorageTokenGet"          , lambda{|e| token_get()})
			producer_register("StorageUserGet"           , lambda{|e| user_get()})
			producer_register("StorageDirectoriesGet"    , lambda{|e| directories_get()})
			producer_register("StorageVersionGet"        , lambda{|e| version_get()})
			producer_register("StorageFirstTimeStartup?" , lambda{|e| first_time_get()})

			verify_version
		end

		def user_get
			user = ""
			@@mutex.synchronize{
				@@pstorer.transaction do
					user = @@pstorer[:user]
				end
			}
			return user
		end
		def user_set(user)
			#return nil unless user && user != "" #wan't to be able to set it to nil
			@@mutex.synchronize{
				@@pstorer.transaction do
					@@pstorer[:user] = user
				end
			}
			return user
		end
		def token_get
			token = ""
			@@mutex.synchronize{
				@@pstorer.transaction do
					token = @@pstorer[:token]
				end
			}
			return token
		end
		def token_set(token)
			#return nil unless token && token != "" #No. We want to be able to set it to nil
			@@mutex.synchronize{
				@@pstorer.transaction do
					@@pstorer[:token] = token
				end
			}
			return token
		end
		def version_get
			version = ""
			@@mutex.synchronize{
				@@pstorer.transaction do
					version = @@pstorer[:version]
				end
			}
			return version
		end
		def version_set(version)
      return nil unless version && version != ""
			@@mutex.synchronize{
				@@pstorer.transaction do
					@@pstorer[:version] = version
				end
			}
			return version
		end
		def directories_get
			directories = ""
			@@mutex.synchronize{
				@@pstorer.transaction do
					directories = @@pstorer[:directories]
				end
			}
			return directories
		end
		def directories_set(directories)
			return nil unless directories && directories != ""
			@@mutex.synchronize{
				@@pstorer.transaction do
					@@pstorer[:directories] = directories
				end
			}
			return directories
		end

		def first_time_get
			first_time = true
			@@mutex.synchronize{
				@@pstorer.transaction do
					first_time = @@pstorer[:first_time]
				end
			}
			return first_time
		end
		def first_time_set(first_time)
			return nil unless first_time == false || first_time == true
			@@mutex.synchronize{
				@@pstorer.transaction do
					@@pstorer[:first_time] = first_time
				end
			}
			return first_time
		end

		def reset(data)
			if data == "HARD"
				@@mutex.synchronize{
					@@pstorer.transaction do
						rooties = @@pstorer.roots
						rooties.each do |root|
							@@pstorer.delete(root)
						end
					end
				}
			end
		end
		
		def dump(data)
			data = nil
			@@mutex.synchronize{
				@@pstorer.transaction do
					data = @@pstorer.inspect
				end
			}
			EventAggregator::Message.new("debug",data).publish
		end

		def verify_version
			version = version_get()
			if !version.is_a?(String) || version < "0.1.0"
				reset("HARD")
				version_set("0.1.0")
			end
		end
	end
end
module KonjektClient::Core
	class Utils
		include EventAggregator::Listener

		@dropbox_folde = nil
		@host = nil
		#def initialize(host="http://dev.konjekt.com") #="http://192.168.1.170:3000"#home laptop
		# def initialize(host="https://konjekt.com")
		def initialize(host="http://192.168.1.170:2998")
			#@host = "https://konjekt.com" #TODO: Move this to somewhere
			@host = host
			message_type_register("FileOpen" , method(:file_open))

			producer_register("GetMACAddress"       , lambda{|e| get_mac_address()})
			producer_register("GetDropboxFolderPath", lambda{|e| get_dropbox_folder(e)})
			producer_register("GeoLocationGet"      , lambda{|e| geo_location_get(e)})
			producer_register("CurrentTimeGet"      , lambda{|e| current_time_get(e)})
			producer_register("Ping"                , lambda{|e| ping(e)})
			producer_register("Host"                , lambda{|e| host()})
			producer_register("HasInternet?"        , lambda{|e| has_internet?()})
			producer_register("IsLoggedIn?"         , lambda{|e| is_logged_in?()})
			producer_register("GetOperatingSystem"  , lambda{|e| get_operating_system()})
			
		end

		def file_open(file)
			if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
				Kernel.system %{start #{file}}
			elsif RbConfig::CONFIG['host_os'] =~ /darwin/
				Kernel.system %{open "#{file}"}
			elsif RbConfig::CONFIG['host_os'] =~ /linux|bsd/
				Kernel.system %{xdg-open "#{file}"}
			end
		end

		def get_mac_address()
			return Mac.addr
		end

		def dropbox_folde
			@dropbox_folde
		end

		def get_dropbox_folder(data)
			if !@dropbox_folder || @dropbox_folder == ""  || !File.exist?(@dropbox_folder)
				Dir.glob(File.join( "", "**", ".dropbox.cache" ) ).each do |x|
					@dropbox_folder = x.slice( File.join("",".dropbox.cache" ) )
					break
				end
			end
			return @dropbox_folder
		end

		# Public: Will provide a location object indicating your geo-location and more.
		#
		# data - Your remote ip, if any.
		#
		# Returns location object telling where you are and more.
		def geo_location_get(data)
			#TODO: This should be moved to an external thingimagig
			remote_ip =  data ? data : open('http://whatismyip.akamai.com').read  #This can be on our neugle server
			#To make your own of this, what follows is the entire rack server
			# A server than can provide what the link above does
			# run lambda { |env|
			# 	remote_ip = env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_ADDR']
			# 	remote_ip = remote_ip.scan(/[\d.]+/).first
			# 	[ 200, {'Content-Type'=>'text/plain'}, [remote_ip] ]
			# }
			location = Geocoder.search(remote_ip) #TODO: Verify this
		end


		# Public: Returns string of the current time.
		#
		# data -Nothing. Just there for the EventAggregator.
		#
		# Returns a string of the current time.
		def current_time_get(data)
			return Time.new.inspect
		end

		def ping(token)
			return nil unless token
			d = "server not found"
			
			begin
				status = Timeout::timeout(15) {
					path = @host+'/api/utils/ping.json?auth_token='+token
					uri = URI.parse(path)
					http = Net::HTTP.new(uri.host, uri.port)
					http.use_ssl = (uri.scheme == "https")
					http.verify_mode = OpenSSL::SSL::VERIFY_PEER
					
					request = Net::HTTP::Get.new(uri.request_uri)
					request["Content-Type"] = "application/json"
					res = http.request(request)
					if res && defined?(res.body) 
						if res.body == '{"success":true,"respone":true}'
							d = "success" 
						else
							d = "failure"
						end
					else
						d = "error" #Something went wrong :(
					end
				}
				if !status || status.is_a?(Exception)
					if has_internet?
						d = "Konjekt servers down"
						EventAggregator::Message.new("ERROR", "Problem with Konjekt Servers").publish
					else
						d = "Network is unreachable"
						EventAggregator::Message.new("ERROR", "Problem with your internet connection").publish
					end
				end
			rescue Exception => e
				if has_internet?
					d = "Konjekt servers down"
					EventAggregator::Message.new("ERROR", "Problem with Konjekt Servers").publish
				else
					d = "Network is unreachable"
					EventAggregator::Message.new("ERROR", "Problem with your internet connection").publish
				end
			end
			return d
		end

		def host
			return @host
		end

		#This can be a good alternative because of DNS caching.
		# def has_internet?
		# 	begin
		# 		ret = false
		# 		status = Timeout::timeout(15) {
		# 			ret = true if open("http://www.google.com/")
		# 		}
		# 		return ret
		# 	rescue
		# 		return false
		# 	end
		# end

		def has_internet?
			require "resolv"
			dns_resolver = Resolv::DNS.new()
			begin
				dns_resolver.getaddress("symbolics.com")#the first domain name ever. Will probably not be removed ever.
				return true
			rescue Resolv::ResolvError => e
				return false
			end
		end
		#look into pinging :
		# letter = "a"
		# while letter <= "m"
		# ping "#{letter}.root-servers.net"

		# letter = letter.next
		# end

		def is_logged_in?
			token = EventAggregator::Message.new("StorageTokenGet", nil).request

			return ping(token) == "success"
		end

		def get_operating_system
			case RbConfig::CONFIG['host_os']
			when /mswin|mingw|cygwin/
				'win'
			when /darwin/
				'osx'
			when /linux|bsd/
				'linux'
			else
				'unknown'				
			end
		end
	end
end
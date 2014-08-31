module KonjektClient::Core
	class ServerConnector
		include EventAggregator::Listener

		def initialize
			@host = EventAggregator::Message.new("Host", nil).request
			@token = nil
			set_token

			message_type_register("LogIn"                      , method(:receive_log_in))
			message_type_register("LogInToken"                 , method(:receive_log_in_token))
			message_type_register("LogInTry"                   , method(:receive_log_in_try))
			message_type_register("LogOut"                     , method(:receive_log_out))
			message_type_register("StringSearch"               , method(:receive_string_search))
			message_type_register("TokenSet"                   , method(:receive_token_set))
			message_type_register("SendToServerFileIndexArray" , method(:receive_file_indexed_array))
			message_type_register("RecommendFilesRequest"      , method(:receive_recommend_files_request))

			producer_register("IsLoggedIn?"         , lambda{|e| is_logged_in?()})
		end

		def receive_log_in(data)
			if data && data.is_a?(Hash) && data[:user_name] && data[:user_name].is_a?(String) && data[:user_name] != "" && data[:password] && data[:password].is_a?(String) && data[:password] != ""
				login(data[:user_name], data[:password])
			else
				EventAggregator::Message.new("LogInError", nil).publish
				return nil
			end
		end

		def receive_log_out(data)
			#Net::HTTP.get(@host, )
		end

		def receive_log_in_try(data)
			token = EventAggregator::Message.new("StorageTokenGet", nil).request
			#user = EventAggregator::Message.new("StorageUserGet", nil).request
			receive_log_in_token({:token => token})
		end
		#Don't think I have tested this one:
		def receive_log_in_token(data)
			check_and_fix_login?(data[:token])
		end

		def login(user, password)
			res = login_SSL(user, password)
			if res && res.code == '200' && defined?(res.body) && res.body.is_a?(String)
				EventAggregator::Message.new("LoggedIn", "#{user}").publish

				body = res.body.parse_json_or_nil

				EventAggregator::Message.new("StorageUserSet", user).publish #TODO: Remove email from this, and use the user-parameter in stead. res.body["email"]
				@token = body["auth_token"]
				EventAggregator::Message.new("StorageTokenSet", @token).publish
				return res
			end
			returner = res && defined?(res.body) ? res.body : nil
			EventAggregator::Message.new("LogInError", returner).publish
			return nil
		end


		def receive_string_search(query)
			set_token
			res = string_search_send(query)

			if !res || res.code != '200' || !defined?(res.body) || !res.body.is_a?(String)
				if res
					EventAggregator::Message.new("debug", "Error with search. #{res.code}___#{res.body}").publish
				else
					EventAggregator::Message.new("debug", "Error with search. Got nil").publish
				end

				check_and_fix_login? if res
				return nil
			end
			body = res.body.parse_json_or_nil
			EventAggregator::Message.new("SearchResults", body).publish
			return res
		end

		def receive_token_set(token)
			@token = token
		end

		def set_token
			@token = EventAggregator::Message.new("StorageTokenGet", nil).request unless @token
		end

		def receive_file_indexed_array(file_array)
			set_token

			files_no_file_path = {:files => file_array.map{|f| f.reject{|k,_| k==:file_path}} }
			res = index_file_array_execute(files_no_file_path)
			
			if !res || res.code != '200'
				EventAggregator::Message.new("debug", "Res_code: #{res.code}. #{res.inspect}").publish if res
				EventAggregator::Message.new("debug", "There were no res...").publish if !res
				check_and_fix_login? if res
				return nil
			end
			
			body = defined?(res.body) ? res.body.parse_json_or_nil : nil

			if body && body["file_ids"]
				if body["file_ids"].count == file_array.count	
					path_to_id_list = body["file_ids"].each_with_index.map do |id, index|
						[file_array[index], id]
					end
					EventAggregator::Message.new("FileIndexStoredToServerArray", path_to_id_list).publish
				else
					#Somethin has gone horribly wrong. Mismatch between number of files from server and number of files from indexer
					begin
						EventAggregator::Message.new("debug", "If you see this, please notify us! Something went horribly wrong in the indexer. No worries though, we log, keep calm and carry on. But, please, contact us about this.").publish
						EventAggregator::Message.new("debug", "#{body.to_json}").publish
						
						throw "Something horribly wrong in receive_file_indexed_array!" #This logs it to a file for us.
					rescue Exception => e
						#I know, it sucks
						#It is now stored on the server, but is unusable because we have no clue which IDs should go where. This is a critical bug and must be dealt with if it ever occurs.

						#It might require a completely full reindex of every file ever.
					end
				end
			else
				EventAggregator::Message.new("FileIndexNotStoredToServerArray", file_array).publish
			end
			return body
		end

		def receive_recommend_files_request(data)
			set_token
			res = recommend_files_send(data)
			
			if !res || res.code != '200' || !defined?(res.body) || !res.body.is_a?(String)
				a = ""
				a = res.body if res && defined?(res.body)
				a += "__code: #{res.code}" if res && defined?(res.code)
				a += "__host: #{@host}"
				a += "__host: #{@token}"
				check_and_fix_login? if res
				EventAggregator::Message.new("ERROR", "Error with index: #{a}").publish
				return nil
			end
			EventAggregator::Message.new("SearchResults", res.body).publish
			return res.body
		end

		private

		def version
			return @version if @version

			@version = EventAggregator::Message.new("StorageVersionGet", nil).request
		end

		def check_and_fix_login?(token = nil)
			ping_res = get_ping_result(token)
			logged_in = false
			if ping_res == "success"
				user = EventAggregator::Message.new("StorageUserGet", nil).request
				EventAggregator::Message.new("LoggedIn", "#{user}").publish
				logged_in = true
			elsif ping_res == "Network is unreachable"
				EventAggregator::Message.new("debug", "Ohh no! You don't have an internet connection :(").publish
			elsif ping_res == "Konjekt servers down"
				EventAggregator::Message.new("debug", "Ohh no! Konjekt servers down! :( We are notified and should have it solved soon!").publish
				#TODO: notify about this. send email or something. Set up a silly hotmal that sends up email, like in the BibleGen project.
			else
				EventAggregator::Message.new("LogInRequest", nil).publish
			end

			return logged_in
		end

		def build_search_query(query)
			@host + '/api/search?qs='+query+'&auth_token='+@token
		end

		def string_search_send(query)
			return nil unless @token && @host
			return string_search_execute_SSL(query)
		end


		def string_search_execute_SSL(query)
			path =@host+'/api/search.json?qs='+ CGI::escape(query)+'&auth_token='+@token
			 
			path.untaint

			uri = URI.parse(path)
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = (uri.scheme == "https")
			http.verify_mode = OpenSSL::SSL::VERIFY_PEER

			request = Net::HTTP::Get.new(uri.request_uri)
			request["Content-Type"] = "application/json"

			begin
				(response = http.request(request)).untaint
			rescue Exception => e
				#Keep getting timeouts and stuff.
				return nil
			end

			return response
		end

		def login_SSL(user, password)
			path = "#{@host}/api/users/sign_in.json"

			uri = URI.parse(path)
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true if @host.include?("https")
			http.verify_mode = OpenSSL::SSL::VERIFY_PEER

			request = Net::HTTP::Post.new(uri.request_uri)
			request.body = '{"user_login": {"login": "'+user+'", "password": "'+password+'"}}'
			request["Content-Type"] = "application/json"
			response = http.request(request)
			return response
		end


		# Public: Will send an indexed file to the server for storing.
		#
		# index - a hash on the following format: {file: "path_name/file_id", conecepts: [["concept1", 1.3132],["concept2", 0.13223]]}
		#
		# Returns the duplicated String.
		#
		def index_file_execute(index)
			path = pad_path('/api/index_storage/file.json')	
			return nil if !path.is_a?(String)
			path.untaint
			send_to_server(path,index)
		end

		def index_file_array_execute(index)
			path = pad_path('/api/index_storage/file_bulk.json')
			return nil if !path.is_a?(String)
			path.untaint
			send_to_server(path, index)
		end

		def recommend_files_send(data)
			path = pad_path('/api/search/recommend.json')
			return nil if !path.is_a?(String)
			path.untaint
			send_to_server(path, data)
		end

			private
			def pad_path(path)
				return nil unless @token && @host

				@host + path + '?&auth_token=' + @token
			end

			def send_to_server(path, data)
				return nil unless path

				uri = URI.parse(path)
				http = Net::HTTP.new(uri.host, uri.port)
				http.use_ssl = (uri.scheme == "https")

				http.verify_mode = OpenSSL::SSL::VERIFY_PEER
				request = Net::HTTP::Post.new(uri.request_uri)
				
				request.body = data.to_json
				request["Content-Type"] = "application/json"

				begin
					(response = http.request(request)).untaint
				rescue Exception => e
					#Keep getting timeouts and stuff.
					return nil
				end

				return response
			end

			def is_logged_in?(token = nil)
				get_ping_result(token) == "success"
			end

			def get_ping_result(token = nil)
				unless token
					set_token 
					token = @token
				end
				return EventAggregator::Message.new("Ping", token).request
			end
	end
end

class String
	def is_json?
		begin
			!!JSON.parse(self)
		rescue
			false
		end
	end
	def parse_json_or_nil
		begin
			JSON.parse(self)
		rescue
			nil
		end
	end
end
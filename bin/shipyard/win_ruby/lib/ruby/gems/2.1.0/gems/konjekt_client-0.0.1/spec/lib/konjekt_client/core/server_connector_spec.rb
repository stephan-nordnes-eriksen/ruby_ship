require 'spec_helper'

describe KonjektClient::Core::ServerConnector do
	let(:server_connector)   { KonjektClient::Core::ServerConnector.new }

	let(:random_string)      { Faker::Internet.password }
	let(:random_number)      { Faker::Number.number(rand(9)).to_i }

	let(:user_name)          { Faker::Internet.user_name }
	let(:password)           { Faker::Internet.password }
	let(:token)              { "validtoken" }
	let(:invalid_token)      { "ilvalidtoken" }
	let(:search_result)      { '{"file": 1.0332, "file2": 0.223 }' }

	let(:file_index)         { {:file_path => Faker::Internet.password, :concepts => [[Faker::Internet.password,rand(0.0..5.0)],[Faker::Internet.password, rand(0.0..5.0)]]} }
	let(:file_index_return)  { '{"success":true,"respone":true,"file_id":8}' }
	let(:host)               { "https://konjekt.com" }
	let(:recommend_context)  { {:qs => "query statement", :lc => "location(in string)", :dt => "date", :tm => "time", :cx => "context"} }

	before(:each) do
		EventAggregator::Aggregator.reset

		#TODO: Mock the actual server connection.
		u = KonjektClient::Core::Utils.new()
		u.stub(:host) { "https://konjekt.com" }

		@s = OpenStruct.new()
		
		KonjektClient::Core::Storage.stub(:new) { @s }
		
		@s.stub(:token_get) { token }
		@s.stub(:user_get)  { user_name }


		stub_request(:any, host)
		stub_request(:post, host).
		with(:body => /^.*world$/, :headers => {"Content-Type" => /image\/.+/}).
		to_return(:body => '{"abc": "file_path"}')


		# stub_request(:get, "https://konjekt.com/api/search?auth_token=whatever&qs=estaccusamusiure").
		# with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
		# to_return(:status => 200, :body => "", :headers => {})

		stub_request(:get, "www.example.com").
		with(:query => {"a" => ["b", "c"]})
		# RestClient.get("http://www.example.com/?a[]=b&a[]=c") #success


		# @search_request_stub = stub_request(:get, /https:\/\/konjekt\.com\/api\/search\?qs\=.+\&auth_token\=.+/).
		# with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
		# to_return(:status => 200, :body => '{"file": 1.0332, "file2": 0.223 }', :headers => {})


		# stub_request(:get, "https://konjekt.com/api/search?auth_token=validtoken&qs=consequaturculpacumque").[0m
		# with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json'}).
		# to_return(:status => 200, :body => "", :headers => {})


		# @login_post_stub = stub_request(:post, /http:\/\/konjekt\.com:443\/users\/sign\_in/).
		# with(:body => /\{user\_login": \{login: .+\, password: .+\}\}/,:headers => {'Content-Type'=>'application/json'}).
		# to_return(:status => 200, :body => '{"success":true,"auth_token":"'+token+'"}', :headers => {})
		
		@login_post_stub = stub_request(:post, /https:\/\/konjekt\.com\/api\/users\/sign\_in\.json/).
		with(:body => "{\"user_login\": {\"login\": \"#{user_name}\", \"password\": \"#{password}\"}}", 
			:headers => {'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
		to_return(:status => 200, :body => '{"success":true,"auth_token":"'+token+'"}', :headers => {})
		

		@login_post_fail_stub = stub_request(:post, /https:\/\/konjekt\.com\/api\/users\/sign\_in\.json/).
		with(:body => "{\"user_login\": {\"login\": \"#{user_name}\", \"password\": \"#{password+ " fail"}\"}}", 
			:headers => {'Content-Type'=>'application/json'}).
		to_return(:status => 401, :body => '{"success":false,"message":"Error with your login or password"}', :headers => {})


		@search_request_stub = stub_request(:get, /https:\/\/konjekt\.com\/api\/search\.json\?auth_token\=.+\&qs\=.+/).
		with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
		to_return(:status => 200, :body => search_result, :headers => {})

		@file_index_post_stub = stub_request(:post, /https:\/\/konjekt\.com\/api\/index_storage\/file\.json\?auth_token\=.+/).
		with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}, :body =>file_index.to_json).
		to_return(:status => 200, :body => file_index_return, :headers => {})

		@request_recommend_get_stub = stub_request(:post, /https:\/\/konjekt\.com\/api\/search\/recommend\.json\?auth_token\=.+/).
		with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}, :body => recommend_context.to_json).
		to_return(:status => 200, :body => search_result, :headers => {})

		stub_request(:any, /.+ilvalidtoken.+/).to_return(:status => 404)
	end

	#TODO: Look into using gem rest-client:
	# http://rubydoc.info/gems/rest-client/1.6.7/frames
	# https://github.com/rest-client/rest-client
	# and
	# require 'oauth'


	describe ".initialize" do
		it "message type signup" do
			expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("Host") }
			expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageTokenGet") }

			expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("LogIn") }
			expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("LogInToken") }
			expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("LogInTry") }
			expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("LogOut") }
			expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("StringSearch") }
			expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("TokenSet") }
			expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("SendToServerFileIndex") }
			expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("SendToServerFileIndexArray") }
			expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("RecommendFilesRequest") }


			#Can potentially move to this way: however, would like to be able to check that the fisrt argument is the object-in-question.
			#expect(EventAggregator::Aggregator).to receive(:register).with(kind_of(EventAggregator::Listener), "StringSearch", kind_of(Proc))

			KonjektClient::Core::ServerConnector.new
		end
	end
	describe ".receive_log_in" do
		describe "valid parameters" do
			it "call .login" do
				expect(server_connector).to receive(:login).with(user_name, password)
				server_connector.receive_log_in({:user_name => user_name, :password => password})

				#server_connector.receive_log_in([user_name, password, nil]) #Is this ok?
				#server_connector.receive_log_in([user_name, password, ""]) #Is this ok?
				#server_connector.receive_log_in([user_name, password, random_string]) #Is this ok?
				#server_connector.receive_log_in([user_name, password, random_number]) #Is this ok?
			end
		end
		describe "valid parameters" do
			it "does not call login" do
				expect(server_connector).to_not receive(:login)

				#Invalid data format
				server_connector.receive_log_in([user_name])
				server_connector.receive_log_in([password])
				server_connector.receive_log_in(user_name)
				server_connector.receive_log_in(random_string)
				server_connector.receive_log_in(random_number)
				server_connector.receive_log_in(nil)
				server_connector.receive_log_in({:user_name => user_name})
				server_connector.receive_log_in({:password => password})
				server_connector.receive_log_in({:user_name => user_name, :whatevs => password})
				server_connector.receive_log_in({:password => password, :whatevxex => password})

				#Invalid data values
				server_connector.receive_log_in({:user_name => nil      , :password => nil})
				server_connector.receive_log_in({:user_name => ""       , :password => ""})
				server_connector.receive_log_in({:user_name => user_name, :password => nil})
				server_connector.receive_log_in({:user_name => user_name, :password => ""})
				server_connector.receive_log_in({:user_name => nil      , :password => password})
				server_connector.receive_log_in({:user_name => ""       , :password => password})
				
				#Invalid object-types
				server_connector.receive_log_in({:user_name => random_number, :password => password})
				server_connector.receive_log_in({:user_name => user_name    , :password => random_number})
				server_connector.receive_log_in({:user_name => random_number, :password => random_number})
				server_connector.receive_log_in({:user_name => user_name    , :password => Object.new})
				server_connector.receive_log_in({:user_name => Object.new   , :password => password})
			end
		end
	end
	describe ".login" do
		describe "valid parameters" do
			it "makes login http post" do
				@login_post_stub.should_not have_been_requested
				server_connector.login(user_name, password)
				@login_post_stub.should have_been_requested
			end
			it "sends LoggedIn message" do
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("LoggedIn")}
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("StorageUserSet")}
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("StorageTokenSet")}
				
				server_connector.login(user_name, password)
			end
			it "sends LoggedIn message" do
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("LoggedIn") and expect(message.data).to be(user_name) }
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("StorageUserSet")}
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("StorageTokenSet")}
				
				server_connector.login(user_name, password)
			end
		end
		describe "invalid parameters" do
			it "sends LogInError message" do
				server_connector.receive_token_set(token)
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("LogInError") }
				server_connector.login(user_name, password+" fail")
			end
		end
	end


	describe ".search" do
		describe "valid parameters" do
			it "makes search http get" do
				server_connector.receive_token_set(token)
				@search_request_stub.should_not have_been_requested
				server_connector.receive_string_search(random_string)
				@search_request_stub.should have_been_requested
			end
			it "sends SearchResults message" do
				server_connector.receive_token_set(token)
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("SearchResults")}
				server_connector.receive_string_search(random_string)
			end
		end
		describe "invalid parameters" do
			pending "not implemented"
		end
	end

	#TODO: probably more here which I can't think of right now.
	describe ".receive_file_indexed" do
		describe "valid parameters" do
			it "post request" do
				server_connector.receive_token_set(token)
				@file_index_post_stub.should_not have_been_requested
				server_connector.receive_file_indexed(file_index)
				@file_index_post_stub.should have_been_requested
			end
			it "returns true" do
				server_connector.receive_token_set(token)
				expect(server_connector.receive_file_indexed(file_index)).to eq(JSON.parse(file_index_return))
			end
			it "sends FileIndexStoredToServer on success" do
				server_connector.receive_token_set(token)
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("FileIndexStoredToServer") and expect(message.data).to eq([file_index,8]) }
				server_connector.receive_file_indexed(file_index)
			end
		end
		describe "invalid parameters" do
			pending "not implemented"
		end
	end


	#TODO: Consider using FakeWeb to mock the web-requests
	describe "Token related" do
		describe "no auth token" do
			it "returns nil" do #OR should it be raising errors?
				@s.stub(:token_get) { nil }#server_connector.receive_token_set(nil)

				expect(server_connector.receive_string_search(random_string)).to be(nil)
			end
		end
		describe "invalid/old token" do
			it "returns nil" do
				#server_connector.receive_token_set(invalid_token)
				@s.stub(:token_get) { token+" illegal" }

				expect(server_connector.receive_string_search("lol"))    .to be(nil) #This resets the token, due to awesome.
				expect(server_connector.receive_file_indexed(file_index)).to be(nil)
				#expect(server_connector.get_ip())                   .to be(nil)#TODO: this
			end
			it "send LogInRequest" do
				@s.stub(:token_get) { token+" illegal" }

				expect(EventAggregator::Aggregator).to receive(:message_publish).exactly(2).times { |message| expect(message.message_type).to eq("LogInRequest") }

				server_connector.receive_string_search("lol")
				server_connector.receive_file_indexed(file_index)
				#server_connector.get_ip()#TODO: this
			end
		end
	end

	describe ".receive_token_set" do
		it "sets token" do
			expect{server_connector.receive_token_set(random_string)}.to change{server_connector.instance_variable_get(:@token)}.from(nil).to(random_string)
		end
		it "sends StorageTokenSet message" do
			expect(EventAggregator::Aggregator).to receive(:message_publish).exactly(1).times { |message| expect(message.message_type).to eq("StorageTokenSet") }
			server_connector.receive_token_set(random_string)
		end
	end

	describe ".receive_recommend_files_request" do
		it "request recommend from server" do
			server_connector.receive_token_set(token)
			@request_recommend_get_stub.should_not have_been_requested
			server_connector.receive_recommend_files_request(recommend_context)
			@request_recommend_get_stub.should have_been_requested
			
		end
		it "publishes SearchResult" do
			server_connector.receive_token_set(token)
			expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("SearchResults") }
			server_connector.receive_recommend_files_request(recommend_context)
		end
	end

	describe ".receive_log_in_try" do
		it "requests token, ping and sends LoggedIn" do
			server_connector
			server_connector.receive_token_set(token)
			expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageTokenGet") }.and_return(token)
			expect(server_connector).to receive(:receive_log_in_token).with({:token => token})
			# expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("Ping") }.and_return('{"success":true,"respone":true}')
			# expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageUserGet") }.and_return(user_name)
			
			# expect(EventAggregator::Aggregator).to receive(:message_publish).exactly(1).times { |message| expect(message.message_type).to eq("LoggedIn") and expect(message.data).to eq(user_name)}
			
			server_connector.receive_log_in_try(nil)
		end
	end


	#This is not the server-connectors responsibility (I think. Might be to actually get the index-things from the server)
	# describe ".file_to_id" do
	# 	pending "not implemented"
	# end
	# describe ".id_to_file" do
	# 	pending "not implemented"
	# end
	# describe ".file_rename" do
	# 	pending "not implemented"
	# end
	# describe ".file_delete" do
	# 	pending "not implemented"
	# end
	# describe ".id_delete" do
	# 	pending "not implemented"
	# end
	# describe ".file_create" do
	# 	pending "not implemented"
	# end
	# describe ".store_to_file" do
	# 	pending "not implemented"
	# end
	# describe ".check_storage_concistency" do
	# 	pending "not implemented"
	# end
end
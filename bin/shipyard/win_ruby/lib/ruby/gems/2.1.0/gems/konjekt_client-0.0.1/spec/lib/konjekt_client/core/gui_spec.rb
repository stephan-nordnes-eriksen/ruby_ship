require 'spec_helper'

#We are now using TideSDK. This will be the adapter between Tide and the ruby gem.

describe KonjektClient::Core::GUI do
	let(:gui)                     { KonjektClient::Core::GUI.new }

	let(:user_name)               { Faker::Internet.user_name }
	let(:password)                { Faker::Internet.password }
	let(:token)                   { Faker::Internet.password }

	let(:message_search_results)  { EventAggregator::Message.new("SearchResults" , "data", false, false) }
	let(:message_logged_in)       { EventAggregator::Message.new("LoggedIn"      , "data", false, false) }
	let(:message_logged_out)      { EventAggregator::Message.new("LoggedOut"     , "data", false, false) }
	let(:message_connection_lost) { EventAggregator::Message.new("ConnectionLost", "data", false, false) }

	let(:random_string) { Faker::Internet.password }
	let(:random_number) { Faker::Number.number(rand(9)).to_i }

	before(:each) do
		EventAggregator::Aggregator.reset
	end

	describe 'Sends Messages' do
		describe ".log_in" do
			it "send LogIn message" do
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("LogIn") }
				gui.log_in(user_name, password)
			end
		end

		describe ".log_in_token" do
			it "send LogIn message" do
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("LogInToken") }
				gui.log_in_token(user_name, token)
			end
		end

		describe ".log_out" do
			it "send LogOut message" do
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("LogOut") }
				gui.log_out()
			end
		end

		describe ".recommend_files" do
			it "send RecommendFilesRequest message" do
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("RecommendFilesRequest") }
				gui.recommend_files()
			end
		end

		describe ".shutdown" do
			it "send Shutdown message" do
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("Shutdown") }
				gui.shutdown()
			end
		end

		describe ".string_search" do
			it "send StringSearch message" do
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("StringSearch") }
				gui.string_search(random_string)
			end
		end

		describe ".folder_watch_add" do
			it "send FolderWatchAdd message" do
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("FolderWatchAdd") }
				gui.folder_watch_add(random_string)
			end
		end
		describe ".folder_watch_remove" do
			it "send FolderWatchRemove message" do
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("FolderWatchRemove") }
				gui.folder_watch_remove(random_string)
			end
		end
		describe ".file_index" do
			it "send FolderWatchRemove message" do
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("FileIndex") ; expect(message.data).to eq(random_string) }
				gui.file_index(random_string)
			end
		end
		describe ".file_index_all" do
			it "send FolderWatchRemove message" do
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("FileIndexAll") }
				gui.file_index_all()
			end
		end
	end

	# describe ".initialize" do
	# 	it "message type signup" do
	# 		#NEW METHOD:
	# 		expect(EventAggregator::Aggregator).to receive(:register).with(kind_of(KonjektClient::Core::GUI), "SearchResults", kind_of(Method) ) #TODO: Maybe we can add method-name in here to verify the method?
	# 		expect(EventAggregator::Aggregator).to receive(:register).with(kind_of(KonjektClient::Core::GUI), "LoggedIn", kind_of(Method))
	# 		expect(EventAggregator::Aggregator).to receive(:register).with(kind_of(KonjektClient::Core::GUI), "LoggedOut", kind_of(Method))
	# 		expect(EventAggregator::Aggregator).to receive(:register).with(kind_of(KonjektClient::Core::GUI), "ConnectionLost", kind_of(Method))

	# 		#OLD METHOD:
	# 		#expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("SearchResults") }
	# 		#expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("LoggedIn") }
	# 		#expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("LoggedOut") }
	# 		#expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("ConnectionLost") }
	# 		KonjektClient::Core::GUI.new
	# 	end
	# end
	

	describe ".user_get" do
		it "sends StorageUserGet request" do
			expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageUserGet") }.and_return([user_name])
			gui.user_get
		end
		it "returns requested message data" do
			@storage = KonjektClient::Core::Storage.new
			@storage.stub(:user_get) { user_name }

			expect(gui.user_get).to eq(user_name)
		end
	end
	describe ".token_get" do
		it "sends StorageTokenGet request" do
			expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageTokenGet") }.and_return(token)
			gui.token_get
		end
		it "returns requested message data" do
			@storage = KonjektClient::Core::Storage.new
			@storage.stub(:token_get) { token }

			expect(gui.token_get).to eq(token)
		end
	end


	describe ".user_set" do
		it "sends StorageUserGet request" do
			expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("StorageUserSet") }
			gui.user_set(user_name)
		end
	end
	describe ".token_set" do
		it "sends StorageTokenGet request" do
			expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("StorageTokenSet") }
			gui.token_set(token)
		end
	end
	describe ".storage_reset" do
		it "sends StorageReset request" do
			expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("StorageTokenSet") }
			gui.token_set("lol")
		end
	end

	#This is now in the konjekt_tidesdk project.
	# describe "on receive message" do
	# 	describe "message_type SearchResults" do
	# 		it "should fire javascript frontend" do
	# 			#TODO: I don't know how to test this. It depends on running under TideSDK.
	# 			#The goal of the test is to verify that SearchResults causes a js-frontend update
	# 			pending "don't know how to implement"
	# 			#expect(something_to_happend)
	# 		end
	# 	end
	# 	describe "message_type LoggedIn" do
	# 		it "should fire javascript frontend" do
	# 			#TODO: I don't know how to test this. It depends on running under TideSDK.
	# 			#The goal of the test is to verify that LoggedIn causes a js-frontend update
	# 			pending "don't know how to implement"
	# 			#expect(something_to_happend)
	# 		end
	# 	end
	# 	describe "message_type LoggedOut" do
	# 		it "should fire javascript frontend" do
	# 			#TODO: I don't know how to test this. It depends on running under TideSDK.
	# 			#The goal of the test is to verify that LoggedOut causes a js-frontend update
	# 			pending "don't know how to implement"
	# 			#expect(something_to_happend)
	# 		end
	# 	end
	# 	describe "message_type ConnectionLost" do
	# 		it "should fire javascript frontend" do
	# 			#TODO: I don't know how to test this. It depends on running under TideSDK.
	# 			#The goal of the test is to verify that ConnectionLost causes a js-frontend update
	# 			pending "don't know how to implement"
	# 			#expect(something_to_happend)
	# 		end
	# 	end
	# end
end
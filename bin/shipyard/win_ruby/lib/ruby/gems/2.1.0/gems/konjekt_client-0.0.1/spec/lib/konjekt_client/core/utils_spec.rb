require 'spec_helper'

describe KonjektClient::Core::Utils do
	let(:utils)         { KonjektClient::Core::Utils.new("https://konjekt.com") }

	let(:random_string) { Faker::Internet.password }
	let(:random_number) { Faker::Number.number(rand(9)).to_i }
	let(:token)         { Faker::Internet.password }
	let(:host)          { "https://konjekt.com" }

	before(:each) do
		EventAggregator::Aggregator.reset
		Kernel.stub(:system)

		@ping_request = stub_request(:get, "#{host}/api/utils/ping.json?auth_token=#{token}").
         with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => '{"success":true,"respone":true}', :headers => {})

	end

	describe ".initialize" do
		it "message type signup" do
			expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("FileOpen") }
			# expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("TestFirstTimeStartup") }
			utils
		end
		it "producer signup" do
			expect(EventAggregator::Aggregator).to receive(:register_producer).with("GetMACAddress"       , kind_of(Proc))
			expect(EventAggregator::Aggregator).to receive(:register_producer).with("GetDropboxFolderPath", kind_of(Proc))
			expect(EventAggregator::Aggregator).to receive(:register_producer).with("GeoLocationGet"      , kind_of(Proc))
			expect(EventAggregator::Aggregator).to receive(:register_producer).with("CurrentTimeGet"      , kind_of(Proc))
			expect(EventAggregator::Aggregator).to receive(:register_producer).with("Ping"                , kind_of(Proc))
			expect(EventAggregator::Aggregator).to receive(:register_producer).with("Host"                , kind_of(Proc))
			expect(EventAggregator::Aggregator).to receive(:register_producer).with("HasInternet?"        , kind_of(Proc))
			expect(EventAggregator::Aggregator).to receive(:register_producer).with("IsLoggedIn?"         , kind_of(Proc))
			expect(EventAggregator::Aggregator).to receive(:register_producer).with("GetOperatingSystem"  , kind_of(Proc))
			utils
		end
	end

	describe ".file_open" do
		it "runs system command" do
			expect(Kernel).to receive(:system)
			utils.file_open(random_string)
		end
	end

	describe ".get_mac_addess" do
		it "runs system command" do
			expect(Mac).to receive(:addr)
			utils.get_mac_address()
		end
	end

	describe ".geo_location_get" do
		it "should invoke Geocoder.search" do
			Geocoder.stub(:search) { nil }
			expect(Geocoder).to receive(:search).with(random_number)
			utils.geo_location_get(random_number)
		end
	end


	describe ".get_dropbox_folder" do
		before(:each) do
			stubsome = "some_path_to_nothing.dropbox.cache"
			stubsome.stub(:slice) { "some_path_to_nothing.dropbox.cache" }
			Dir.stub(:glob) {[stubsome]}
		end
		it "should return string" do
			#pending "takes too long to compute. These are successfull now." #Fixed with stub. Works without as well, but takes FOREVER, basically
			expect(utils.get_dropbox_folder(nil))          .to be_a(String)
			expect(utils.get_dropbox_folder(random_number)).to be_a(String)
			expect(utils.get_dropbox_folder(random_string)).to be_a(String)
			expect(utils.get_dropbox_folder(Object.new))   .to be_a(String)
		end
		it "calls Dir.glob when data nil" do
			expect(Dir).to receive(:glob).with(File.join("", "**", ".dropbox.cache"))
			utils.get_dropbox_folder(nil)
		end
		it "calls Dir.glob when data random_number" do
			expect(Dir).to receive(:glob).with(File.join("", "**", ".dropbox.cache"))
			utils.get_dropbox_folder(random_number)
		end
		it "calls Dir.glob when data random_string" do
			expect(Dir).to receive(:glob).with(File.join("", "**", ".dropbox.cache"))
			utils.get_dropbox_folder(random_string)
		end
		it "calls Dir.glob when data new object" do
			expect(Dir).to receive(:glob).with(File.join("", "**", ".dropbox.cache"))
			utils.get_dropbox_folder(Object.new)
		end
	end

	
	describe ".get_operating_system" do
		it "should return string" do
			expect(utils.get_operating_system()).to be_a(String)
		end
		it "should return osx" do
			stub_const("RbConfig::CONFIG",{'host_os'=> "darwin"} )

			expect(utils.get_operating_system()).to eq("osx")
		end
		it "should return win, on mswin" do
			stub_const("RbConfig::CONFIG",{'host_os'=> "mswin"} )

			expect(utils.get_operating_system()).to eq("win")
		end
		it "should return win, on mingw" do
			stub_const("RbConfig::CONFIG",{'host_os'=> "mingw"} )

			expect(utils.get_operating_system()).to eq("win")
		end
		it "should return win, on cygwin" do
			stub_const("RbConfig::CONFIG",{'host_os'=> "cygwin"} )

			expect(utils.get_operating_system()).to eq("win")
		end
		it "should return linux" do
			stub_const("RbConfig::CONFIG",{'host_os'=> "linux"} )

			expect(utils.get_operating_system()).to eq("linux")
		end
		it "should return linux, on bsd" do
			stub_const("RbConfig::CONFIG",{'host_os'=> "bsd"})

			expect(utils.get_operating_system()).to eq("linux")
		end

		describe "returns unknown on other platforms" do
			it "rofl" do
				stub_const("RbConfig::CONFIG",{'host_os'=> "rofl"})

				expect(utils.get_operating_system()).to eq("unknown")
			end
			it "strange datatype" do
				stub_const("RbConfig::CONFIG",{'host_os'=> 1})

				expect(utils.get_operating_system()).to eq("unknown")
			end
		end
	end

	describe ".current_time_get" do
		it "invokes Time" do
			expect(Time).to receive(:new)
			utils.current_time_get(nil)
		end
		it "invokes Time.new.inspect" do
			a = double()
			Time.stub(:new){ a }
			expect(a).to receive(:inspect)
			utils.current_time_get(nil)
		end
		it "returns Time.new.inspect" do
			a = double()
			a.stub(:inspect) {"data"}
			Time.stub(:new){ a }
			expect(utils.current_time_get(nil)).to eq("data")
		end
	end

	describe ".first_time_startup" do
		it "sends StorageFirstTimeStartup? request" do
			pending "this has been moved."
			expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageFirstTimeStartup?") }.and_return(true)
			utils.first_time_startup(nil)
		end

		describe "StorageFirstTimeStartup? is true " do
			it "sends FolderWatchAdd and IndexAllFiles messages" do
				pending "this has been moved."
				expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageFirstTimeStartup?") }.and_return(true)
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("FolderWatchAdd") }
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("IndexAllFiles") }
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("StorageFirstTimeStartupSet") and expect(message.data).to eq(true)  }

				utils.first_time_startup(nil)
			end
		end
		describe "StorageFirstTimeStartup? is false " do
			it "sends FolderWatchAdd message" do
				pending "this has been moved."
				expect(EventAggregator::Aggregator).to     receive(:message_request) { |message| expect(message.message_type).to eq("StorageFirstTimeStartup?") }.and_return(false)
				expect(EventAggregator::Aggregator).to     receive(:message_request) { |message| expect(message.message_type).to eq("StorageDirectoriesGet") }
				expect(EventAggregator::Aggregator).to_not receive(:message_publish) { |message| expect(message.message_type).to eq("FolderWatchAdd") }
				utils.first_time_startup(nil)
			end
			it "sends IndexAllFiles message" do
				pending "this has been moved."
				expect(EventAggregator::Aggregator).to     receive(:message_request) { |message| expect(message.message_type).to eq("StorageFirstTimeStartup?") }.and_return(false)
				expect(EventAggregator::Aggregator).to     receive(:message_request) { |message| expect(message.message_type).to eq("StorageDirectoriesGet") }
				expect(EventAggregator::Aggregator).to_not receive(:message_publish) { |message| expect(message.message_type).to eq("IndexAllFiles") }
				utils.first_time_startup(nil)
			end
		end
	end

	describe ".ping" do
		it "sends pings to server" do
			@ping_request.should_not have_been_requested
			expect(utils.ping(token).body).to eq('{"success":true,"respone":true}')
			@ping_request.should have_been_requested
		end
	end
	describe ".host" do
		it "returns https://konjekt.com" do			
			expect(utils.host).to eq("https://konjekt.com")
		end
	end

	describe ".has_internet?" do
		it "Uses Resolv" do
			open_struct = OpenStruct.new()
			open_struct.stub(:getaddress) {true}
			Resolv::DNS.stub(:new) {open_struct}
			
			expect(Resolv::DNS).to receive(:new)
			expect(open_struct).to receive(:getaddress).with("symbolics.com")
			
			utils.has_internet?
		end
		it "returns true if Resolv not error" do
			open_struct = OpenStruct.new()
			open_struct.stub(:getaddress) {true}
			Resolv::DNS.stub(:new) {open_struct}
			
			expect(utils.has_internet?).to be(true)
		end
		it "returns false if Resolv error" do
			open_struct = OpenStruct.new()
			open_struct.stub(:getaddress) {raise Resolv::ResolvError.new()}
			Resolv::DNS.stub(:new) {open_struct}
			
			expect(utils.has_internet?).to be(false)
		end
	end

	describe ".is_logged_in?" do
		it "request StorageTokenGet" do
			expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageTokenGet") }.and_return(token)
			utils.is_logged_in?
		end
		it "request is true" do
			expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageTokenGet") }.and_return(token)
			expect(utils.is_logged_in?).to be(true)
		end
		it "runs ping" do
			expect(utils).to receive(:ping).with(token).and_return("false")
			expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageTokenGet") }.and_return(token)
			expect(utils.is_logged_in?).to be(false)
		end

		describe "returns false when" do
			it "illegal token" do
				expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageTokenGet") }.and_return(token+"illegal")
				expect(utils.is_logged_in?).to be(false)
			end
			it "token is nil" do
				expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageTokenGet") }.and_return(nil)
				expect(utils.is_logged_in?).to be(false)
			end
		end

		describe "invalid params" do
			it "ping and token nil" do
				expect(utils).to receive(:ping).and_return(nil)
				expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageTokenGet") }.and_return(nil)
				expect(utils.is_logged_in?).to be(false)
			end
			it "ping random number" do
				expect(utils).to receive(:ping).and_return(random_number)
				expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageTokenGet") }.and_return(nil)
				expect(utils.is_logged_in?).to be(false)
			end
			it "ping random string" do
				expect(utils).to receive(:ping).and_return(random_string)
				expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageTokenGet") }.and_return(nil)
				expect(utils.is_logged_in?).to be(false)
			end
			it "token random number" do
				expect(utils).to receive(:ping).and_return(nil)
				expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageTokenGet") }.and_return(random_number)
				expect(utils.is_logged_in?).to be(false)
			end
			it "token random string" do
				expect(utils).to receive(:ping).and_return(random_number)
				expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageTokenGet") }.and_return(random_string)
				expect(utils.is_logged_in?).to be(false)
			end
		end
	end
end
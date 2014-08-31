require 'spec_helper'

#TODO: This should be moved to the startup script
describe KonjektClient::Core::Storage do
	let(:storage)     { KonjektClient::Core::Storage.new }
	let(:user_name)   { Faker::Internet.user_name }
	let(:token)       { Faker::Internet.password }
	let(:version)     { "#{Faker::Number.number(rand(2))}.#{Faker::Number.number(rand(2))}.#{Faker::Number.number(rand(2))}" }
	let(:directories) { [Faker::Internet.password,Faker::Internet.password,Faker::Internet.password] }
	let(:first_time)  { [true, false].sample }
	let(:random_junk)     { [nil, false, true, Object.new, Faker::Number.number(rand(9)).to_i, Faker::Internet.password, Faker::Internet.user_name] }
		
	before(:each) do
		EventAggregator::Aggregator.reset

		@double_store = double().as_null_object
		@double_store.stub(:transaction).and_yield
		@double_store.stub(:[]).with(:user)        {user_name}
		@double_store.stub(:[]).with(:token)       {token}
		@double_store.stub(:[]).with(:directories) {directories}
		@double_store.stub(:[]).with(:first_time)  {first_time}
		@double_store.stub(:[]).with(:version)     {version}
		
		PStore.stub(:new) { @double_store }
	end

	describe ".initialize" do
		it "message type signup" do
			expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("StorageTokenSet") }
			expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("StorageUserSet") }
			expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("StorageDirectoriesSet") }
      expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("StorageVersionSet") }
      expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("StorageFirstTimeStartupSet") }
			expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("StorageVersionSet") }
			expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("StorageReset") }

			storage
		end
		it "initialize producers" do
			expect(EventAggregator::Aggregator).to receive(:register_producer).with("StorageTokenGet",          kind_of(Proc))
			expect(EventAggregator::Aggregator).to receive(:register_producer).with("StorageUserGet",           kind_of(Proc))
			expect(EventAggregator::Aggregator).to receive(:register_producer).with("StorageDirectoriesGet",    kind_of(Proc))
			expect(EventAggregator::Aggregator).to receive(:register_producer).with("StorageVersionGet",        kind_of(Proc))
			expect(EventAggregator::Aggregator).to receive(:register_producer).with("StorageFirstTimeStartup?", kind_of(Proc))
			

			storage
		end
		it "initializes pstore" do
			expect(PStore).to receive(:new).with( match(/.+konjekt\.store/) )

			storage
		end
		it "calls verify_version" do
			expect(@double_store).to receive(:[]).with(:version)#this is not good enough

			storage
			pending "how to test this?"
		end
	end

	describe ".user_get" do
		it "execute get procedure on pstore" do
			expect(@double_store).to receive(:transaction)

			expect(storage.user_get()).to eq(user_name)
		end
	end

	describe ".user_set" do
		describe "valid parameters" do
			it "execute set procedure on pstore" do
				expect(@double_store).to receive(:transaction)

				expect(@double_store).to receive(:[]=).with(:user, user_name+" different")
				
				storage.user_set(user_name+" different")
			end
		end
		describe "invalid parameters" do
			it "not execute set procedure on pstore" do
				@double_store
				expect(@double_store).to_not receive(:transaction)

				storage.user_set(nil)
				storage.user_set("")
			end
		end
	end

	describe ".token_get" do
		it "execute get procedure on pstore" do
			expect(@double_store).to receive(:transaction)
			#expect(@double_store).to receive(:[]).with(:token)

			expect(storage.token_get()).to eq(token)
		end
	end

	
	describe ".token_set" do
		describe "valid parameters" do
			it "execute set procedure on pstore" do
				expect(@double_store).to receive(:transaction)
				expect(@double_store).to receive(:[]=).with(:token, token + " different")

				storage.token_set(token + " different")
			end
		end
		describe "invalid parameters" do
			it "not execute set procedure on pstore" do
				expect(@double_store).to_not receive(:transaction)
				#expect(@double_store[]).to_not receive(:=).with(token)

				storage.token_set(nil)
				storage.token_set("")
			end
		end
	end

	describe ".version_get" do
		it "execute get procedure on pstore" do
			expect(@double_store).to receive(:transaction)
			
			expect(storage.version_get()).to eq(version)
		end
	end
	describe ".version_set" do
		describe "valid parameters" do
			it "execute set procedure on pstore" do
				expect(@double_store).to receive(:transaction)
				expect(@double_store).to receive(:[]=).with(:version, version + " different")

				storage.version_set(version + " different")
			end
		end
		describe "invalid parameters" do
			it "not execute set procedure on pstore" do
				expect(@double_store).to_not receive(:transaction)

				storage.version_set(nil)
				storage.version_set("")
			end
		end
	end




	describe ".directories_get" do
		it "execute get procedure on pstore" do
			expect(@double_store).to receive(:transaction)

			expect(storage.directories_get()).to eq(directories)
		end
	end

	describe ".directories_set" do
		describe "valid parameters" do
			it "execute set procedure on pstore" do
				expect(@double_store).to receive(:transaction)
				expect(@double_store).to receive(:[]=).with(:directories, directories << "different")
				

				storage.directories_set(directories << "different")
			end
		end
		describe "invalid parameters" do
			it "not execute set procedure on pstore" do
				expect(@double_store).to_not receive(:transaction)

				storage.directories_set(nil)
				storage.directories_set("")
			end
		end
	end

	describe ".first_time_set" do
		describe "valid parameters" do
			it "execute set procedure on pstore" do
				expect(@double_store).to receive(:transaction)
				expect(@double_store).to receive(:[]=).with(:first_time, !first_time)

				storage.first_time_set(!first_time)
			end
		end
		describe "invalid parameters" do
			it "not execute set procedure on pstore" do
				expect(@double_store).to_not receive(:transaction)

				storage.first_time_set(nil)
			end
		end
	end

	describe "producers" do
		describe "StorageTokenGet" do
			it "should return token" do
				expect(storage).to receive(:token_get)
				EventAggregator::Message.new("StorageTokenGet", nil).request
				#TODO: For some reason the one below does not work. It gives nil, not what we want.
				#expect(EventAggregator::Message.new("StorageTokenGet", nil).request()).to eq(token)
			end
		end
		describe "StorageUserGet" do
			it "should return user_name" do
				expect(storage).to receive(:user_get)
				EventAggregator::Message.new("StorageUserGet", nil).request()

				#expect(EventAggregator::Message.new("StorageUserGet", nil).request).to eq(user_name)
			end
		end
		describe "StorageDirectoriesGet" do
			it "should return directories" do
				expect(storage).to receive(:directories_get)
				EventAggregator::Message.new("StorageDirectoriesGet", nil).request()

				#expect(EventAggregator::Message.new("StorageUserGet", nil).request).to eq(user_name)
			end
		end
		describe "StorageVersionGet" do
			it "should return version" do
				expect(storage).to receive(:version_get)
				EventAggregator::Message.new("StorageVersionGet", nil).request()
			end
		end
		describe "StorageFirstTimeStartup?" do
			it "should return first_time" do
				expect(storage).to receive(:first_time_get)
				EventAggregator::Message.new("StorageFirstTimeStartup?", nil).request()

				#expect(EventAggregator::Message.new("StorageUserGet", nil).request).to eq(user_name)
			end
		end
	end

	describe ".reset" do
		it "resets the pstore if data is \"HARD\"" do
			expect(@double_store).to receive(:[]=).with(:user       , nil)
			expect(@double_store).to receive(:[]=).with(:token      , nil)
			expect(@double_store).to receive(:[]=).with(:directories, nil)
			expect(@double_store).to receive(:[]=).with(:first_time , nil)

			storage.reset("HARD")
		end
		it "does not reset store when data is not \"HARD\"" do
			expect(@double_store).to_not receive(:transaction)

			random_junk.each do |j|
				storage.reset(j) unless j == "HARD"
			end
		end
	end



	describe ".verify_version" do
		it "resets the pstore data if version is too old" do
			expect(@double_store).to receive(:version_get) {"0.0.0"}
			expect(@double_store).to receive(:reset).with("HARD")
			expect(@double_store).to receive(:version_set) {"0.1.0"}

			storage.verify_version()
		end
		it "resets the pstore data if version is nil" do
			expect(@double_store).to receive(:version_get) {nil}
			expect(@double_store).to receive(:reset).with("HARD")

			storage.verify_version()
		end
		it "resets the pstore data if version is number" do
			random_junk.each do |junk|
				next if junk.is_a?(String)
				expect(@double_store).to receive(:version_get) {junk}
				expect(@double_store).to receive(:reset).with("HARD")
				expect(@double_store).to receive(:version_set) {"0.1.0"}

				storage.verify_version()
			end
		end

		it "does not reset store when version is not too old" do
			expect(@double_store).to receive(:version_get) {"0.1.0"}
			expect(@double_store).to_not receive(:reset)

			storage.verify_version()
		end
	end
end


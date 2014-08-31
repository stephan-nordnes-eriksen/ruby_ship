require 'spec_helper'

describe KonjektClient::Core::FileRegister do
	let(:file_register)   { KonjektClient::Core::FileRegister.new }
	let(:unregistered_id) { 999999999 }
	let(:file_index)      { {:file_path => Faker::Internet.password, :mtime => Time.at((50.years.ago.to_f - Time.new.to_f)*rand + Time.new.to_f),  :concepts => [[Faker::Internet.password,rand(0.0..5.0)],[Faker::Internet.password, rand(0.0..5.0)]]} }
	let(:user_name)       { Faker::Internet.user_name}
	let!(:directory_path) { Dir.pwd }

	let(:random_id)       { Faker::Number.number(rand(9)).to_i }
	let(:random_string)   { Faker::Internet.password }
	let(:random_number)   { Faker::Number.number(rand(9)).to_i }
	let(:random_time)     { Time.at((50.years.ago.to_f - Time.new.to_f)*rand + Time.new.to_f) }
	let(:random_junk)     { [nil, false, true, Object.new, Faker::Number.number(rand(9)).to_i, Faker::Internet.password, Faker::Internet.user_name] }


	let(:file_index_return)  { '{"success":true,"respone":true,"file_id":8}' }


	before(:each) do
		EventAggregator::Aggregator.reset
		# File.stub(:find){ ['registered_file_1', 'registered_file_2', 'file_to_be_registered'] }
		# File.stub(:read).with('registered_file_1') { 'registered_file_1 content' }
		# File.stub(:read).with('registered_file_2') { 'registered_file_2 content' }
		# File.stub(:read).with('file_to_be_registered') { 'file_to_be_registered content' }
		# file_register.update_or_create_entry_with_file_and_id!('registered_file_1', 1)
		# file_register.update_or_create_entry_with_file_and_id!('registered_file_2', 2)

		@double_store = double().as_null_object
		@double_store.stub(:transaction).and_yield
		h =  { 'registered_file_1' => 1, 'registered_file_2' => 2 }
		@double_store.stub(:[]).with(:file_to_id_hash) { h }
		h2 = {"file_one" => file_index, "file_two" => file_index, "file_three" => file_index}
		@double_store.stub(:[]).with(:index_cache) { h2 }

		h3 = {"file_one" => Time.now, "file_two" => Time.now - 3.hours, "file_three" => Time.now - 4.days}
		@double_store.stub(:[]).with(:file_to_utime_hash) { h3 }

		h4 = "0.1.0"
		@double_store.stub(:[]).with(:version) { h3 }

		PStore.stub(:new) { @double_store }

		#file_register


		#TODO: Do the same kind of testing here as we do with the konjekt_store, or even move these features to the konjekt_store.
	end

	describe ".initialize" do
		describe "valid parameters" do
			it "map events to producers" do
				expect(EventAggregator::Aggregator).to receive(:register_producer).with("FileNameToID"                      , kind_of(Proc))
				expect(EventAggregator::Aggregator).to receive(:register_producer).with("FileLookupID"                      , kind_of(Proc))
				expect(EventAggregator::Aggregator).to receive(:register_producer).with("FileLookupName"                    , kind_of(Proc))
				expect(EventAggregator::Aggregator).to receive(:register_producer).with("FileUpdated?"                      , kind_of(Proc))
				expect(EventAggregator::Aggregator).to receive(:register_producer).with("FilesIndexSelectNeededFromFolders" , kind_of(Proc))
				expect(EventAggregator::Aggregator).to receive(:register_producer).with("FileLookupIDArray"                 , kind_of(Proc))
				
				expect(@double_store).to receive(:transaction)

				file_register
			end
			it "register listeners" do
				expect(EventAggregator::Aggregator).to receive(:register).with(kind_of(KonjektClient::Core::FileRegister), "FileIDAdd"                       , kind_of(Method))
				expect(EventAggregator::Aggregator).to receive(:register).with(kind_of(KonjektClient::Core::FileRegister), "FileMoved"                       , kind_of(Method))
				expect(EventAggregator::Aggregator).to receive(:register).with(kind_of(KonjektClient::Core::FileRegister), "FileRenamed"                     , kind_of(Method))
				expect(EventAggregator::Aggregator).to receive(:register).with(kind_of(KonjektClient::Core::FileRegister), "FileDeleted"                     , kind_of(Method))
				expect(EventAggregator::Aggregator).to receive(:register).with(kind_of(KonjektClient::Core::FileRegister), "FileIndexStoredToServer"         , kind_of(Method))
				expect(EventAggregator::Aggregator).to receive(:register).with(kind_of(KonjektClient::Core::FileRegister), "FileIndexStoredToServerArray"    , kind_of(Method))
				expect(EventAggregator::Aggregator).to receive(:register).with(kind_of(KonjektClient::Core::FileRegister), "FileIndexNotStoredToServer"      , kind_of(Method))
				expect(EventAggregator::Aggregator).to receive(:register).with(kind_of(KonjektClient::Core::FileRegister), "FileIndexNotStoredToServerArray" , kind_of(Method))
				expect(EventAggregator::Aggregator).to receive(:register).with(kind_of(KonjektClient::Core::FileRegister), "LoggedIn"                        , kind_of(Method))
				expect(EventAggregator::Aggregator).to receive(:register).with(kind_of(KonjektClient::Core::FileRegister), "FileIndexAllCheck"               , kind_of(Method))


				expect(EventAggregator::Aggregator).to receive(:register).with(kind_of(KonjektClient::Core::FileRegister), "FileRegisterDump"                , kind_of(Method))
				expect(EventAggregator::Aggregator).to receive(:register).with(kind_of(KonjektClient::Core::FileRegister), "StorageReset"                    , kind_of(Method))

				expect(@double_store).to receive(:transaction)

				file_register
			end

			it "initializes the PStore variables" do
				@double_store.stub(:[]).with(:file_to_id_hash) { nil }
				@double_store.stub(:[]).with(:index_cache) { nil }
				expect(@double_store).to receive(:transaction).and_yield
				expect(@double_store).to receive(:[]=).with(:file_to_id_hash, {})
				expect(@double_store).to receive(:[]=).with(:index_cache, {})
				file_register
			end
		end
	end

	# Queries
	describe ".file_to_id" do
		describe "valid parameters" do
			it "return correct id" do
				expect(file_register.file_to_id('registered_file_1'))        .to equal(1)
				expect(file_register.file_to_id('registered_file_2'))        .to equal(2)
				expect(file_register.file_to_id('file_not_in_file_register')).to equal(nil)
			end
			it "accesses pstore correctly" do
				expect(@double_store).to receive(:transaction)
				expect(@double_store[:file_to_id_hash]).to receive(:[]).with('registered_file_1')
				file_register.file_to_id('registered_file_1')
			end
		end
		describe "invalid parameters" do
			it "fails silently" do
        expect{file_register.file_to_id('registered_file_3')}.to_not raise_error
      end
      it "returns nil" do
        expect(file_register.file_to_id('registered_file_3')).to be(nil)
      end
		end
	end

	describe ".id_to_file" do
		describe "valid parameters" do
			it "returns correctly" do
				expect(file_register.id_to_file(1)).to eq('registered_file_1')
				expect(file_register.id_to_file(2)).to eq('registered_file_2')
				expect(file_register.id_to_file(unregistered_id)).to eq(nil)
			end
			it "access the pstore correctly" do
				expect(@double_store).to receive(:transaction)
				expect(@double_store[:file_to_id_hash]).to receive(:index).with(1).and_return('registered_file_1')
				file_register.id_to_file(1)
			end
		end
		describe "invalid parameters" do
			it "fails silently" do
        expect{file_register.id_to_file(3)}.to_not raise_error
      end
      it "returns nil" do
        expect(file_register.id_to_file(3)).to be(nil)
      end
		end
	end

	# Actions
	describe ".update_or_create_entry_with_file_and_id!" do
		describe "valid parameters" do
			it "register file with valid path" do
				expect(file_register.update_or_create_entry_with_file_and_id!('file_to_be_registered', 3, random_time)).to eq(3)
				expect(file_register.file_to_id('file_to_be_registered')).to eq(3)
				expect(file_register.id_to_file(3)).to eq('file_to_be_registered')
			end
			it "uses pstore correctly" do
				file_register
				expect(@double_store).to receive(:transaction)
				expect(@double_store).to receive(:[]).with(:file_to_id_hash)
				expect(@double_store[:file_to_id_hash]).to receive(:[]=).with('file_to_be_registered', 3)
				expect(@double_store[:file_to_utime_hash]).to receive(:[]=).with('file_to_be_registered', random_time)

				file_register.update_or_create_entry_with_file_and_id!('file_to_be_registered', 3, random_time)
			end
		end
		describe "invalid parameters" do
			it "raise error" do
				file_register
				expect(@double_store).to_not receive(:transaction).with(any_args)

				random_junk.shuffle.each do |junk|
					file_register.update_or_create_entry_with_file_and_id!('file_to_be_registered', junk, random_time) unless junk.is_a?(Numeric) || junk.is_a?(String)
				end
				random_junk.shuffle.each do |junk|
					file_register.update_or_create_entry_with_file_and_id!('file_to_be_registered', 3, junk) unless junk.kind_of?(Time)
				end
				random_junk.shuffle.each do |junk|
					file_register.update_or_create_entry_with_file_and_id!(junk, 3, random_time) unless junk.is_a?(String)
				end
			end
		end
	end


	describe "update_or_create_entry_with_file_and_id_array!" do
		describe "valid parameters" do
			it "register file with valid path" do
				expect{file_register.update_or_create_entry_with_file_and_id_array!([[{file_path:'file_to_be_registered', mtime:random_time}, 3]])}.to_not raise_error
				expect(file_register.file_to_id('file_to_be_registered')).to eq(3)
				expect(file_register.id_to_file(3)).to eq('file_to_be_registered')
			end
			it "uses pstore correctly" do
				file_register
				expect(@double_store).to receive(:transaction)
				expect(@double_store).to receive(:[]).with(:file_to_id_hash)
				
				expect(@double_store[:file_to_id_hash]).to receive(:[]=).with('file_to_be_registered', 3)
				expect(@double_store[:file_to_id_hash]).to receive(:[]=).with('file_to_be_registered_2', 4)

				expect(@double_store[:file_to_utime_hash]).to receive(:[]=).with('file_to_be_registered', random_time)
				expect(@double_store[:file_to_utime_hash]).to receive(:[]=).with('file_to_be_registered_2', random_time)

				file_register.update_or_create_entry_with_file_and_id_array!([[{file_path:'file_to_be_registered', mtime:random_time}, 3], [{file_path:'file_to_be_registered_2', mtime:random_time}, 4]])
			end
			it "more tests" do
				pending "not yet implemented, but should be tested more."
			end
		end
		describe "invalid parameters" do
			it "raise error" do
				file_register
				expect(@double_store).to_not receive(:[]).with(any_args)

				random_junk.shuffle.each do |junk|
					file_register.update_or_create_entry_with_file_and_id_array!([[{file_path:'file_to_be_registered', mtime:random_time}, junk]]) unless junk.is_a?(Numeric) || junk.is_a?(String)
				end
				random_junk.shuffle.each do |junk|
					file_register.update_or_create_entry_with_file_and_id_array!([[{file_path:'file_to_be_registered', mtime:junk}, 3]]) unless junk.kind_of?(Time)
				end
				random_junk.shuffle.each do |junk|
					file_register.update_or_create_entry_with_file_and_id_array!([[{file_path:junk, mtime:random_time}, 3]]) unless junk.is_a?(String)
				end
			end
		end
	end

	describe ".delete_entry_with_file!" do
		describe "valid parameters" do
			it "delete existing entry with file" do
				expect(@double_store).to receive(:transaction)
				expect(@double_store).to receive(:[]).with(:file_to_id_hash)
				expect(@double_store[:file_to_id_hash]).to receive(:delete).with('registered_file_1')

				file_register.delete_entry_with_file!('registered_file_1')
			end
		end
		describe "invalid parameters" do
      it "fails silently" do
        expect{file_register.delete_entry_with_file!('registered_file_3')}.to_not raise_error
      end
		end
	end
	describe "delete_entry_with_id!" do
		describe "valid parameters" do
			it "delete existing entry with id" do
				expect(@double_store).to receive(:transaction)
				expect(@double_store).to receive(:[]).with(:file_to_id_hash)
				expect(@double_store[:file_to_id_hash]).to receive(:delete).with('registered_file_1')

				file_register.delete_entry_with_id!(1)
			end
		end
		describe "invalid parameters" do
			it "fails silently" do
        expect{file_register.delete_entry_with_id!(3)}.to_not raise_error
			end
		end
	end
	describe "rename_file_to_new_file!" do
		describe "valid parameters" do
			it "rename existing entry file in the PStore" do
				expect(@double_store).to receive(:transaction)
				expect(@double_store).to receive(:[]).with(:file_to_id_hash)
				expect(@double_store[:file_to_id_hash]).to receive(:delete).with('registered_file_1')
				expect(@double_store[:file_to_id_hash]).to receive(:[]=).with('new_file_name', 1)

				file_register.rename_file_to_new_file!('registered_file_1', 'new_file_name')
			end
		end
		describe "invalid parameters" do
      it "fails silently" do
        expect{file_register.rename_file_to_new_file!('registered_file_3', 'new_file_name')}.to_not raise_error
      end
		end
	end

	describe ".receive_file_index_stored_to_server" do
		describe "valid parameters" do
      it "calls update_or_create_entry_with_file_and_id_array!" do
        file_register
        expect(file_register).to receive(:update_or_create_entry_with_file_and_id!).with('file_to_be_registered', 3, random_time)

        file_register.receive_file_index_stored_to_server([{file_path: 'file_to_be_registered', mtime: random_time}, 3])
      end
		end
		describe "invalid parameters" do
      it "does not call update_or_create_entry_with_file_and_id_array" do
        expect(file_register).to_not receive(:update_or_create_entry_with_file_and_id!)

        random_junk.each do |junk|
          file_register.receive_file_index_stored_to_server(junk)
        end
      end
		end
  end

	describe ".receive_file_index_not_stored_to_server" do
		describe "valid parameters" do
			it "stores to @double_store" do
				expect(@double_store).to receive(:transaction).and_yield
				expect(@double_store).to receive(:[]).with(:index_cache)

				expect(@double_store[:index_cache]).to receive(:[]=).with(file_index[:file_path], file_index)

				file_register.receive_file_index_not_stored_to_server(file_index)
			end

		end
		describe "invalid parameters" do
			it "does not store junk" do
				file_register
				expect(@double_store).to_not receive(:transaction).and_yield

				random_junk.shuffle.each do |junk|
					file_register.receive_file_index_not_stored_to_server(junk)
				end
			end
			it "does not store dirty index" do
				file_register
				expect(@double_store).to_not receive(:transaction).and_yield

				file_index
				file_index[:dirty] = true

				file_register.receive_file_index_not_stored_to_server(file_index)
			end
		end
	end

	describe ".receive_file_index_not_stored_to_server_array" do
		describe "valid parameters" do
			it "stores to @double_store" do
				expect(@double_store).to receive(:transaction).and_yield
				expect(@double_store).to receive(:[]).with(:index_cache)

				expect(@double_store[:index_cache]).to receive(:[]=).with(file_index[:file_path], file_index)

				file_register.receive_file_index_not_stored_to_server_array([file_index])
			end

		end
		describe "invalid parameters" do
			it "does not store junk" do
				file_register
				expect(@double_store).to_not receive(:[]).with(:index_cache).with(any_args)

				random_junk.shuffle.each do |junk|
					file_register.receive_file_index_not_stored_to_server_array([junk])
				end
			end
			it "does not store dirty index" do
				file_register
				expect(@double_store).to_not receive(:[]).with(:index_cache).with(any_args)

				file_index
				file_index[:dirty] = true

				file_register.receive_file_index_not_stored_to_server_array([file_index])
			end
		end
	end

	describe ".receive_logged_in" do
		describe "valid parameters" do
			it "publishes FileIndexed" do
				#Expect it to grab all the cached indexes, and create messages with those, but now with dirty = true
				expect(EventAggregator::Aggregator).to receive(:message_publish).exactly(1).times { |message| expect(message.message_type).to eq("FileIndexedArray") and expect(message.data[0][:dirty]).to be(true) }

				file_register.receive_logged_in(user_name)
				#should it consider which user it is, maybe?
			end
			it "deletes indecies after publishment"do
				expect(EventAggregator::Aggregator).to receive(:message_publish).exactly(1).times { |message| expect(message.message_type).to eq("FileIndexedArray") and expect(message.data[0][:dirty]).to equal(true) }
				file_register.receive_logged_in(user_name)

				expect(@double_store[:index_cache].length).to be(0)
			end
		end
		describe "invalid parameters" do
			it "does not publish FileIndexed if user has changed, and delete cache" do
				pending "This is not nescessary just yet. Lets just run the index no matter who logs in."
				expect(EventAggregator::Aggregator).to receive(:message_publish).exactly(0).times
				file_register.receive_logged_in({:name => user_name, :user_changed => true})

				expect(@double_store[:index_cache].length).to be(0)
			end
		end
	end
	describe ".receive_file_index_all_check" do
		before(:each) do
			@storage = KonjektClient::Core::Storage.new
			@storage.stub(:directories_get) { [File.expand_path(File.dirname(__FILE__))] }
			@storage.stub(:directories_set)
		end
		describe "valid parameters" do
			it "produces IndexFile messages" do
				expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageDirectoriesGet") }.and_return([directory_path])

				file_count = Dir[File.join(directory_path, '**', '*')].count { |file| File.file?(file) }

				#Given that all the files are new/outdated.
				expect(EventAggregator::Aggregator).to receive(:message_publish).exactly(file_count).times { |message| expect(message.message_type).to eq("FileIndex")}
				# expect(to get the directories from storage)

				# iterates over all the files in those directories

				# Checks if all the files has a m-time newer than what we have registered on that file.
				#expect(File).to receive(:mtime).exactly(file_count).times#won't do this because the file is not in the hash.


				# if it does, we send a new "FileIndex" with that file-name.

				file_register.receive_file_index_all_check(nil)
			end

			it "Does not produce IndexFile when files not updated" do
				temp_h = Hash.new
				directories = @storage.directories_get
				directories.each do |fold|
					Dir[File.join(fold, '**', '*')].each do |file|
						temp_h[file] = File.mtime(file)
					end
				end

				@double_store.stub(:[]).with(:file_to_utime_hash) { temp_h }

				expect(EventAggregator::Aggregator).to receive(:message_publish).exactly(0).times { |message| expect(message.message_type).to eq("FileIndex")}

				file_register.receive_file_index_all_check(nil)
			end
		end
		describe "invalid parameters" do
			pending "not implemented"
		end
	end
end
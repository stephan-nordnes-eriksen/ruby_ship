require 'spec_helper'

# Public: Some ruby trickery to be able to test private methods
#
# Example:
# whatever_object.class.publicize_methods do
# #... execute private methods
# end
class Class
	def publicize_methods
		saved_private_instance_methods = self.private_instance_methods
		self.class_eval { public *saved_private_instance_methods }
		yield
		self.class_eval { private *saved_private_instance_methods }
	end
end

describe KonjektClient::Core::FileSystemWatcher do
	let(:file_system_watcher)         { KonjektClient::Core::FileSystemWatcher.new }
	let!(:file_path)                   { File.expand_path File.dirname(__FILE__) }
	let!(:file_path_illegal)           { File.join(Dir.pwd, "lol_does_not_exists.com") }
	let!(:directory_path)              { Dir.pwd }
	let(:directory_path_illegal)      { File.join(Dir.pwd, "lol_does_not_exists") }

	let(:message_folder_watch_add)    { EventAggregator::Message.new("FolderWatchAdd", "data") }
	let(:message_folder_watch_remove) { EventAggregator::Message.new("FolderWatchRemove", "data") }
	let(:message_log_out)             { EventAggregator::Message.new("LogOut", "data") }


	before(:each) do
		EventAggregator::Aggregator.reset
		@storage = KonjektClient::Core::Storage.new
		@storage.stub(:directories_get) { [File.expand_path(File.dirname(__FILE__))] }
		@storage.stub(:directories_set)
		#Stubbing File class
		#		File.stubs(:find).returns(['file1', 'file2'])
		#		File.stubs(:read).with('file1').returns('some content')
		#		File.stubs(:read).with('file2').returns('other content')
	end

	#TODO: There is something fishy here. Should not test for this I think.
	describe 'Sends Messages' do
		describe ".file_added" do
			it "send FileAdded message" do
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("FileAdded") }
				file_system_watcher.file_added(file_path)
			end
		end

		describe ".file_changed" do
			it "send FileChanged message" do
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("FileChanged") }
				file_system_watcher.file_changed(file_path)
			end
		end

		describe ".file_moved" do
			it "send FileMoved message" do
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("FileMoved") }
				file_system_watcher.file_moved(file_path)
			end
		end

		describe ".file_deleted" do
			it "send FileDeleted message" do
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("FileDeleted") }
				file_system_watcher.file_deleted(file_path)
			end
		end

		describe ".file_renamed" do
			it "send FileRenamed message" do
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("FileRenamed") }
				file_system_watcher.file_renamed(file_path)
			end
		end


		pending "should send FileUnwatched" # Watched files are the ones we care about for indexing etc.
		pending "should send QueryBuild*"
		pending "should send FileOpened(?)"
		pending "should send FileClosed(?)"
	end

	describe ".initialize" do
		pending "Not implemented"
		describe "valid parameters" do
			it "message type signup" do
				expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("FolderWatchAdd") }
				expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("FolderWatchRemove") }
				expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("LogOut") }
				expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("FileIndexAll") }
				file_system_watcher
			end

			#TODO: Remove requirement from the silly initialize method. use storage and get the folders that way.
			it "request StorageDirectoriesGet" do
				expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageDirectoriesGet") }.and_return([file_path])
				file_system_watcher
			end
		end
	end

	describe ".file_modified" do
		it "sends FileModified message" do
			expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("FileModified") }
			file_system_watcher.file_modified(file_path)
		end
	end
	describe ".file_added" do
		it "sends FileAdded message" do
			expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("FileAdded") }
			file_system_watcher.file_added(file_path)
		end
	end
	describe ".file_removed" do
		it "sends FileRemoved message" do
			expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("FileRemoved") }
			file_system_watcher.file_removed(file_path)
		end
	end

	describe ".start" do
		it "called" do
			expect(file_system_watcher.listener).to receive(:start)
			file_system_watcher.start
		end
	end
	describe ".listen?" do
		it "called" do
			expect(file_system_watcher.listener).to receive(:listen?)
			file_system_watcher.listen?
		end
	end
	describe ".pause" do
		it "called" do
			expect(file_system_watcher.listener).to receive(:pause)
			file_system_watcher.pause
		end
	end
	describe ".paused?" do
		it "called" do
			expect(file_system_watcher.listener).to receive(:paused?)
			file_system_watcher.paused?
		end
	end
	describe ".unpause" do
		it "called" do
			expect(file_system_watcher.listener).to receive(:unpause)
			file_system_watcher.unpause
		end
	end
	describe ".stop" do
		it "called" do
			expect(file_system_watcher.listener).to receive(:stop)
			file_system_watcher.stop
		end
	end

	describe ".folder_watch_add" do
		describe "valid parameters" do
			it "sends FileIndex" do
				file_system_watcher
				
				file_count = Dir[File.join(directory_path, '**', '*')].count { |file| File.file?(file) }
				
				expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageDirectoriesGet") }.and_return([])
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("StorageDirectoriesSet") }

				expect(EventAggregator::Aggregator).to receive(:message_publish).exactly(file_count).times { |message| expect(message.message_type).to eq("FileIndex")}

				file_system_watcher.folder_watch_add(directory_path)
			end
		end
	end
	describe ".folder_watch_remove" do
		describe "valid parameters" do
			it "sends FileRemoved" do
				
				#EventAggregator::Aggregator.register_all(file_system_watcher, lambda {|e| puts "MESSAGE: #{e}" })
				file_system_watcher
				file_count = Dir[File.join(directory_path, '**', '*')].count { |file| File.file?(file) }
				

				expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("StorageDirectoriesGet") }.and_return([directory_path])
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("StorageDirectoriesSet") }
				expect(EventAggregator::Aggregator).to receive(:message_publish).exactly(file_count).times { |message| expect(message.message_type).to eq("FileRemove")}

				file_system_watcher.folder_watch_remove(directory_path)
			end
			it "handles array of folders" do
				pending "not implemented"
			end
			it "handles single folder" do
				pending "not implemented"
			end
		end
		describe "invalid parameters" do
			it "fails silently" do
				pending "not implemented"
			end
		end
	end
	describe ".log_out" do
		it "stops listener" do
			expect(file_system_watcher.listener).to receive(:stop)#TODO: Should this be the Listen object in stead?
			file_system_watcher.log_out(nil)
		end
	end

	describe ".folder_watch_add" do
		describe "valid parameters" do
			it "not raise error" do
				expect{ file_system_watcher.folder_watch_add([directory_path])                 }.to_not raise_error
				expect{ file_system_watcher.folder_watch_add([file_path])                      }.to_not raise_error

				expect{ file_system_watcher.folder_watch_add([directory_path, directory_path]) }.to_not raise_error
				expect{ file_system_watcher.folder_watch_add([file_path, directory_path])      }.to_not raise_error
				expect{ file_system_watcher.folder_watch_add([file_path, file_path])           }.to_not raise_error
			end

			it "calls Listen.to with directory_path from array" do
				file_system_watcher
				@storage.stub(:directories_get) { nil }
				expect(Listen).to receive(:to).with(directory_path)
				file_system_watcher.folder_watch_add([directory_path])
			end
			it "calls Listen.to with file_path from array" do
				file_system_watcher
				@storage.stub(:directories_get) { nil }
				expect(Listen).to receive(:to).with(file_path)
				file_system_watcher.folder_watch_add([file_path])
			end
			it "calls Listen.to with file_path" do
				file_system_watcher
				@storage.stub(:directories_get) { nil }
				expect(Listen).to receive(:to).with(file_path)
				file_system_watcher.folder_watch_add([file_path])
			end
			it "calls Listen.to with several" do
				file_system_watcher
				@storage.stub(:directories_get) { nil }
				expect(Listen).to receive(:to).with(file_path, directory_path)
				file_system_watcher.folder_watch_add([file_path, directory_path])
			end
			it "sends StorageDirectoriesSet message" do
				file_system_watcher
				@storage.stub(:directories_get) { nil }
				expect(EventAggregator::Aggregator).to receive(:message_publish).once { |message| expect(message.message_type).to eq("StorageDirectoriesSet") and expect(message.data).to eq([file_path, directory_path])}
				expect(EventAggregator::Aggregator).to receive(:message_publish).at_least(:once).
				with(kind_of(EventAggregator::Message)) do |message| 
					expect(message.message_type).to eq("FileIndex")
				end

				file_system_watcher.folder_watch_add([file_path, directory_path])
			end
		end

		describe "invalid parameters" do
			it "raise error" do
				#We require the input to be an array of file_paths or directory_paths, for now.
				#expect{ file_system_watcher.folder_watch_add(directory_path)                                              }.to raise_error
				#expect{ file_system_watcher.folder_watch_add(file_path)                                                   }.to raise_error

				expect{ file_system_watcher.folder_watch_add(1)                                                           }.to raise_error
				expect{ file_system_watcher.folder_watch_add(Object.new)                                                  }.to raise_error
				#This won't throw error, just not do anything.
				#expect{ file_system_watcher.folder_watch_add(directory_path_illegal)                                      }.to raise_error
				#expect{ file_system_watcher.folder_watch_add(file_path_illegal)                                           }.to raise_error
				expect{ file_system_watcher.folder_watch_add()                                                            }.to raise_error

				expect{ file_system_watcher.folder_watch_add([1])                                                         }.to raise_error
				expect{ file_system_watcher.folder_watch_add([Object.new])                                                }.to raise_error
				#expect{ file_system_watcher.folder_watch_add([directory_path_illegal])                                    }.to raise_error
				#expect{ file_system_watcher.folder_watch_add([file_path_illegal])                                         }.to raise_error
				#expect{ file_system_watcher.folder_watch_add([])                                                          }.to raise_error

				expect{ file_system_watcher.folder_watch_add([1, 2])                                                      }.to raise_error
				expect{ file_system_watcher.folder_watch_add([Object.new,Object.new])                                     }.to raise_error
				#expect{ file_system_watcher.folder_watch_add([directory_path_illegal, directory_path_illegal])            }.to raise_error
				#expect{ file_system_watcher.folder_watch_add([file_path_illegal, file_path_illegal])                      }.to raise_error
				#expect{ file_system_watcher.folder_watch_add([])                                                          }.to raise_error

				expect{ file_system_watcher.folder_watch_add([file_path, 1, 2])                                           }.to raise_error
				expect{ file_system_watcher.folder_watch_add([file_path, Object.new,Object.new])                          }.to raise_error
				#expect{ file_system_watcher.folder_watch_add([file_path, directory_path_illegal, directory_path_illegal]) }.to raise_error
				#expect{ file_system_watcher.folder_watch_add([file_path, file_path_illegal, file_path_illegal])           }.to raise_error
			end
		end
	end




end
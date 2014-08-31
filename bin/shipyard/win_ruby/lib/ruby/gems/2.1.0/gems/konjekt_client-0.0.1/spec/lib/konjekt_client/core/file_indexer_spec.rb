# encoding: UTF-8
require 'spec_helper'

describe KonjektClient::Core::FileIndexer do
	let(:file_indexer)         { KonjektClient::Core::FileIndexer.new }

	let(:random_string) { Faker::Internet.password }
	let(:random_number) { Faker::Number.number(rand(9)).to_i }

	#TODO: Consider removing these message types here, and only respond to "FileIndex"
	#After all. It is not the indexers job to know when to index, is it?
	#Probably make a scheduler class, or something, where we can list up actions
	#that should be executen when certain messages arrive. A giant switch thing.
	let(:message_file_changed) { EventAggregator::Message.new("FileChanged","data") }
	let(:message_file_added)   { EventAggregator::Message.new("FileAdded","data") }
	let(:message_file_index)   { EventAggregator::Message.new("FileIndex","data") }

	let(:file_path)            { File.expand_path(__FILE__) }
	let(:file_path_illegal)    { File.join(Dir.pwd, "lol_does_not_exists.com") }

	before(:each) do
		EventAggregator::Aggregator.reset
	end

	describe ".initialize" do
		it "message type signup" do
			# expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("FileChanged") }
			# expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("FileAdded") }

			expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("FileIndexArray") }
			KonjektClient::Core::FileIndexer.new
		end
	end

	describe ".orta_index_files_array" do
		describe "valid parameters" do
      it "calls OrtaIndexer.process_files" do
         expect(KonjektClient::Core::OrtaIndexer).to receive(:process_files).with([file_path]) {[{"fp"=> file_path, "ln"=> "en", "mt"=> "text", "cs"=> {"lol" =>23} }]}
         file_indexer.orta_index_files_array([[file_path]])
      end
			it "publishes EventAggregator::Message" do
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("FileIndexedArray") }

				file_indexer.orta_index_files_array([file_path])
			end
			it "publishes EventAggregator::Message with this data" do
				t = Time.now
				File.stub(:mtime) {t}
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("FileIndexedArray") and
					expect(message.data[0][:file_path]).to eq(file_path) and
					expect(message.data[0][:concepts]).to be_a(Hash) and
					expect(message.data[0][:mtime]).to eq(t)
				}

				file_indexer.orta_index_files_array([[file_path]])
			end
			it "retrieves modified-date" do
				expect(File).to receive(:mtime).with(file_path) {Time.now}
				file_indexer.orta_index_files_array([[file_path]])
			end

			it "handles file types" do
				pending "not implemented"
			end

			it "adds file-type to the concepts" do
				File.stub(:file?).with("some_file.png") { true }
				File.stub(:mtime) { Time.now }

				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("FileIndexedArray") and
					expect(message.data[0][:concepts]).to be_a(Hash) and
					expect(message.data[0][:concepts].keys).to include(".png")
				}
				file_indexer.orta_index_files_array([["some_file.png"]])
			end

			it "sends index even if the yomu text fails" do
				expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("FileIndexedArray")}
				file_indexer.orta_index_files_array([[file_path]])
			end
		end
		#this is texas. If you don't do this right, you deserve to get fucked in the chest with poo.
    # describe "invalid parameters" do
		# 	it "gracefull return" do
		# 		expect{file_indexer.orta_index_files_array([file_path_illegal])}.to_not raise_error
		# 		expect{file_indexer.orta_index_files_array([random_number])}    .to_not raise_error
		# 		expect{file_indexer.orta_index_files_array([random_string])}    .to_not raise_error
		# 	end
     #  it "raise error" do
     #    expect{file_indexer.orta_index_files_array([random_number])}.to raise_error
     #    expect{file_indexer.orta_index_files_array([random_string])}.to raise_error
     #  end
		# end
	end


end

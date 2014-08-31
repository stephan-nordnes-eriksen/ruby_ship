require 'spec_helper'

describe KonjektClient::Core::Logger do
	let(:logger)         { KonjektClient::Core::Logger.new }
	
	let(:random_string) { Faker::Internet.password }
	let(:random_number) { Faker::Number.number(rand(9)).to_i }
	

	let(:message_type) { Faker::Internet.password }
	let(:message_data) { Faker::Number.number(rand(9)).to_i }

	before(:each) do
		EventAggregator::Aggregator.reset
		@file_double = double().as_null_object
		#File.stub(:new) { @file_double }
		#File.stub(:new) { @file_double }
		#stub_const("File", @file_double)
		File.stub(:open) { nil }
		File.stub(:write) { nil }
		@now = Time.now
		Time.stub(:now) { @now }
	end

	describe ".initialize" do
		it "registers for all" do
			expect(EventAggregator::Aggregator).to receive(:register_all) { |listener, callback| expect(listener).to be_kind_of(KonjektClient::Core::Logger) }
			logger
		end
			# it "initializes logger file" do
			# 	expect(@file_double).to receive(:new).with("konjekt.log")
			# 	logger
			# end
	end

	describe "writes to file" do
		it "on all messages" do
			expect(File).to receive(:open).with(/.+konjekt.log/, 'a')
			#,"#{@now}: Type: #{message_type} __ Data: #{message_data}", any_args, any_args)

			message = EventAggregator::Message.new("message_type", "message_data")
			logger.log_message(message)
			#This is ruby 1.9.3:
			#File.write('some-file.txt', 'here is some text', File.size('some-file.txt'), mode: 'a')
		end
	end


end
# encoding: UTF-8
require 'spec_helper'

describe KonjektClient::Core::OrtaIndexer do
	let(:random_string) { Faker::Internet.password }
	let(:random_number) { Faker::Number.number(rand(9)).to_i }
	let(:file_path)     { File.expand_path(__FILE__) }

	let(:random_junk)     { [nil, false, true, Object.new, Faker::Number.number(rand(9)).to_i, Faker::Internet.password, Faker::Internet.user_name] }

	before(:each) do
		EventAggregator::Aggregator.reset
	end

	describe "self.java_path" do
		it "returns java if no ENV['JAVA_HOME'] exists" do
			stub_const("ENV", {})

			expect(KonjektClient::Core::OrtaIndexer.java_path).to eq('java')
		end
		it "returns java_path/bin/java if ENV['JAVA_HOME'] exists" do
			stub_const("ENV", {'JAVA_HOME'=> 'java_path'})
			
			expect(KonjektClient::Core::OrtaIndexer.java_path).to eq(File.join('java_path','bin','java'))
		end
	end
	describe "self.jar_path" do
		it 'returns path to contain orta12.jar' do
			expect(KonjektClient::Core::OrtaIndexer.jar_path).to match(/orta12\.jar/)
		end
		it 'returns path to existing orta12.jar file' do
			expect(File.file?(KonjektClient::Core::OrtaIndexer.jar_path)).to be(true)
		end
	end

	describe "self.start_command" do
		before(:each) do
			KonjektClient::Core::OrtaIndexer.class_variable_set(:@@os, nil)
		end
		it "includes jar path" do
			expect(KonjektClient::Core::OrtaIndexer.start_command).to include(KonjektClient::Core::OrtaIndexer.jar_path)
		end
		it "includes java path" do
			expect(KonjektClient::Core::OrtaIndexer.start_command).to include(KonjektClient::Core::OrtaIndexer.java_path)
		end
		it "requests GetOperatingSystem message" do
			expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("GetOperatingSystem") }
			KonjektClient::Core::OrtaIndexer.start_command
		end
		it "prepends start \"KonjektOrtaIndexer\" on windows" do
			expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("GetOperatingSystem") }.and_return("win")
			expect(KonjektClient::Core::OrtaIndexer.start_command[0..25]).to eq("start \"KonjektOrtaIndexer\"")
		end
		it "prepends exec -a KonjektOrtaIndexer on osx" do
			expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("GetOperatingSystem") }.and_return("osx")
			expect(KonjektClient::Core::OrtaIndexer.start_command[0..25]).to eq("exec -a KonjektOrtaIndexer")
		end
		it "prepends exec -a KonjektOrtaIndexer on linux" do
			expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("GetOperatingSystem") }.and_return("linux")
			expect(KonjektClient::Core::OrtaIndexer.start_command[0..25]).to eq("exec -a KonjektOrtaIndexer")
		end
	end

	describe "self.process_files" do
		describe "valid parameters" do
			it "runs IO.popen" do
				expect(IO).to receive(:popen).with(KonjektClient::Core::OrtaIndexer.start_command, 'r+').twice
				KonjektClient::Core::OrtaIndexer.process_files([file_path])
				KonjektClient::Core::OrtaIndexer.process_files([file_path,file_path,file_path,file_path]) #should this be ok? Probably. I mean, if you really really want to be stupid, you should be allowed to be.
			end
		end
		describe "invalid parameters" do
			it "not opens IO.popen on non-array" do
				expect(IO).to_not receive(:popen)

				random_junk.shuffle.each do |junk|
					KonjektClient::Core::OrtaIndexer.process_files(junk) unless junk.is_a?(Array)
				end
			end
			it "opens IO.popen and does not crash on array with junk" do
				expect(IO).to receive(:popen).exactly(random_junk.length)
				random_junk.shuffle.each do |junk|
					unless junk.is_a?(String) && File.file?(junk)
						expect{KonjektClient::Core::OrtaIndexer.process_files([junk])}.to_not raise_error 
					end
				end
			end
		end
	end
end
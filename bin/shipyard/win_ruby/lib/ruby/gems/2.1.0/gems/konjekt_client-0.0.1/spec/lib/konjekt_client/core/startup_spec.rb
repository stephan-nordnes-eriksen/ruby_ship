require 'spec_helper'


describe KonjektClient::Core::Startup do
	before(:each) do
		EventAggregator::Aggregator.reset

		# n = nil
		# n.stub(:kind_of).with(KonjektClient::Core::GUI                    ) { true }
		# n.stub(:kind_of).with(KonjektClient::Core::FileIndexer            ) { true }
		# n.stub(:kind_of).with(KonjektClient::Core::FileRegister           ) { true }
		# n.stub(:kind_of).with(KonjektClient::Core::RecommendationGenerator) { true }

		# KonjektClient::Core::GUI                    .stub(:new) { n }
		# KonjektClient::Core::FileIndexer            .stub(:new) { n }
		# KonjektClient::Core::FileRegister           .stub(:new) { n }
		# KonjektClient::Core::RecommendationGenerator.stub(:new) { n }
	end
	let(:startup) { KonjektClient::Core::Startup.new }#TODO: Mock stuff that might get started because of this.

	let(:random_string) { Faker::Internet.password }
	let(:random_number) { Faker::Number.number(rand(9)).to_i }

	describe ".initialize" do
		it "initialize components" do
			expect(KonjektClient::Core::Utils)                  .to receive(:new).once
			expect(KonjektClient::Core::Storage)                .to receive(:new).once
			expect(KonjektClient::Core::FileIndexer)            .to receive(:new).once
			expect(KonjektClient::Core::FileRegister)           .to receive(:new).once
			#expect(KonjektClient::Core::FileSystemWatcher)      .to receive(:new).once #TODO: This component is not ready yet.
			expect(KonjektClient::Core::GUI)                    .to receive(:new).once
			expect(KonjektClient::Core::RecommendationGenerator).to receive(:new).once
			expect(KonjektClient::Core::ServerConnector)        .to receive(:new).once
			
			


			#expect(KonjektClient::Core::Logger)                  .to receive(:new).once

			KonjektClient::Core::Startup.new
		end
		it "returns correct type" do
			expect(startup.file_indexer)            .to be_a(KonjektClient::Core::FileIndexer)
			expect(startup.file_register)           .to be_a(KonjektClient::Core::FileRegister)
			#expect(startup.file_system_watcher)     .to be_a(KonjektClient::Core::FileSystemWatcher)
			expect(startup.gui)                     .to be_a(KonjektClient::Core::GUI)
			expect(startup.recommendation_generator).to be_a(KonjektClient::Core::RecommendationGenerator)
			expect(startup.server_connector)        .to be_a(KonjektClient::Core::ServerConnector)
			expect(startup.storage)                 .to be_a(KonjektClient::Core::Storage)
			expect(startup.utils)                   .to be_a(KonjektClient::Core::Utils)
			#expect(startup.logger)                  .to be_a(KonjektClient::Core::Logger)
		end
		
		it "sends LogInTry message" do
			expect(EventAggregator::Aggregator).to receive(:message_publish) {|m| expect(m.message_type).to eq("LogInTry")}
			startup
		end
		
	end
end
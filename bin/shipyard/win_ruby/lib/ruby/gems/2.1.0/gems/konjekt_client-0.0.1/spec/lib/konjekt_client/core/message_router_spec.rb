require 'spec_helper'

describe KonjektClient::Core::MessageRouter do 
	let(:message_router) { KonjektClient::Core::MessageRouter.new }

	before(:each) do
		EventAggregator::Aggregator.reset
	end

	describe ".initialize" do
		it "sets up translate_message_with" do
			expect(EventAggregator::Aggregator).to receive(:translate_message_with).with("FileAdded"  , "FileIndex")
			expect(EventAggregator::Aggregator).to receive(:translate_message_with).with("FileChanged", "FileIndex")
			expect(EventAggregator::Aggregator).to receive(:translate_message_with).with("LoggedIn"   , "TestFirstTimeStartup")

			message_router
		end
	end
end
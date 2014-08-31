require 'spec_helper'

describe KonjektClient::Core::RecommendationGenerator do
	let(:recommendation_generator) { KonjektClient::Core::RecommendationGenerator.new }

	before(:each) do
		EventAggregator::Aggregator.reset
	end

	describe ".initialize" do
		describe "valid parameters" do
			it "message type signup" do
				expect(EventAggregator::Aggregator).to receive(:register) { |listener, message_type, callback| expect(message_type).to eq("RecommendFiles") }
				recommendation_generator
			end
		end
	end

	describe ".recommend_files" do
		it "produces RecommendFromServer message" do
			expect(EventAggregator::Aggregator).to receive(:message_publish) { |message| expect(message.message_type).to eq("RecommendFromServer") }
			recommendation_generator.recommend_files(nil)
		end

		it "requests messages" do #This needs to be one test. If you split these up you will get errors.
			expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("CurrentTimeGet") }
			expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("GeoLocationGet") }
			expect(EventAggregator::Aggregator).to receive(:message_request) { |message| expect(message.message_type).to eq("ContextGet") }
			recommendation_generator.recommend_files(nil)
		end
	end
end
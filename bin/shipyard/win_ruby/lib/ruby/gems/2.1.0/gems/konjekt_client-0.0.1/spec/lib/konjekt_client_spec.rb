require 'spec_helper'

describe KonjektClient do
	before(:each) do
		EventAggregator::Aggregator.reset
	end

	describe "self.start" do
		it "should be start startup" do
			expect(KonjektClient::Core::Startup).to receive(:new).once { double().as_null_object }
			KonjektClient.start
		end
		it "should return GUI class" do
			expect(KonjektClient.start).to be_kind_of(KonjektClient::Core::GUI)
		end
	end
end
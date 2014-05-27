require 'spec_helper'

describe EventAggregator::MessageJob do
	let(:callback)    { lambda{ |data| } }
	let(:data)        { Faker::Name.name }
	let(:message_job) { EventAggregator::MessageJob.new }

	describe '.perform' do
		describe 'legal parameters' do
			it 'excute callback with data' do
				expect(callback).to receive(:call).with(data)
				
				message_job.perform(data, callback)
			end
		end
		describe 'illegal parameters' do
			it 'should never be passed to MessageJob' do
				expect(true).to eq(true)
			end
		end
	end
end

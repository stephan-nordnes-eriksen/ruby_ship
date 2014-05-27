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

describe EventAggregator::Listener do
	let(:listener)           { (Class.new { include EventAggregator::Listener }).new }
	let(:listener_class)     { Class.new { include EventAggregator::Listener } }
	let(:message_type)       { Faker::Name.name }
	let(:callback)      { lambda { |data| } }
	let(:data)  		     { Faker::Name.name }
	let(:recieve_all_method) { lambda { |message| } }

	before(:each) do
		EventAggregator::Aggregator.reset
		@message = EventAggregator::Message.new(message_type, data)
	end

	describe '.message_type_register' do
		describe 'legal parameters' do
			it 'invoke aggregator register' do
				expect(EventAggregator::Aggregator).to receive(:register).with(listener, message_type, callback)

				listener.class.publicize_methods do
					listener.message_type_register(message_type, callback)
				end
			end
		end
		describe 'illegal parameters' do
			it 'raise error' do
				expect{listener.message_type_register(message_type, nil)}.to                raise_error
				expect{listener.message_type_register(message_type, 1)}.to                  raise_error
				expect{listener.message_type_register(message_type, "string")}.to           raise_error
				expect{listener.message_type_register(message_type, listener_class.new)}.to raise_error
			end
		end
	end

	describe '.message_type_unregister' do
		describe 'legal parameters' do
			it 'invoke aggregator unregister' do
				listener.class.publicize_methods do
					listener.message_type_register(message_type, callback)

					expect(EventAggregator::Aggregator).to receive(:unregister).with(listener, message_type)

					listener.message_type_unregister(message_type)
				end
			end
		end
	end

	describe '.message_type_register_all' do
		describe 'legal parameters' do
			it 'invoke aggregator unregister_all' do
				listener.class.publicize_methods do
					expect(EventAggregator::Aggregator).to receive(:register_all).with(listener,callback)

					listener.message_type_register_all(callback)
				end
			end
		end
	end

	describe '.message_type_unregister_all' do
		describe 'legal parameters' do
			it 'invoke aggregator unregister' do
				listener.class.publicize_methods do
					expect(EventAggregator::Aggregator).to receive(:unregister_all).with(listener)

					listener.message_type_unregister_all()
				end
			end
		end
	end

	describe ".message_type_producer_register" do
		describe 'legal parameters' do
			it "invoke aggregator register_producer" do
				expect(EventAggregator::Aggregator).to receive(:register_producer).with(message_type, callback)
				listener.class.publicize_methods do
					listener.producer_register(message_type, callback)
				end
			end
		end
	end
end

require 'spec_helper'

describe EventAggregator::Aggregator do
	let(:listener)       { (Class.new { include EventAggregator::Listener }).new }
	let(:listener_class) { Class.new { include EventAggregator::Listener }}
	let(:message_type)   { Faker::Name.name }
	let(:data)           { Faker::Name.name }
	let(:callback)       { lambda{ |data| } }
	let(:random_string)  { Faker::Internet.password }
	let(:random_number)  { Faker::Number.number(rand(9)) }
	let(:empty_object)   { Object.new }

	before(:all) do
		EventAggregator::Aggregator.reset
	end

	after(:each) do
		EventAggregator::Aggregator.restart_pool
	end
	describe "self.register" do
		describe 'legal parameters' do
			it "no errors" do
				expect{EventAggregator::Aggregator.register(listener, message_type, callback)}.to_not raise_error
			end
			it "is stored" do
				expect{EventAggregator::Aggregator.register(listener, message_type, callback)}.to change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
			end
			it "overwrite previous callback" do
				callback2 = lambda { |data| }
				EventAggregator::Aggregator.register(listener, message_type, callback)
				EventAggregator::Aggregator.register(listener, message_type, callback2)
				
				expect(callback).to_not receive(:call)
				expect(callback2).to receive(:call)

				EventAggregator::Aggregator.message_publish(EventAggregator::Message.new(message_type, data))
			end
		end
		describe 'illegal parameters' do
			it 'message_type raise error' do
				expect{EventAggregator::Aggregator.register(listener, nil, callback)}.to raise_error
			end
			it "listener raise error" do
				expect{EventAggregator::Aggregator.register(nil                                  , message_type, callback)}.to raise_error
				expect{EventAggregator::Aggregator.register(EventAggregator::Message.new("a","b"), message_type, callback)}.to raise_error
				expect{EventAggregator::Aggregator.register(random_string                        , message_type, callback)}.to raise_error
				expect{EventAggregator::Aggregator.register(random_number                        , message_type, callback)}.to raise_error
				expect{EventAggregator::Aggregator.register(2.0                                  , message_type, callback)}.to raise_error
			end
			it 'callback raise error' do
				expect{EventAggregator::Aggregator.register(listener, message_type, nil                                  )}.to raise_error
				expect{EventAggregator::Aggregator.register(listener, message_type, EventAggregator::Message.new("a","b"))}.to raise_error
				expect{EventAggregator::Aggregator.register(listener, message_type, random_string                        )}.to raise_error
				expect{EventAggregator::Aggregator.register(listener, message_type, random_number                        )}.to raise_error
				expect{EventAggregator::Aggregator.register(listener, message_type, 2.0                                  )}.to raise_error
			end
		end
	end

	describe "self.unregister" do
		describe 'legal parameters'  do
			it 'decrease count by 1' do
				EventAggregator::Aggregator.register(listener, message_type, callback)
				expect{EventAggregator::Aggregator.unregister(listener, message_type)}.to change{EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type].length}.by(-1)
			end
			it 'be remove from list' do
				EventAggregator::Aggregator.register(listener, message_type, callback)
				EventAggregator::Aggregator.unregister(listener, message_type)
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type]).to_not include([listener, callback])
			end
			it 'keep listener in unrelated lists' do
				message_type2 = message_type + " different"

				EventAggregator::Aggregator.register(listener, message_type, callback)
				EventAggregator::Aggregator.register(listener, message_type2, callback)

				EventAggregator::Aggregator.unregister(listener, message_type)

				expect(callback).to receive(:call).once

				EventAggregator::Aggregator.message_publish(EventAggregator::Message.new(message_type2,data))
			end
		end
		describe 'unregitering nonregisterd listener' do
			it 'not change list' do
				message_type1 = message_type + " different 1"
				message_type2 = message_type + " different 2"
				message_type3 = message_type + " different 3"
				listener1 	  = listener_class.new
				listener2 	  = listener_class.new
				listener3 	  = listener_class.new

				EventAggregator::Aggregator.register(listener1, message_type1, callback)
				EventAggregator::Aggregator.register(listener2, message_type2, callback)
				EventAggregator::Aggregator.register(listener3, message_type3, callback)

				#Touching hash
				EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type]

				expect{EventAggregator::Aggregator.unregister(listener1, message_type)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.unregister(listener2, message_type)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.unregister(listener3, message_type)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				
				expect(callback).to receive(:call).exactly(3).times

				EventAggregator::Aggregator.message_publish(EventAggregator::Message.new(message_type1,data))
				EventAggregator::Aggregator.message_publish(EventAggregator::Message.new(message_type2,data))
				EventAggregator::Aggregator.message_publish(EventAggregator::Message.new(message_type3,data))
			end
		end
		describe 'unregitering listener from wrong message type' do
			it 'not change list' do
				message_type2 = message_type + " different"

				EventAggregator::Aggregator.register(listener, message_type, callback)

				expect{EventAggregator::Aggregator.unregister(listener, message_type2)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type]}
			end
		end
		describe 'unregitering non-listener class' do
			it 'not change register list' do
				#Touching hash
				EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type]

				expect{EventAggregator::Aggregator.unregister(EventAggregator::Message.new("a","b"), message_type)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.unregister("string", message_type)}.to_not                              change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.unregister(1, message_type)}.to_not                                     change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
				expect{EventAggregator::Aggregator.unregister(2.0, message_type)}.to_not                                   change{EventAggregator::Aggregator.class_variable_get(:@@listeners)}
			end
		end
	end

	describe "self.unregister_all" do
		describe "unregistering listener registered to one message type" do
			it "unregister from list" do
				EventAggregator::Aggregator.register(listener, message_type, callback)

				EventAggregator::Aggregator.unregister_all(listener)

				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type]).to_not  include([listener, callback])
			end
			it "not unregister wrong listener" do
				listener2 = listener_class.new
				listener3 = listener_class.new
				listener4 = listener_class.new

				message_type2 = message_type + " different"
				message_type3 = message_type + " different 2"

				EventAggregator::Aggregator.register(listener, message_type, callback)
				EventAggregator::Aggregator.register(listener2, message_type, callback)
				EventAggregator::Aggregator.register(listener3, message_type2, callback)
				EventAggregator::Aggregator.register(listener4, message_type3, callback)


				EventAggregator::Aggregator.unregister_all(listener)

				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type][listener2]).to eq(callback)
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type2][listener3]).to eq(callback)
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type3][listener4]).to eq(callback)
			end
		end
		describe "unregistering listener registered for several message types" do
			it "unregister from all lists" do
				EventAggregator::Aggregator.register(listener, message_type, callback)
				message_type2 = message_type + " different"
				EventAggregator::Aggregator.register(listener, message_type2, callback)

				EventAggregator::Aggregator.unregister_all(listener)

				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type]).to_not include([listener, callback])
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners)[message_type2]).to_not include([listener, callback])
			end
		end
		describe "unregistering listener registered for all" do
			it "unregister from all" do
				EventAggregator::Aggregator.register_all(listener, callback)

				EventAggregator::Aggregator.unregister_all(listener)

				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners_all)).to_not include([listener, callback])
			end
		end
	end

	describe "self.message_publish" do
		describe 'legal parameters' do
			it 'run correct callback' do
				EventAggregator::Aggregator.register(listener, message_type, callback)
				message = EventAggregator::Message.new(message_type, data)

				expect(callback).to receive(:call).with(data)

				EventAggregator::Aggregator.message_publish(message)
			end
			it 'not run incorrect callback' do
				message_type2 = message_type + " different"

				EventAggregator::Aggregator.register(listener, message_type, callback)
				message = EventAggregator::Message.new(message_type2, data)

				expect(callback).to_not receive(:call).with(data)

				EventAggregator::Aggregator.message_publish(message)
			end

			it 'run correct callback in list' do
				listener2 = listener_class.new
				message_type2 = message_type + " different"

				callback2 = lambda{|data|}

				EventAggregator::Aggregator.register(listener, message_type, callback)
				EventAggregator::Aggregator.register(listener, message_type2, callback2)

				message = EventAggregator::Message.new(message_type, data)

				expect(callback).to receive(:call).with(data)
				expect(callback2).to_not receive(:call)

				EventAggregator::Aggregator.message_publish(message)
			end
			it 'run all callbacks from register_all' do
				listener2 = listener_class.new
				callback2 = lambda{ |message| }
				EventAggregator::Aggregator.register_all(listener, callback)
				EventAggregator::Aggregator.register_all(listener2, callback2)

				message = EventAggregator::Message.new(message_type, data, true, true)

				expect(callback).to receive(:call).with(message)
				expect(callback2).to receive(:call).with(message)

				EventAggregator::Aggregator.message_publish(message)
			end

			it 'runs all callbacks when data is different types' do
				EventAggregator::Aggregator.register_all(listener, callback)
				
				message1 = EventAggregator::Message.new(message_type      , nil)
				message2 = EventAggregator::Message.new(message_type + "2", random_number)
				message3 = EventAggregator::Message.new(message_type + "3", random_string)
				message4 = EventAggregator::Message.new(message_type + "4", empty_object)
				message5 = EventAggregator::Message.new(message_type + "5", true)
				message6 = EventAggregator::Message.new(message_type + "6", false)

				expect(callback).to receive(:call).with(message1)
				expect(callback).to receive(:call).with(message2)
				expect(callback).to receive(:call).with(message3)
				expect(callback).to receive(:call).with(message4)
				expect(callback).to receive(:call).with(message5)
				expect(callback).to receive(:call).with(message6)

				EventAggregator::Aggregator.message_publish(message1)
				EventAggregator::Aggregator.message_publish(message2)
				EventAggregator::Aggregator.message_publish(message3)
				EventAggregator::Aggregator.message_publish(message4)
				EventAggregator::Aggregator.message_publish(message5)
				EventAggregator::Aggregator.message_publish(message6)
			end

			it 'runs all callbacks when data is different types register one' do
				EventAggregator::Aggregator.register(listener, message_type, callback)
				
				message1 = EventAggregator::Message.new(message_type, nil)
				message2 = EventAggregator::Message.new(message_type, random_number)
				message3 = EventAggregator::Message.new(message_type, random_string)
				message4 = EventAggregator::Message.new(message_type, empty_object)
				message5 = EventAggregator::Message.new(message_type, true)
				message6 = EventAggregator::Message.new(message_type, false)
				
				expect(callback).to receive(:call).with(nil)
				expect(callback).to receive(:call).with(random_number)
				expect(callback).to receive(:call).with(random_string)
				expect(callback).to receive(:call).with(empty_object)
				expect(callback).to receive(:call).with(true)
				expect(callback).to receive(:call).with(false)

				EventAggregator::Aggregator.message_publish(message1)
				EventAggregator::Aggregator.message_publish(message2)
				EventAggregator::Aggregator.message_publish(message3)
				EventAggregator::Aggregator.message_publish(message4)
				EventAggregator::Aggregator.message_publish(message5)
				EventAggregator::Aggregator.message_publish(message6)
			end

			it 'run all callbacks for all message types register all' do #Fails with seed: 34154
				EventAggregator::Aggregator.register_all(listener, callback)

				message1 = EventAggregator::Message.new(message_type      , data)
				message2 = EventAggregator::Message.new(message_type + "2", data)
				message3 = EventAggregator::Message.new(message_type + "3", data)
				message4 = EventAggregator::Message.new(message_type + "4", data)
				message5 = EventAggregator::Message.new(message_type + "5", data)
				message6 = EventAggregator::Message.new(message_type + "6", data)


				expect(callback).to receive(:call).with(message1)
				expect(callback).to receive(:call).with(message2)
				expect(callback).to receive(:call).with(message3)
				expect(callback).to receive(:call).with(message4)
				expect(callback).to receive(:call).with(message5)
				expect(callback).to receive(:call).with(message6)


				EventAggregator::Aggregator.message_publish(message1)
				EventAggregator::Aggregator.message_publish(message2)
				EventAggregator::Aggregator.message_publish(message3)
				EventAggregator::Aggregator.message_publish(message4)
				EventAggregator::Aggregator.message_publish(message5)
				EventAggregator::Aggregator.message_publish(message6)
			end
		end
		describe 'illegal parameters' do
			it 'non-message type' do
				expect{EventAggregator::Aggregator.message_publish("string")}.to raise_error
				expect{EventAggregator::Aggregator.message_publish(1)}       .to raise_error
				expect{EventAggregator::Aggregator.message_publish(listener)}.to raise_error
				expect{EventAggregator::Aggregator.message_publish()}        .to raise_error
				expect{EventAggregator::Aggregator.message_publish(nil)}     .to raise_error
			end
		end
		describe 'consisten_data behaviour' do
			it 'uses same object when true' do
				listener2 = listener_class.new
				callback1 = lambda{|data|}
				callback2 = lambda{|data|}

				EventAggregator::Aggregator.register(listener, message_type, callback1)
				EventAggregator::Aggregator.register(listener2, message_type, callback2)

				message = EventAggregator::Message.new(message_type, data, false, true)

				expect(callback1).to receive(:call) {|arg| expect(arg).to equal(data)}
				expect(callback2).to receive(:call) {|arg| expect(arg).to equal(data)}

				EventAggregator::Aggregator.message_publish(message)
			end
			it 'uses different objects when false' do
				listener2 = listener_class.new
				callback1 = lambda{|data| data = "no"}
				callback2 = lambda{|data| data = "no"}

				EventAggregator::Aggregator.register(listener, message_type, callback1)
				EventAggregator::Aggregator.register(listener2, message_type, callback2)

				message = EventAggregator::Message.new(message_type, data, false, false)

				expect(callback1).to receive(:call) {|arg| expect(arg).to_not equal(data)}
				expect(callback2).to receive(:call) {|arg| expect(arg).to_not equal(data)}

				EventAggregator::Aggregator.message_publish(message)
			end
			it 'objects have same values when false' do
				listener2 = listener_class.new
				callback1 = lambda{|data| data = "no"}
				callback2 = lambda{|data| data = "no"}

				EventAggregator::Aggregator.register(listener, message_type, callback1)
				EventAggregator::Aggregator.register(listener2, message_type, callback2)

				message = EventAggregator::Message.new(message_type, data, false, false)

				expect(callback1).to receive(:call) {|arg| expect(arg).to eq(data)}
				expect(callback2).to receive(:call) {|arg| expect(arg).to eq(data)}

				EventAggregator::Aggregator.message_publish(message)
			end
		end
	end

	describe "self.register_all" do
		describe 'legal parameters' do
			it 'registered at correct place' do
				EventAggregator::Aggregator.register_all(listener, callback)
				expect(EventAggregator::Aggregator.class_variable_get(:@@listeners_all)).to include(listener)
			end

			it 'not register same listener multiple times' do
				EventAggregator::Aggregator.register_all(listener, callback)
				expect{EventAggregator::Aggregator.register_all(listener, callback)}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@listeners_all)}
			end
			it "overwrite previous callback" do
				callback2 = lambda { |data| }
				EventAggregator::Aggregator.register_all(listener, callback)
				EventAggregator::Aggregator.register_all(listener, callback2)
				
				expect(callback).to_not receive(:call)
				expect(callback2).to receive(:call)

				EventAggregator::Aggregator.message_publish(EventAggregator::Message.new(message_type, data))
			end
		end
		describe 'illegal parameters' do
			it 'listener raise error' do
				expect{EventAggregator::Aggregator.register_all(nil,                                   callback)}.to raise_error
				expect{EventAggregator::Aggregator.register_all(EventAggregator::Message.new("a","b"), callback)}.to raise_error
				expect{EventAggregator::Aggregator.register_all(random_string,                         callback)}.to raise_error
				expect{EventAggregator::Aggregator.register_all(random_number,                         callback)}.to raise_error
				expect{EventAggregator::Aggregator.register_all(2.0,                                   callback)}.to raise_error
			end
			it 'callback raise error' do
				expect{EventAggregator::Aggregator.register_all(listener, nil                                  )}.to raise_error
				expect{EventAggregator::Aggregator.register_all(listener, EventAggregator::Message.new("a","b"))}.to raise_error
				expect{EventAggregator::Aggregator.register_all(listener, random_string                        )}.to raise_error
				expect{EventAggregator::Aggregator.register_all(listener, random_number                        )}.to raise_error
				expect{EventAggregator::Aggregator.register_all(listener, 2.0                                  )}.to raise_error
			end
		end
	end

	describe "self.reset" do
		it 'removes all listenes' do
			EventAggregator::Aggregator.register(listener, message_type, callback)
			EventAggregator::Aggregator.register_all(listener, callback)
			EventAggregator::Aggregator.translate_message_with(message_type, message_type + " different")
			EventAggregator::Aggregator.register_producer(message_type, callback)

			EventAggregator::Aggregator.reset

			expect(EventAggregator::Aggregator.class_variable_get(:@@listeners))          .to be_empty
			expect(EventAggregator::Aggregator.class_variable_get(:@@listeners_all))      .to be_empty
			expect(EventAggregator::Aggregator.class_variable_get(:@@message_translation)).to be_empty
			expect(EventAggregator::Aggregator.class_variable_get(:@@producers))          .to be_empty
		end

		it 'listener not receive messages' do
			listener2 = listener_class.new
			callback2 = lambda{|data|}
			message = EventAggregator::Message.new(message_type, data)
			EventAggregator::Aggregator.register(listener, message_type, callback)
			EventAggregator::Aggregator.register_all(listener2, callback2)

			EventAggregator::Aggregator.reset

			expect(callback).to_not receive(:call)
			expect(callback2).to_not receive(:call)

			EventAggregator::Aggregator.message_publish(message)
		end
		it "producers not responding" do
			EventAggregator::Aggregator.register_producer(message_type, callback)
			message = EventAggregator::Message.new(message_type, data)

			EventAggregator::Aggregator.reset

			expect(callback).to_not receive(:call)

			EventAggregator::Aggregator.message_request(message)
		end
	end

	describe "self.translate_message_with" do
		describe 'legal parameters' do
			it "creates new message from type" do
				EventAggregator::Aggregator.register(listener, message_type + " different", callback)
				message = EventAggregator::Message.new(message_type, data)

				EventAggregator::Aggregator.translate_message_with(message_type, message_type + " different")

				expect(callback).to receive(:call).with(data)

				EventAggregator::Aggregator.message_publish(message)
			end

			it "listener receives transformed data" do
				EventAggregator::Aggregator.register(listener, message_type + " different", callback)
				message = EventAggregator::Message.new(message_type, "data")

				EventAggregator::Aggregator.translate_message_with(message_type, message_type + " different", lambda{|data| "other data"})

				expect(callback).to receive(:call).with("other data")

				EventAggregator::Aggregator.message_publish(message)
			end

			it "multiple assigns not change list" do
				message = EventAggregator::Message.new(message_type, data)

				EventAggregator::Aggregator.translate_message_with(message_type, message_type + " different")

				expect{EventAggregator::Aggregator.translate_message_with(message_type, message_type + " different")}.to_not change{EventAggregator::Aggregator.class_variable_get(:@@message_translation)}
			end

			it "multiple assigns not publish several messages" do
				EventAggregator::Aggregator.register(listener, message_type + " different", callback)
				message = EventAggregator::Message.new(message_type, data)

				EventAggregator::Aggregator.translate_message_with(message_type, message_type + " different")
				EventAggregator::Aggregator.translate_message_with(message_type, message_type + " different")

				expect(callback).to receive(:call).with(data).once

				EventAggregator::Aggregator.message_publish(message)
			end

			it "multiple assigns to update callback" do
				EventAggregator::Aggregator.register(listener, message_type + " different", callback)
				message = EventAggregator::Message.new(message_type, "data")

				EventAggregator::Aggregator.translate_message_with(message_type, message_type + " different")
				EventAggregator::Aggregator.translate_message_with(message_type, message_type + " different", lambda{|data| "changed data"})

				expect(callback).to receive(:call).with("changed data").once

				EventAggregator::Aggregator.message_publish(message)
			end
		end
		describe 'illegal parameters' do
			it "callback raise error" do
				expect{EventAggregator::Aggregator.translate_message_with(message_type, message_type + " different", nil)}                 .to raise_error
				expect{EventAggregator::Aggregator.translate_message_with(message_type, message_type + " different", random_number)}       .to raise_error
				expect{EventAggregator::Aggregator.translate_message_with(message_type, message_type + " different", random_string)}       .to raise_error
				expect{EventAggregator::Aggregator.translate_message_with(message_type, message_type + " different", Object.new)}          .to raise_error
				expect{EventAggregator::Aggregator.translate_message_with(message_type, message_type + " different", lambda{})}            .to raise_error
				expect{EventAggregator::Aggregator.translate_message_with(message_type, message_type + " different", lambda{ "whatever" })}.to raise_error
			end

			it "message type nil raise error" do
				expect{EventAggregator::Aggregator.translate_message_with(nil,          message_type)}.to raise_error
				expect{EventAggregator::Aggregator.translate_message_with(message_type, nil)}         .to raise_error
				expect{EventAggregator::Aggregator.translate_message_with(nil,          nil)}         .to raise_error
			end

			#Very VERY important that these raise errors!
			it "equal arguments no callback raise error" do
				expect{EventAggregator::Aggregator.translate_message_with(message_type,  message_type)} .to raise_error
				expect{EventAggregator::Aggregator.translate_message_with(random_string, random_string)}.to raise_error
				expect{EventAggregator::Aggregator.translate_message_with(random_number, random_number)}.to raise_error
				expect{EventAggregator::Aggregator.translate_message_with(random_number, random_number)}.to raise_error
				expect{EventAggregator::Aggregator.translate_message_with("string",      "string")}     .to raise_error
				expect{EventAggregator::Aggregator.translate_message_with(1,             1)}            .to raise_error
			end

			it "equal arguments with callback raise error" do
				expect{EventAggregator::Aggregator.translate_message_with(message_type,  message_type,  callback)}.to raise_error
				expect{EventAggregator::Aggregator.translate_message_with(random_string, random_string, callback)}.to raise_error
				expect{EventAggregator::Aggregator.translate_message_with(random_number, random_number, callback)}.to raise_error
				expect{EventAggregator::Aggregator.translate_message_with(random_number, random_number, callback)}.to raise_error
				expect{EventAggregator::Aggregator.translate_message_with("string",      "string",      callback)}.to raise_error
				expect{EventAggregator::Aggregator.translate_message_with(1,             1,             callback)}.to raise_error
			end
		end
	end

	describe "self.register_producer" do
		describe 'illegal parameters' do
			it 'callback raise error' do
				expect{EventAggregator::Aggregator.register_producer(message_type, nil                                  )}.to raise_error
				expect{EventAggregator::Aggregator.register_producer(message_type, EventAggregator::Message.new("a","b"))}.to raise_error
				expect{EventAggregator::Aggregator.register_producer(message_type, random_string                        )}.to raise_error
				expect{EventAggregator::Aggregator.register_producer(message_type, random_number                        )}.to raise_error
				expect{EventAggregator::Aggregator.register_producer(message_type, 2.0                                  )}.to raise_error
			end
		end
	end

	describe "self.unregister_producer" do
		it "producers not responding" do
			EventAggregator::Aggregator.register_producer(message_type, callback)
			message = EventAggregator::Message.new(message_type, data)

			EventAggregator::Aggregator.unregister_producer(message_type)

			expect(callback).to_not receive(:call)

			EventAggregator::Aggregator.message_request(message)
		end
	end


	describe "self.message_request" do
		describe 'legal parameters' do
			it 'run correct callback' do
				EventAggregator::Aggregator.register_producer(message_type, callback)
				message = EventAggregator::Message.new(message_type, data)

				expect(callback).to receive(:call).with(data)

				EventAggregator::Aggregator.message_request(message)
			end
			it 'not run incorrect callback' do
				message_type2 = message_type + " different"

				EventAggregator::Aggregator.register_producer(message_type, callback)
				message = EventAggregator::Message.new(message_type2, data)

				expect(callback).to_not receive(:call).with(data)

				EventAggregator::Aggregator.message_request(message)
			end

			it 'run correct callback in list' do
				message_type2 = message_type + " different"

				callback2 = lambda{|data|}

				EventAggregator::Aggregator.register_producer(message_type, callback)
				EventAggregator::Aggregator.register_producer(message_type2, callback2)

				message = EventAggregator::Message.new(message_type, data)

				expect(callback).to receive(:call).with(data)
				expect(callback2).to_not receive(:call)

				EventAggregator::Aggregator.message_request(message)
			end

		end
		describe 'illegal parameters' do
			it 'non-message type' do
				expect{EventAggregator::Aggregator.message_request("string")}.to raise_error
				expect{EventAggregator::Aggregator.message_request(1)}       .to raise_error
				expect{EventAggregator::Aggregator.message_request(listener)}.to raise_error
				expect{EventAggregator::Aggregator.message_request()}        .to raise_error
				expect{EventAggregator::Aggregator.message_request(nil)}     .to raise_error
			end
		end
	end

	describe 'propagates fully' do
		class TestClassSingle
			include EventAggregator::Listener

			def initialize
				message_type_register("message_type", method(:test_method))
			end

			def test_method(data)
				self.self_called(data)
			end
			def self_called(data)
			end
		end

		class TestClassAll
			include EventAggregator::Listener

			def initialize
				message_type_register_all(method(:test_method))
			end

			def test_method(data)
				self.self_called(data)
			end
			def self_called(data)
			end
		end

		it "calls method on test class single" do
			test_class = TestClassSingle.new
			expect(test_class).to receive(:self_called).with(data)
			message = EventAggregator::Message.new("message_type", data)
			EventAggregator::Aggregator.message_publish(message)
		end

		it "calls method on test class all" do
			test_class = TestClassAll.new
			message = EventAggregator::Message.new("message_type", data)
			expect(test_class).to receive(:self_called){|e| expect(e.message_type).to eq("message_type") and expect(e.data).to eq(data)}
			EventAggregator::Aggregator.message_publish(message)
		end

		it "calls method on test class single full-stack" do
			test_class = TestClassSingle.new
			expect(test_class).to receive(:self_called).with(data)
			message = EventAggregator::Message.new("message_type", data)
			message.publish
		end

		it "calls method on test class all full-stack" do
			test_class = TestClassAll.new
			message = EventAggregator::Message.new("message_type", data)
			expect(test_class).to receive(:self_called){|e| expect(e.message_type).to eq("message_type") and expect(e.data).to eq(data)}
			message.publish
		end
		it "calls method on mulitple" do
			test_class = TestClassAll.new
			test_class2 = TestClassSingle.new
			message = EventAggregator::Message.new("message_type", data)
			expect(test_class).to receive(:self_called){|e| expect(e.message_type).to eq("message_type") and expect(e.data).to eq(data)}
			expect(test_class2).to receive(:self_called){|e| expect(e.message_type).to eq("message_type") and expect(e.data).to eq(data)}
			message.publish
		end
	end
end
module EventAggregator

	# Public: TODO: Could potentially turn this into a module.
	#
	# 	module OtherSingleton
	# 		@index = -1
	# 		@colors = %w{ red green blue }
	# 		def self.change
	# 			@colors[(@index += 1) % @colors.size]
	# 		end
	# 	end
	class Aggregator
		class <<self; private :new; end
		@@pool = Thread.pool(4)
		@@listeners = Hash.new{|h, k| h[k] = Hash.new }
		@@listeners_all = Hash.new
		@@message_translation = Hash.new{|h, k| h[k] = Hash.new }
		@@producers = Hash.new
		# Public: Register an EventAggregator::Listener to receive
		# 		  a specified message type
		#
		# listener - An EventAggregator::Listener which should receive
		# 			 the messages.
		# message_type - The message type to receive. Can be anything except nil.
		# 				 Often it is preferable to use a string eg. "Message Type".
		# callback - The callback that will be executed when messages of type equal
		# 				message_type is published. Is executed with message.data as parameter.
		#
		def self.register( listener, message_type, callback )
			raise "Illegal listener" unless listener.class < EventAggregator::Listener
			raise "Illegal message_type" if message_type == nil
			raise "Illegal callback" unless callback.respond_to?(:call)

			@@listeners[message_type][listener] = callback
		end


		# Public: Register an EventAggregator::Listener to receive
		# 		  every single message that is published.
		#
		# listener - An EventAggregator::Listener which should receive
		# 			 the messages.
		# callback - The callback that will be executed every time a message is published.
		# 				will execute with the message as parameter.
		#
		def self.register_all( listener, callback )
			raise "Illegal listener" unless listener.class < EventAggregator::Listener
			raise "Illegal callback" unless callback.respond_to?(:call)
			@@listeners_all[listener] = callback
		end

		# Public: Unegister an EventAggregator::Listener to a
		# 		  specified message type. The listener will no
		# 		  longer get messages of this type.
		#
		# listener - The EventAggregator::Listener which should no longer receive
		# 			 the messages.
		# message_type - The message type to unregister for.
		def self.unregister( listener, message_type )
			@@listeners[message_type].delete(listener)
		end

		# Public: As Unregister, but will unregister listener from all message types.
		#!
		# listener - The listener who should no longer get any messages at all,
		# 			 regardless of type.
		def self.unregister_all( listener )
			@@listeners.each do |key,value|
				value.delete(listener)
			end
			@@listeners_all.delete(listener)
		end

		# Public: Will publish the specified message to all listeners
		# 		  who has registered for this message type.
		#
		# message - The message to be distributed to the listeners.
		# async - true => message will be sent async. Default true
		# consisten_data - true => the same object will be sent to all recievers. Default false
		def self.message_publish ( message )
			raise "Invalid message" unless message.respond_to?(:message_type) && message.respond_to?(:data)
			@@listeners[message.message_type].each do |listener, callback|	
				perform_message_job(message.data, callback, message.async, message.consisten_data)
			end
			@@listeners_all.each do |listener,callback|
				perform_message_job(message, callback, message.async, message.consisten_data)
			end
			@@message_translation[message.message_type].each do |message_type_new, callback|
				EventAggregator::Message.new(message_type_new, callback.call(message.data)).publish
			end
		end


		# Public: Resets the Aggregator to the initial state. This removes all registered listeners.
		# Use EventAggregator::Aggregator.reset before each test when doing unit testing.
		#
		def self.reset
			@@listeners = Hash.new{|h, k| h[k] = Hash.new}
			@@listeners_all = Hash.new
			@@message_translation = Hash.new{|h, k| h[k] = Hash.new }
			@@producers = Hash.new
		end

		# Public: Will produce another message when a message type is published.
		#
		# message_type - Type of the message that will trigger a new message to be published.
		# message_type_new - The type of the new message that will be published
		# callback=lambda{|data| data} - The callback that will transform the data from message_type to message_type_new. Default: copy.
		#
		def self.translate_message_with(message_type, message_type_new, callback=lambda{|data| data})
			raise "Illegal parameters" if message_type == nil || message_type_new == nil || !callback.respond_to?(:call) || callback.arity != 1 #TODO: The callback.parameters is not 1.8.7 compatible.
			raise "Illegal parameters, equal message_type and message_type_new" if message_type == message_type_new || message_type.eql?(message_type_new)

			@@message_translation[message_type][message_type_new] = callback unless @@message_translation[message_type][message_type_new] == callback
		end

		
		# Public: Registering a producer with the Aggregator. A producer will respond to message requests, a 
		# 			request for a certain piece of data. 
		#
		# message_type - The message type that this callback will respond to.
		# callback - The callback that returns data to the requester. Must have one parameter.
		#
		# Example:
		#
		# 	EventAggregator::Aggregator.register_producer("GetMultipliedByTwo", lambda{|data| data*2})
		#
		def self.register_producer(message_type, callback)
			raise "Illegal message_type" if message_type == nil
			raise "Illegal callback" unless callback.respond_to?(:call) && callback.arity == 1
			
			@@producers[message_type] = callback
		end
		
		
		# Public: Will remove a producer.
		#
		# message_type - The message type which will no longer respond to message requests.
		#
		def self.unregister_producer(message_type)
			@@producers.delete(message_type)
		end

		
		# Public: Request a piece of information.
		#
		# message - The message that will be requested based on its message type and data.
		#
		# Returns The data provided by a producer registered for this specific message type, or nil.
		#
		def self.message_request(message)
			@@producers[message.message_type] ? @@producers[message.message_type].call(message.data) : nil
		end

		private
		def self.perform_message_job(data, callback, async, consisten_data)
			case [async, consisten_data || data == nil]
			when [true, true]   then @@pool.process{ EventAggregator::MessageJob.new.perform(data,       callback) }
			when [true, false]  then @@pool.process{ EventAggregator::MessageJob.new.perform(data.clone, callback) }
			when [false, true]  then EventAggregator::MessageJob.new.perform(data,       callback)
			when [false, false] then EventAggregator::MessageJob.new.perform(data.clone, callback)
			end
		end
	end
end

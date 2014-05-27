module EventAggregator
	# Public: A module you can include or extend to receive messages from
	# the event Aggregator system.
	#
	# Examples
	#
	#   class Foo
	# 		Include Listener
	# 		...
	# 		def initialize()
	# 			...
	# 			message_type_register( "foo", lambda{ puts "bar" } )
	# 		end
	# 		...
	#  	end
	#
	module Listener
		private
		# public: Use to add message types you want to receive. Overwirte existing callback when existing message type is given.
		#
		# message_type 	- A string indicating the message type you want to receive from the event aggregrator. Can actually be anything.
		# callback 		- The method that will be invoked every time this message type is received. Must have: callback.respond_to? :call #=> true
		#
		# Examples
		#
		#   message_type_register("foo", method(:my_class_method))
		#   message_type_register("foo", lambda { puts "foo" })
		#   message_type_register("foo", Proc.new { puts "foo" })
		#
		def message_type_register( message_type, callback )
			Aggregator.register( self, message_type, callback)
		end

		
		# Public: Used to register listener for all message types. Every time a message is published
		# the provided callback will be executed with the message as the content.
		#
		# callback - The method that will be invoked every time this message type is received. Must have: callback.respond_to? :call #=> true
		#
		def message_type_register_all(callback)
			Aggregator.register_all(self, callback)
		end

		# Public: Used to remove a certain type of message from your listening types. Messages of this specific type will no longer
		# invoke any callbacks.
		#
		# message_type - A string indicating the message type you no longer want to receive.
		#
		# Examples
		#
		#   message_type_unregister("foo")
		#
		def message_type_unregister( message_type )
			Aggregator.unregister(self, message_type)
		end

		
		# Public: Will unregister the listener from all message types as well as the message_type_register_all.
		# Listener will no longer recieve any callbacks when messages of any kind are published.
		#
		def message_type_unregister_all
			Aggregator.unregister_all(self)
		end


		
		# Public: Duplicate some text an arbitrary number of times.
		#
		# message_type - A string indicating the the message type the callback will respond to
		# callback - The callback returning data whenever a message requests the message_type.
		#
		# Excample: 
		# 			listener.producer_register("MultiplyByTwo", lambda{|data| return data*2})
		# 			number = EventAggregator::Message.new("MultiplyByTwo", 3).request
		# 			# => 6
		#
		def producer_register(message_type, callback)
			Aggregator.register_producer(message_type, callback)
		end
	end
end

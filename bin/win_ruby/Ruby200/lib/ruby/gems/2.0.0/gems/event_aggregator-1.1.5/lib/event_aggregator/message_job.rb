module EventAggregator
	
	# Public: MessageJob is a class used by the EventAggregator::Aggregator
	# for processing message distribution.
	#
	class MessageJob
		
		# Public: Duplicate some text an arbitrary number of times.
		#
		# data - The data that will be sent to the callback, originating 
		# from a message.
		# callback - The callback that will be processed with the data as 
		# a parameter
		def perform(data, callback)
			callback.call(data)
		end
	end
end
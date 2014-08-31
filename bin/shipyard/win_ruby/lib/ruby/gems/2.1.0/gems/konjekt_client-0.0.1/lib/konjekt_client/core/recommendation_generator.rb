module KonjektClient::Core
	class RecommendationGenerator
		include EventAggregator::Listener

		def initialize
			message_type_register("RecommendFiles", method(:recommend_files))
		end

		def recommend_files(data)
			#TODO: Make this thing gather information and bundle it as a message publish with a request to the server.
			time     = EventAggregator::Message.new("CurrentTimeGet", nil).request
			location = EventAggregator::Message.new("GeoLocationGet", nil).request
			context  = EventAggregator::Message.new("ContextGet", nil).request

			recommendation_data = {:time => time, :location => location, :context => context}
			EventAggregator::Message.new("RecommendFromServer", data).publish
		end
	end
end
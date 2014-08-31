module KonjektClient::Core
	class MessageRouter
		def initialize
			EventAggregator::Aggregator.translate_message_with("FileAdded"        , "FileIndex")
			EventAggregator::Aggregator.translate_message_with("FileChanged"      , "FileIndex")
			EventAggregator::Aggregator.translate_message_with("LoggedIn"         , "TestFirstTimeStartup")
			EventAggregator::Aggregator.translate_message_with("FileIndexed"      , "SendToServerFileIndex")
			EventAggregator::Aggregator.translate_message_with("FileIndexedArray" , "SendToServerFileIndexArray")
			EventAggregator::Aggregator.translate_message_with("TokenSet"         , "StorageTokenSet")
			EventAggregator::Aggregator.translate_message_with("UserSet"          , "StorageUserSet")
			EventAggregator::Aggregator.translate_message_with("LogOut"           , "TokenSet"               , lambda { |e| nil })
			EventAggregator::Aggregator.translate_message_with("LogOut"           , "UserSet"                , lambda { |e| nil })
			EventAggregator::Aggregator.translate_message_with("SearchResults"    , "FilesDisplayTooSlow"    , lambda { |e| parse_result_data(e) })
		end

		def parse_result_data(data)
			res = []
			if defined?(data['response'][0][0]) && data['response'][0][0] != nil
				res = data['response'][0].map{|e| e[0]['_id'].to_i }  #"file_name" is the ID
			end

			path_names = []
			if res.length > 0 && res[0].is_a?(Numeric)
				path_names = EventAggregator::Message.new("FileLookupIDArray", res).request
			end
			#TODO: This is a hack around an issue in the event aggregator which does not pass on async-state.
			EventAggregator::Message.new("FilesDisplay", path_names, false).publish
			
			"Already posted FilesDisplay."
		end
	end
end
module KonjektClient::Core
	class Logger
		include EventAggregator::Listener

		@@konjekt_log = nil

		# def initialize
		# 	@@konjekt_log = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'konjekt.log')) #"konjekt.store"
		# 	message_type_register_all(method(:log_message))
		# end

		# def log_message(message)
		# 	File.open(@@konjekt_log, 'a') do |f|
		# 		f.puts("\n#{@now}: Type: #{message.message_type} __ Data: #{message.data}")
		# 	end
		# end
	end
end
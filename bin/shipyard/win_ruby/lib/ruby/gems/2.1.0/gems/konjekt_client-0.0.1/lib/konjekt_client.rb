require 'event_aggregator'
require 'open-uri'
require 'macaddr'
require 'pstore'
require 'geocoder'
require 'json'

require 'rb-fsevent'
require 'listen'

require 'net/https'
require 'uri'

require 'timeout'
require 'thread'
require 'fileutils'
require 'cgi'

# #For file watcher
# require 'rbconfig'
# gem 'wdm', '>= 0.1.0'     if RbConfig::CONFIG['target_os'] =~ /mswin|mingw|cygwin/i
# gem 'rb-kqueue', '>= 0.2' if RbConfig::CONFIG['target_os'] =~ /freebsd/i
# # end

#TODO: this might break shit
# require 'wdm'       if RbConfig::CONFIG['target_os'] =~ /mswin|mingw|cygwin/i
# require 'rb-kqueue' if RbConfig::CONFIG['target_os'] =~ /freebsd/i



require 'konjekt_client/version'
require 'konjekt_client/core/orta_indexer'
require 'konjekt_client/core/file_indexer'
require 'konjekt_client/core/file_register'
require 'konjekt_client/core/server_connector'
require 'konjekt_client/core/gui'
require 'konjekt_client/core/startup'
require 'konjekt_client/core/file_system_watcher'
require 'konjekt_client/core/server_message_builder'
require 'konjekt_client/core/recommendation_generator'
require 'konjekt_client/core/storage'
require 'konjekt_client/core/utils'
require 'konjekt_client/core/message_router'
require 'konjekt_client/core/logger'



module KonjektClient
	def self.start
		su = KonjektClient::Core::Startup.new
		
		return su.gui
	end
end

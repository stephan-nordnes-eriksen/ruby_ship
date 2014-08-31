module KonjektClient::Core
	module OrtaIndexer
		@@os = nil
		def self.java_path
			ENV['JAVA_HOME'] ? File.join(ENV['JAVA_HOME'], 'bin', 'java') : 'java'
		end
		def self.jar_path
			File.expand_path(File.join(File.expand_path(File.dirname(__FILE__)),'..','..','..','ext','orta13.jar')).untaint
		end
		def self.start_command
			@@os = EventAggregator::Message.new("GetOperatingSystem",nil).request unless @@os

			if @@os == "win"
				prepend = "start \"KonjektOrtaIndexer\""
			else
				prepend = "exec -a KonjektOrtaIndexer"
			end
			#TODO: prepend did not work for some reason.
			return "#{KonjektClient::Core::OrtaIndexer.java_path} -Xmx1g -Djava.awt.headless=true -jar #{KonjektClient::Core::OrtaIndexer.jar_path}".untaint
		end

		#This is code to snoop on every popen command ever called, or whatever else you want. Super-powerfull.
		# set_trace_func proc { |event, file, line, id, binding, classname|
		#	 puts "#{classname} #{id} #{event} #{file} #{line} #{binding.to_json} called" if id == :popen && classname == IO && event == "c-call"
		# }

		def self.process_files(file_list)
			return nil if !file_list.is_a?(Array) || file_list.count <=0
			result = IO.popen KonjektClient::Core::OrtaIndexer.start_command, 'r+' do |io|
				io.write file_list.to_json
				io.close_write
				io.read
			end
			#EventAggregator::Message.new("debug", "Orta index: #{result.parse_json_or_empty_array.inspect} files." ).publish

			return [] unless result && result.is_a?(String)
			return result.parse_json_or_empty_array
		end
	end
end

class String
	def is_json?
		begin
			!!JSON.parse(self)
		rescue
			false
		end
	end
	def parse_json_or_nil
		begin
			JSON.parse(self)
		rescue
			nil
		end
	end
	def parse_json_or_empty_array
		begin
			JSON.parse(self)
		rescue
			[]
		end
	end
end

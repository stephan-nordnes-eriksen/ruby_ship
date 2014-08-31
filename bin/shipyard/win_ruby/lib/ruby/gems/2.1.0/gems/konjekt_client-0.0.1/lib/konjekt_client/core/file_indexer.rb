# encoding: UTF-8

module KonjektClient::Core
	class FileIndexer
		include EventAggregator::Listener
		include KonjektClient::Core::OrtaIndexer

		def initialize
			message_type_register("FileIndexArray", method(:orta_index_files_array))
		end

		def orta_index_files_array(file_array_bulks)
			file_array_bulks.each do |files|
				EventAggregator::Message.new("debug", "Orta about to index: #{files.count} files." ).publish
				indexed_files = OrtaIndexer.process_files(files.map{|d| d[0]}).each_with_index.map do |data, index|
					#EventAggregator::Message.new("debug", "Indexer working on data: #{data.inspect}" ).publish
					{
						#TODO: compact the names here. It will become quite a lot of data.. maybe use 1-char keys.
						:file_path => files[index][0], 
						:file_id => (files[index][1] == nil ? -1 : files[index][1]),
						:file_length => data["fl"],
						:mime_type => data["mt"],
						:language => data["ln"],
						:concepts => data["cs"],
						:mtime => File.mtime(files[index][0].untaint)
					}
				end

				# EventAggregator::Message.new("debug", "Got from orta: #{indexed_files.to_json}" ).publish

				# EventAggregator::Message.new("debug", "Batch done: " + indexed_files.length.to_s).publish
				
				EventAggregator::Message.new("FileIndexedArray", indexed_files).publish if indexed_files && indexed_files.is_a?(Array) && indexed_files.length > 0
			end
		end
	end
end

# The Ruby Ship Completeness test
#
# These tests are meant to verify that different parts of ruby_ship works as expected.
#
# Repo at https://github.com/stephan-nordnes-eriksen/ruby_ship
#
#
# Test requires internet access (testing OpenSSL).
#
#
# The tests works by calling a lambda function. If the lambda raises an error, the 
# test will fail.
#
# Syntax for tests: hash with :method => lambda, :info => string.
# Eg.: {:method => lambda { raise "failing test" }, :info => "Test which never succeed"}
#
# By Stephan Nordnes Eriksen 
# Twitter: @Stephan_NE
#


#
# SETTING UP TESTS
#
tests = []
tests << {
	:method => lambda {
		require 'net/http'
		require 'openssl'
		
		uri = URI.parse("https://google.com/")
		# response = Net::HTTP.get_response uri #Unsure if this invokes openssl

		http = Net::HTTP.new(uri.host, uri.port)
		
		http.read_timeout = 120 #seconds
		http.use_ssl = (uri.scheme == "https")
		http.verify_mode = OpenSSL::SSL::VERIFY_PEER

		request = Net::HTTP::Get.new(uri.request_uri)

		response = http.request(request)

		raise "SSL error OR Google is down" if !response.body || response.body == ""
	},
	:info => "Testing that OpenSSL works. It often seems to be a hard feature to get working right."
}

tests << {
	:method => lambda { 
		require 'rubygems'

		at_least_one_gem_found = false
		Gem::Specification.each do |the_gem|
			at_least_one_gem_found = true
		end
		
		# There will always be at least one gem in ruby_ship. Eg. bigdecimal, rake
		raise "No gems found" unless at_least_one_gem_found
	},
	:info => "Testing that rubygems will load and that there are at least one rubygem installed."
}

tests << {
	:method => lambda { 
		require 'digest'


	},
	:info => "See if the libcrypto dylib is linked correctly"
}

tests << {
	:method => lambda { 
		require 'bundler'
		
		Bundler.ruby_version
	},
	:info => "Test if bundler is installed"
}

#
# RUNNING TESTS
#
failed_tests = []
tests.each_with_index do |test, index|
	begin
		test[:method].call
		puts "Test success: #{index+1}"
	rescue => e
		failed_tests << index

		STDERR.puts "Test failed: #{index+1}. Error: #{e.message}"
		STDERR.puts "--inspect--"
		STDERR.puts "#{e.inspect}"
		STDERR.puts "--backtrace--"
		STDERR.puts "#{e.backtrace.join("\n")}"
	end
end

#
# DISPLAYING RESULTS
#
puts "-----------RESULTS-----------"
if failed_tests.size == 0
	puts "All tests succeeded. Ruby ship is ready to sail!"
else
	puts "#{failed_tests.size} test#{failed_tests.size == 1 ? "":"s"} failed"
	failed_tests.each do |failed|
		puts "Test #{failed+1} failed. #{tests[failed][:info]}"
	end
end


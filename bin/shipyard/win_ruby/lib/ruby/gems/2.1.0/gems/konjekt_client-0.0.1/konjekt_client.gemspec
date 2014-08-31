# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'konjekt_client/version'

Gem::Specification.new do |spec|
	spec.name                  = "konjekt_client"
	spec.version               = KonjektClient::VERSION
	spec.required_ruby_version = '>= 1.8.6'
	spec.authors               = ["Stephan Nordnes Eriksen"]
	spec.email                 = ["sne@konjekt.com"]
	spec.summary               = %q{The client side of Konjekt}
	spec.description           = %q{Runs the file indexer, the server connector and everything that is needed to run our product.}
	spec.homepage              = "https://konjekt.com"
	spec.license               = "Copyright (c) 2014 Stephan Nordnes Eriksen - All Rights Reserved"

	spec.files                 = `git ls-files`.split($/)
	spec.executables           = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files            = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths         = ["lib"]

	spec.add_dependency 'event_aggregator', '~> 1.1', '>= 1.1.5' #Used for: System architecture, sending messages to decouple objects.
	spec.add_dependency 'rb-fsevent', '~> 0.9'                   #Used for: used by listen
	spec.add_dependency 'listen', '0.7.3'                        #Used for: Used for listening to file changes in the system.
	spec.add_dependency 'json', '>= 0'                           #Used for: Used for sending/recieving data to/from server
	spec.add_dependency 'geocoder', '~> 1.1.0'                   #Used for: Used to do IP to Geo loaction lookup
	spec.add_dependency 'macaddr', '>= 0'                        #Used for: Used to get system mac address, which is used to identify a users specific machine.
	spec.add_dependency 'rake', '>= 0'
	
	#spec.add_dependency 'wdm', '>= 0.1.0'     #This might not work. Included in the mkrf_conft.rb
	#spec.add_dependency 'rb-kqueue', '>= 0.2' #This might not work. Included in the mkrf_conft.rb


	spec.extensions << 'ext/mkrf_conf.rb'

	spec.add_development_dependency 'bundler', '~> 1.5'
	
	spec.add_development_dependency 'faker', '>= 0'
	spec.add_development_dependency 'rspec', '~> 2.14'
	spec.add_development_dependency 'guard-rspec', '>= 0'
	spec.add_development_dependency 'webmock', '>= 0'
	spec.add_development_dependency 'debugger', '>= 0'
	spec.add_development_dependency 'activesupport', '>= 0'
end

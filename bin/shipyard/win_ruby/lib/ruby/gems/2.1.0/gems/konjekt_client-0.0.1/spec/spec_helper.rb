require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'faker'
require 'konjekt_client'
require 'listen'
require 'webmock/rspec'
require 'ostruct'
require 'pstore'
require 'debugger'
require 'active_support/all'

RSpec.configure do |config|
  I18n.config.enforce_available_locales = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

#Common resources
#let(:random_string) { Faker::Internet.password }
#let(:random_number) { Faker::Number.number(rand(9)) }


module Listen
	def self.to(*args)
		return
	end
end
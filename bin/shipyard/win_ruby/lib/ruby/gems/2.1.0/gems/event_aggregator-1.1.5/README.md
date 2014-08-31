# EventAggregator gem


[![Gem Version](https://badge.fury.io/rb/event_aggregator.png)][gem]
[![Build Status](https://travis-ci.org/stephan-nordnes-eriksen/event_aggregator.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/stephan-nordnes-eriksen/event_aggregator.png)][gemnasium]
[![Code Climate](https://codeclimate.com/github/stephan-nordnes-eriksen/event_aggregator.png)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/stephan-nordnes-eriksen/event_aggregator/badge.png)][coveralls]
[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/stephan-nordnes-eriksen/event_aggregator/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

[gem]: https://rubygems.org/gems/event_aggregator
[travis]: https://travis-ci.org/stephan-nordnes-eriksen/event_aggregator
[gemnasium]: https://gemnasium.com/stephan-nordnes-eriksen/event_aggregator
[codeclimate]: https://codeclimate.com/github/stephan-nordnes-eriksen/event_aggregator
[coveralls]: https://coveralls.io/r/stephan-nordnes-eriksen/event_aggregator


The gem 'event_aggregator' is designed for use with the event aggregator pattern in Ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'event_aggregator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install event_aggregator

## Usage

	#!/usr/bin/ruby

	require "rubygems"
	require "event_aggregator"

	class Foo
		include EventAggregator::Listener
		def initialize()
			message_type_register( "foo", lambda{|data| puts data } )

			message_type_register( "foo2", method(:handle_message) )
		end

		def handle_message(data)
			puts data
		end
		
		def foo_unregister(*args)
			message_type_unregister(*args)
		end
	end

	f = Foo.new

	EventAggregator::Message.new("foo", "bar").publish
	#=> bar
	EventAggregator::Message.new("foo2", "data").publish
	#=> data
	EventAggregator::Message.new("foo3", "data").publish
	#=> []
	f.foo_unregister("foo2")
	EventAggregator::Message.new("foo2", "data").publish
	#=> []
	
	#Possible outcome:
	EventAggregator::Message.new("foo", "data").publish
	EventAggregator::Message.new("foo", "data2").publish
	#=> data2
	#=> data

### IMPORTANT: Asynchronous by Default
Message.publish is asynchronous by default. This means that if you run event_aggregator in a script that terminates, there is a chance that the script will terminate before the workers have processed the messages. This might cause errors.

A simple way to get around this problem is to do the following:

	#....setup...
	EventAggregator::Message.new("foo2", "data").publish

	gets #This will wait for user input.

To make the message processing synchronous (not recommended) use the following:

	EventAggregator::Message.new("foo", "data", false).publish
	#=> data

The message data is duplicated by default for each of the receiving listeners. To force the same object for all listeners, set the consisten_data property to true.

	EventAggregator::Message.new("foo", "data", true, true).publish
	
This enables the following:

	class Foo
		include EventAggregator::Listener
		def initialize()
			message_type_register( "foo", lambda{|data| data << " bar" } )
		end
	end

	f1 = Foo.new
	f2 = Foo.new
	data = "foo"
	
	EventAggregator::Message.new("foo", data, true, false).publish

	puts data 
	#=> "foo"

	EventAggregator::Message.new("foo", data, true, true).publish
	
	puts data
	#=> "foo bar bar"

	EventAggregator::Message.new("foo", data, true, true).publish
	
	puts data
	#=> "foo bar bar bar bar"


## Producers
In version 1.1+ the concept of producers are added. They are blocks or methods that responds to requests. A producer must be registered, which is done like this:

	#listener is an instance of a class that includes EventAggregator::Listener, similar to the Foo class above.
	listener.producer_register("MultiplyByTwo", lambda{|data| return data*2})

Then, somewhere in your code, you can do the following:

	number = EventAggregator::Message.new("MultiplyByTwo", 3).request
	puts number
	# => 6

The producers are a good way to abstract away the retrieval of certain information.

Note: Message reqests are always blocking.

## Message translation
In version 1.1+ the concept of message translation is added. This allows you to have messages on a specific type spawn other messages. To translate message type "type_1" into "type_2" you do:
	
	#Anywhere in your code
	EventAggregator::Aggregator.translate_message_with("type_1", "type_2")

It is also possible to transform the data in the conversion. To double the data value between "type_1" and "type_2" you do:

	EventAggregator::Aggregator.translate_message_with("type_1", "type_2", lambda{|data| data*2})

This is often very usefull when you have one module that has a specific task, and it should be truly independent of other objects, even the message type they produce. The message translation allows you to have one file where you list all translations to give you a good overview and high maintainability.

## Usage Considerations
All messages are processed asynchronous by default. This means that there might be raise conditions in your code. 

If you force synchronous message publishing you should take extra care of where in your code you produce new messages. You can very easily create infinite loops where messages are published and consumed by the same listener. Because of this it is advised not to produce messages within the callback for the listener, even when using asynchronous message publishing. Another good rule is never to produce messages of the same type as those you listen to. This does not completely guard you, as there can still exist loops between two or more listeners.

## About Event Aggregators
An event aggregator is essentially a message passing service that aims at decoupling objects in your code. This is achieved with messages that has a type and some data. A message might be produced when an event, or other condition, occurs. When such conditions occurs a message can be produced with all relevant data in it. This message can then be published. The message will then be distributed to all other objects that want to receive this message type. This way the object or class that produced the message do not need to be aware of every other object that might be interested in the condition that just occurred. It also removes the need for this class to implement any consumer producer pattern or other similar methods to solving this problem. With an event aggregator the listener, the receiver of the message, does not need to know that the sender even exists. This will remove a lot of bug-producing couplings between objects and help your code become cleaner.

For more information see: http://martinfowler.com/eaaDev/EventAggregator.html 

Or: https://www.google.com/#q=event+aggregator

## Todo:
 - Improving the readme and documentation in the gem.

## Versioning Standard:
Using Semantic Versioning - http://semver.org/
### Versioning Summary

#### 0.0.X - Patch
	Small updates and patches that are backwards-compatible. Updating from 0.0.X -> 0.0.Y should not break your code.
#### 0.X - Minor
	Adding functionality and changes that are backwards-compatible. Updating from 0.X -> 0.Y should not break your code.
#### X - Major
	Architectural changes and other major changes that alter the API. Updating from X -> Y will most likely break your code.
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

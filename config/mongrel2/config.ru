#!/usr/bin/env ruby
require 'rubygems'
require 'bundler'
Bundler.setup(:default)

require 'rack/handler/mongrel2'

#Setup your own load paths here
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
require 'server'

#The connection specs are NOT optional, and they must 
#be the opposite of what you declared in the Mongrel
#config--so 'recv' connects to 'send' and vice-versa.
Rack::Handler::Mongrel2.run(  Sinatra::Application, 
                              :recv => "tcp://127.0.0.1:9997", 
                              :send => "tcp://127.0.0.1:9996", 
                              :uuid => "B811AAB7-F7AD-4E2E-B755-8B1E7E52317F",
                              :block => true)               

exit(0)
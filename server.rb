# ts.rb

$:.unshift *Dir[File.dirname(__FILE__) + "/app/**"]

require 'rubygems'
require 'bundler'
Bundler.require
require 'sinatra'
require 'sinatra/activerecord'
require 'ruby-debug'
require 'haml'
require 'guid'

require 'app/core'
require 'app/config'
require 'tuple'
require 'tag'

get '/read/*.*' do |path, ext|
  read_tuples(path, ext)
end

get '/read/*' do
  read_tuples(params[:splat][0], 'json')
end

get '/write/*' do
  write_tuple(params[:splat][0], params[:value])
end

post '/write/*' do
  write_tuple(params[:splat][0], params[:value])
end

put '/write/*' do
  write_tuple(params[:splat][0], params[:value])
end

get '/take/:guid' do
  take_tuple(params[:guid])
end

delete '/take/:guid' do
  take_tuple(params[:guid])
end

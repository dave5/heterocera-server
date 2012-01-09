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

require './app/core'
require './app/config'
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

get '/take/*.*' do |path, ext|
  take_tuples(path, ext)
end

get '/take/*' do 
  take_tuples(params[:splat][0], 'json')
end

not_found do
  haml :home unless valid_action?(request.path_info)
end
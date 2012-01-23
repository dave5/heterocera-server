require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require File.join(File.dirname(__FILE__), 'environment')

configure do
  set :views, File.dirname(__FILE__) + '/views'
  set :haml, :format => :html5
  set :file_root, File.dirname(__FILE__) + '/../files'
  set :temp_dir, File.dirname(__FILE__) + '/../tmp'
end

error do
  e = request.env['sinatra.error']
  Kernel.puts e.backtrace.join("\n")
  'Application error'
end

get '/read/*' do 
  read_tuples(params[:splat][0], 'json')
end

get '/read/*.*' do |path, ext|
  read_tuples(path, ext)
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

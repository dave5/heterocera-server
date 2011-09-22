# app.rb
require 'rubygems'
require 'bundler'
Bundler.require
require 'sinatra'
require 'sinatra/activerecord'
require 'ruby-debug'
require 'tuple'
require 'tag'

configure do
  config = YAML::load(File.open('config/database.yml'))
  environment = Sinatra::Application.environment.to_s
  ActiveRecord::Base.logger = Logger.new($stdout)
  ActiveRecord::Base.establish_connection(
    config[environment]
  )
end

def path_to_tags(path)
  path.split('/')
end

def get_tuples(path)
  tags    = path_to_tags(path)
  tuples  = Tuple.find_by_tag_list tags  
end

get '/read/*.*' do |path, ext|
  tuples = get_tuples(path)

  case ext
  when 'json'
    content_type :json
    tuples.to_json
  when 'xml'
    content_type :xml
    tuples.to_xml
  end
end

get '/read/*' do
  tuples = get_tuples(params[:splat][0])
  content_type :json
  tuples.to_json
end

get '/write/*' do
  tags = path_to_tags(params[:splat][0])

  if params[:value].present?
    tuple = Tuple.from_tags(params[:value], tags) 
    content_type :json
    tuple.to_json
  else
    error 400 do
      "Please provide a value"
    end
  end
end

post '/write/*' do
end

put '/write/*' do
end

get '/take/:id' do
end

delete '/take/:id' do
end

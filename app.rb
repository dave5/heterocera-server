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


def path_to_tags(path)
  path.split('/')
end

def get_tuples(path, ext)
  tags    = path_to_tags(path)
  tuples  = Tuple.find_by_tag_list tags 
  
  if tuples.length > 0 
    case ext
    when 'json'
      content_type :json
      tuples.to_json
    when 'xml'
      content_type :xml
      tuples.to_xml
    end
  else
    error 404 do
      "No data found"
    end
  end
end

def write_tuple(value, tags)
  unless tags.include?('*')
    if value.present?
      tuple = Tuple.from_tags(value, tags) 
      content_type :json
      tuple.to_json
    else
      error 400 do
        "Please provide a value"
      end
    end
  else
    error 400 do
      "Wildcards cannot be used for writing data"
    end
  end
end

get '/read/*.*' do |path, ext|
  get_tuples(path, ext)
end

get '/read/*' do
  get_tuples(params[:splat][0], 'json')
end

get '/write/*' do
  write_tuple(params[:value], path_to_tags(params[:splat][0]))
end

post '/write/*' do
  write_tuple(params[:value], path_to_tags(params[:splat][0]))
end

put '/write/*' do
  write_tuple(params[:value], path_to_tags(params[:splat][0]))
end

get '/take/:id' do
end

delete '/take/:id' do
end

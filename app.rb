# app.rb

$:.unshift *Dir[File.dirname(__FILE__) + "/models"]

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

def read_tuples(path, ext)
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
    when 'html'
      
    end
  else
    error 404 do
      "No data found"
    end
  end
end

def write_tuple(path, value)
  tags = path_to_tags(path)

  unless tags.include?('*')
    if value.present?
      tuple = Tuple.from_tags!(value, tags) 
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

def take_tuple(id)
  tuple = Tuple.find(:first, :conditions => ["id = ? AND marked_for_delete_at IS NULL", id])

  if tuple.present?
    tuple.mark_for_deletion!
    status 200
  else
    error 404 do
      "No data found"
    end
  end
end

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

get '/take/:id' do
  take_tuple(params[:id])
end

delete '/take/:id' do
  take_tuple(params[:id])
end

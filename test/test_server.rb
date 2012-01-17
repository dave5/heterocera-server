require 'rubygems'
require 'rack/test'
require 'test/unit'
require './server'

ENV['RACK_ENV'] = 'test'

class ServerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_clear
  end

  def test_gets_root
    get '/'
    assert !last_response.ok?
    assert last_response.body.include?("Remember something")
  end

  def test_get_write
    get "/write/foo/baa", {:value => 'test_write'}
    assert JSON.parse(last_response.body)["value"] == 'test_write'
  end

  def test_post_write
  end

  def test_read
    get "/write/get/read/baa", {:value => 'test_write'}
    assert JSON.parse(last_response.body)["value"] == 'test_write'

    get "/read/get/read/baa"
    assert JSON.parse(last_response.body)[1]["value"] == 'test_write'    
  end

  def test_take
  end
end
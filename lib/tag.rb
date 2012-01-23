class Tag

  include DataMapper::Resource

  property :id,    Serial
  property :value, String, :index => true
  property :display_order, Integer

  belongs_to :tuple

end
class Tag < ActiveRecord::Base

  belongs_to :tuple

  def as_json(options=nil)
    {
      :value => value,
      :order => order
    }
  end

  def to_xml(options=nil)
    options.merge!(:only => [:value, :order])
    super(options)
  end
end
class Tag < ActiveRecord::Base

  belongs_to :tuple

  def as_json(options=nil)
    {
      :value => value,
      :order => order
    }
  end

end
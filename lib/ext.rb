module HeteroceraStringExtensions
  def blank?
    empty?
  end

  def present?
    !blank?
  end
end

class String
  include HeteroceraStringExtensions
end
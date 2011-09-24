class Tuple < ActiveRecord::Base

  has_many :tags, :dependent => :destroy

  def self.find_by_tag_list tag_list
    unless tag_list.uniq.to_s == '*'
      find_by_sql(tag_list_to_sql(tag_list))
    else
      []
    end
  end

  def self.from_tags(value, tags)
    tuple = new(:value => value)
    tags.each_index do |index|
      tuple.tags << Tag.new(:order => (index + 1), :value => tags[index])
    end
    tuple.save!

    tuple
  end

  def as_json(options=nil)
    {
      :id         => id,
      :value      => value,
      :created_at => created_at,
      :tags       => tags
    }
  end
  
  def to_xml(options = {})
    options.merge!(:except => [:marked_for_delete_at, :updated_at], :include => [:tags])
    super(options)
  end

  private
    def self.tag_list_to_sql tag_list
      first_entry = nil
      sql = 'SELECT tuples.* FROM '

      tag_list.each_index do |i|
        unless tag_list[i] == '*'
          order = i + 1
           
          # create sub_select
          sql << "(SELECT tuple_id FROM tags WHERE (tags.order = #{order} and tags.value = '#{tag_list[i]}')) s#{order}"

          if first_entry.present?
            sql << " ON s#{first_entry}.tuple_id = s#{order}.tuple_id"
          else
            first_entry = order
          end
          # create join
          sql << " JOIN "
        end
      end

      sql << "tuples ON s#{first_entry}.tuple_id = tuples.id WHERE tuples.marked_for_delete_at IS NULL ORDER BY tuples.created_at DESC;"

    end

end
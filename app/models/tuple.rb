class Tuple < ActiveRecord::Base

  has_many :tags, :dependent => :destroy

  before_destroy :delete_file

  def self.find_by_tag_list tag_list
    unless tag_list.uniq.to_s == '*'
      find_by_sql(tag_list_to_sql(tag_list))
    else
      []
    end
  end

  def self.from_tags!(value, tags, file_directory = "")
    save_tuple = true

    tuple_value = (is_a_file?(value)) ? value[:filename] : value
    tuple       = new(:value => tuple_value, 
                      :is_file => is_a_file?(value), 
                      :guid => Guid.new.to_s.gsub('-', ''))

    tags.each_index do |index|
      tuple.tags << Tag.new(:order => (index + 1), :value => tags[index])
    end

    save_tuple = tuple.write_file(value, file_directory) if is_a_file?(value)

    tuple.save! if save_tuple
    
    [save_tuple, tuple]
  end

  def self.marked_for_deletion
    find :all, :conditions => ['marked_for_delete_at IS NOT NULL']
  end

  def mark_for_deletion!
    update_attributes(:marked_for_delete_at => Time.now)
  end

  def tags_to_path
    tags.collect{|tag| tag.value}.join("/")
  end

  def as_json(options=nil)
    {
      :id         => guid,
      :value      => value,
      :created_at => created_at,
      :tags       => tags
    }
  end
  
  def to_xml(options = {})
    options.merge!(:except => [:marked_for_delete_at, :updated_at], :include => [:tags])
    super(options)
  end

  def file_location
    File.join file_directory, value
  end

  def write_file(file_data, directory)

    unless file_data &&
           (tmpfile = file_data[:tempfile]) &&
           (name = file_data[:filename])
      return false
    end

    # create directory
    location = File.join directory, file_directory
    FileUtils.mkdir_p(location) unless File.exists?(location)

    # write file
    FileUtils.cp(tmpfile.path, File.join(directory, file_location))

    return true
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

    def file_directory
      File.join tags_to_path, guid
    end

    def destroy_file
      File.delete(file_location) if File.exists?(file_location)
    end

    def self.is_a_file?(value)
      value_is_file = false

      if value.length > 1
        if value[:filename].present?
          value_is_file = true
        end
      end

      return value_is_file
    end

end
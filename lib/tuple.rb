class Tuple 

  include DataMapper::Resource

  property :id,                   Serial
  property :value,                Text, :lazy => [:show]
  property :guid,                 String
  property :is_file,              Boolean
  property :marked_for_delete_at, DateTime
  property :created_at,           DateTime
  property :updated_at,           DateTime

  has n, :tags

  before :destroy, :destroy_file

  def self.find_by_tag_list tag_list
    tuples = []
    debugger
    tuples = find_by_sql(tag_list_to_sql(tag_list)) unless tag_list.uniq[0].to_s == '*'
  end

  def self.from_tags!(value, tags)

    save_tuple = true

    tuple_value = (Tuple.is_a_file?(value)) ? value[:filename] : value

    tuple       = Tuple.new
    tuple.value = tuple_value
    tuple.is_file  = Tuple.is_a_file?(value)
    tuple.guid     = Guid.new.to_s.gsub('-', '')
    tuple.created_at = Time.now
    tuple.updated_at = Time.now

    save_tuple = tuple.write_file(value) if is_a_file?(value)

    if save_tuple
    
      tags.each_index do |index|
        tag = Tag.create
        tag.display_order = (index + 1)
        tag.value         = tags[index]
        tuple.tags << tag 
      end

      tuple.save
    end
    
    [save_tuple, tuple]
  end

  def self.marked_for_deletion
    find :all, :conditions => ['marked_for_delete_at IS NOT NULL']
  end

  def mark_for_deletion!
    update_attributes(:marked_for_delete_at => Time.now, :updated_at => Time.now)
  end

  def tags_to_path(pop_depth = 0)
    tag_array = tags.collect{|tag| tag.value}
    tag_array.pop(pop_depth) if pop_depth > 0
    tag_array.join("/")
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
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.tuple do
      xml.tag!(:id, guid)
      xml.tag!(:value, value)
      xml.tag!(:created_at, created_at)
      xml.tags do
        tags.each do |tag|
          xml.tag do
            xml.tag! :value, tag.value
            xml.tag! :order, tag.order
          end
        end
      end
    end
  end

  def file_location
    File.join file_directory, value
  end

  def write_file(file_data)

    unless file_data &&
           (tmpfile = file_data[:tempfile]) &&
           (name = file_data[:filename])
      return false
    end

    # create directory
    FileUtils.mkdir_p(file_directory) unless File.exists?(file_directory)

    # write file
    FileUtils.cp(tmpfile.path, file_location)

    return true
  end

  private
    def self.tag_list_to_sql tag_list
      first_entry = nil
      sql = '
            SELECT 
              culled_tuples.* 
            FROM
              (SELECT
                selected_tuples.*,
                tags.tuple_id,
                tags.display_order,
                tags.value as tag_value,
                COUNT(tags.tuple_id) as tag_count
              FROM
              (SELECT tuples.* FROM '


      tag_list.each_index do |i|
        unless tag_list[i] == '*'
          order = i + 1
           
          # create sub_select
          sql << "(SELECT tuple_id FROM tags WHERE (tags.display_order = #{order} and tags.value = '#{tag_list[i]}')) s#{order}"

          unless first_entry.nil?
            sql << " ON s#{first_entry}.tuple_id = s#{order}.tuple_id"
          else
            first_entry = order
          end
          # create join
          sql << " JOIN "
        end
      end

      sql << "tuples ON s#{first_entry}.tuple_id = tuples.id"
      sql << ') selected_tuples
              LEFT JOIN
                tags ON selected_tuples.id = tags.tuple_id
              GROUP BY
                tags.tuple_id) AS culled_tuples
              WHERE'
      sql << " culled_tuples.tag_count = #{tag_list.length} AND culled_tuples.marked_for_delete_at IS NULL 
              ORDER BY 
                culled_tuples.created_at DESC;"

    end

    def file_directory
      File.join Sinatra::Application.settings.file_root, tags_to_path, guid
    end

    def destroy_file
      return true unless is_file

      FileUtils.rm(file_location)
      Dir.rmdir file_directory

      containing_dir = file_directory.split("/")
      containing_dir.pop

      while (Dir.entries(File.join(containing_dir))-['.','..']).empty? ||
            (File.join(containing_dir) != Sinatra::Application.settings.file_root)
        Dir.rmdir File.join(containing_dir)
        containing_dir.pop          
      end 

      true
    end

    def self.is_a_file?(value)
      value_is_file = false
        
      if value.class == Hash
        unless value[:filename].empty?
          value_is_file = true
        end
      end

      return value_is_file
    end

end
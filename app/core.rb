# core.rb

def path_to_tags(path)
  path.split('/')
end

def read_tuples(path, ext)
  tags    = path_to_tags(path)
  @tuples  = Tuple.find_by_tag_list tags 
  
  if @tuples.length > 0 
    case ext
    when 'json'
      content_type :json
      @tuples.to_json
    when 'xml'
      content_type :xml
      @tuples.to_xml
    when 'html'
      haml :read
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
      saved, tuple = Tuple.from_tags!(value, tags, settings.temp_dir) 
      if saved
        content_type :json
        tuple.to_json
      else
        error 500 do
          "There was a problem saving the data"
        end
      end
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
  tuple = Tuple.find(:first, :conditions => ["guid = ? AND marked_for_delete_at IS NULL", id])

  if tuple.present?
    tuple.mark_for_deletion!
    status 200
  else
    error 404 do
      "No data found"
    end
  end
end
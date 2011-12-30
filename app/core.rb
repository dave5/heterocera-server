# core.rb

def path_to_tags(path)
  path.split('/')
end

def read_tuples(path, ext)
  tags     = path_to_tags(path)
  @tuples  = Tuple.find_by_tag_list tags 
  
  render_tuples @tuples, ext
end

def write_tuple(path, value)
  tags = path_to_tags(path)

  unless tags.include?('*')
    if value.present?
      saved, tuple = Tuple.from_tags!(value, tags, settings.file_root) 
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

def take_tuples(path, ext)
  tags = path_to_tags(path)

  unless tags.include?('*')
    @tuples  = Tuple.find_by_tag_list tags

    @tuples.each do |tuple|
      tuple.mark_for_deletion! if tuple.present?
    end

    render_tuples @tuples, ext
  else
    error 400 do
      "Wildcards cannot be used for writing data"
    end
  end
end

def compress_and_send(tuples)
  # generate temp dir
  temp_name = Guid.new.to_s.gsub('-', '')
  temp_dir = File.join settings.temp_dir, temp_name
  temp_tar = "#{temp_name}.tar.gz"
  FileUtils.mkdir_p temp_dir

  # write out tuple js as header file
  File.open(File.join(temp_dir, 'json'), 'w') {|f| f.write(tuples.to_json) }

  # for each tuple
  tuples.each do |tuple|
    if tuple.is_file
      # create directory
      file_dir = File.join temp_dir, tuple.guid
      FileUtils.mkdir_p file_dir
          
      # copy file
      FileUtils.cp File.join(settings.file_root, tuple.file_location), File.join(file_dir, tuple.value)
    end
  end

  # compress
  Dir.chdir(settings.temp_dir) do
    `tar -czf #{temp_tar} #{temp_name}`   
  end

  # send file
  send_file File.join(settings.temp_dir, temp_tar), 
            :type => 'application/octet-stream', 
            :disposition => 'inline', 
            :filename => temp_tar

end

def render_tuples(tuples, ext)
  if tuples.length > 0 
    case ext
    when 'json'
      content_type :json
      tuples.to_json
    when 'xml'
      content_type :xml
      tuples.to_xml
    when 'gz'
      compress_and_send tuples
    when 'html'
      haml :render
    end
  else
    error 404 do
      "No data found"
    end
  end
end
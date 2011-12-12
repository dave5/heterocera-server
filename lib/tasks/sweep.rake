require 'server'

namespace :heterocera do  
  
  namespace :server do

    desc "Sweep out old tmp files"
    task :sweep_tmp_dir do      
      Dir.foreach(settings.temp_dir) do |file_name|

        full_path = File.join(settings.temp_dir, file_name)

        unless file_name.starts_with?('.')
          FileUtils.rm_rf full_path if File.ctime(full_path) < (Time.now.beginning_of_day - 3600)
        end
      end
    end

    desc "Sweep out old tuple records"
    task :sweep_tuples do
      tuples = Tuple.marked_for_deletion
      tuples.each{|t| t.destroy}
    end

  end
  
end

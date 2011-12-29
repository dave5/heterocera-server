class CreateTuples < ActiveRecord::Migration
  def self.up
    create_table(:tuples, :options => 'DEFAULT CHARSET=utf8') do |t|
      t.text     :value
      t.string   :guid
      t.boolean  :is_file
      t.datetime :marked_for_delete_at
      t.timestamps
    end



  end

  def self.down
    drop_table :tuples
  end
end

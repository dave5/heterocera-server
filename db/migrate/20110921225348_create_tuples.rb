class CreateTuples < ActiveRecord::Migration
  def self.up
    create_table :tuples do |t|
      t.text     :value
      t.datetime :marked_for_delete_at
      t.timestamps
    end
  end

  def self.down
    drop_table :tuples
  end
end

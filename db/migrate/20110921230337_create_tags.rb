class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.integer :tuple_id, :order
      t.string  :value
      t.timestamps
    end

    add_index :tags, :value
    add_index :tags, :tuple_id
  end

  def self.down
    drop_table :tags
  end
end

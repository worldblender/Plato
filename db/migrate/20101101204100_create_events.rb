class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :event_type
      t.text    :data
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end

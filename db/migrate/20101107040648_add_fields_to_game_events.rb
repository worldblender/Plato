class AddFieldsToGameEvents < ActiveRecord::Migration
  def self.up
    add_column :game_events, :fields, :text
  end

  def self.down
    remove_column :game_events, :fields
  end
end

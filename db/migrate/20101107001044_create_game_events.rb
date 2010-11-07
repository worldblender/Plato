class CreateGameEvents < ActiveRecord::Migration
  def self.up
    create_table :game_events do |t|
      t.timestamps
    end
  end

  def self.down
    drop_table :game_events
  end
end

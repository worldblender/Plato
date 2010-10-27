class AddDurationToBombs < ActiveRecord::Migration
  def self.up
    add_column :bombs, :duration, :float
  end

  def self.down
    remove_column :bombs, :duration
  end
end

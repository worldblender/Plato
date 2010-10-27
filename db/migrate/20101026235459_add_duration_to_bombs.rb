class AddDurationToBombs < ActiveRecord::Migration
  def self.up
    add_column :bombs, :duration, :integer
  end

  def self.down
    remove_column :bombs, :duration
  end
end

class AddDidExplodeToBombs < ActiveRecord::Migration
  def self.up
    add_column :bombs, :did_explode, :boolean, :default => false
  end

  def self.down
    remove_column :bombs, :did_explode
  end
end

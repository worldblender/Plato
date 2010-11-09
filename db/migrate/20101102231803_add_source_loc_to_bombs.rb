class AddSourceLocToBombs < ActiveRecord::Migration
  def self.up
    add_column :bombs, :srcLat, :float
    add_column :bombs, :srcLng, :float
  end

  def self.down
    remove_column :bombs, :srcLng
    remove_column :bombs, :srcLat
  end
end

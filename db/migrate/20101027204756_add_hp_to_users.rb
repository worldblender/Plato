class AddHpToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :hp, :float
  end

  def self.down
    remove_column :users, :hp
  end
end

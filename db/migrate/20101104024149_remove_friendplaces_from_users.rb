class RemoveFriendplacesFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :friendplaces
  end

  def self.down
    add_column :users, :friendplaces, :string
  end
end

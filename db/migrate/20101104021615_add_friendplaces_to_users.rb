class AddFriendplacesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :friendplaces, :string
  end

  def self.down
    remove_column :users, :friendplaces
  end
end

class AddFplacesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :fplaces, :text
  end

  def self.down
    remove_column :users, :fplaces
  end
end

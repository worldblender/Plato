class AddNotifioConfiguredToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :notifo_configured, :boolean
  end

  def self.down
    remove_column :users, :notifo_configured
  end
end

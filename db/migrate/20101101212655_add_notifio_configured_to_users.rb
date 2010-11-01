class AddNotifioConfiguredToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :notifio_configured, :boolean
  end

  def self.down
    remove_column :users, :notifio_configured
  end
end

class AddNotifioToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :notifo_account, :string
  end

  def self.down
    remove_column :users, :notifo_account
  end
end

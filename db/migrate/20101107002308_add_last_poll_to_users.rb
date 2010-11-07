class AddLastPollToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_poll, :DateTime
  end

  def self.down
    remove_column :users, :last_poll
  end
end

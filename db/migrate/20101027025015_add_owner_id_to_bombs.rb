class AddOwnerIdToBombs < ActiveRecord::Migration
  def self.up
    add_column :bombs, :owner_id, :integer
  end

  def self.down
    remove_column :bombs, :owner_id
  end
end

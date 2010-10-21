class CreateBombs < ActiveRecord::Migration
  def self.up
    create_table :bombs do |t|
      t.float :latitude
      t.float :longitude
      t.datetime :createtime
      t.datetime :detonatetime

      t.timestamps
    end
  end

  def self.down
    drop_table :bombs
  end
end

class AddTopScoreToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :top_score, :integer
  end

  def self.down
    remove_column :users, :top_score
  end
end

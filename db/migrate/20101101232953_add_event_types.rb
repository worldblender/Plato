class AddEventTypes < ActiveRecord::Migration
  def self.up
    %w(kill hit throw respawn move).each do |s|
        EventType.new(:event_name => s).save
    end
  end

  def self.down
    EventType.destroy_all
  end
end

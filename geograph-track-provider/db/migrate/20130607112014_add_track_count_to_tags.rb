class AddTrackCountToTags < ActiveRecord::Migration
  def change
    add_column :tags, :track_count, :integer
  end
end

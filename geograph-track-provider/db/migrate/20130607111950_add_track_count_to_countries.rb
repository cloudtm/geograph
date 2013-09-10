class AddTrackCountToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :track_count, :integer
  end
end

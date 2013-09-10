class AddCitycountryToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :citycountry, :string
    add_column :tracks, :citycountry_idx, :integer
  end
end

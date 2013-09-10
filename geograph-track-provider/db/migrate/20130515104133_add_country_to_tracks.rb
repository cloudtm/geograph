class AddCountryToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :country, :string
  end
end

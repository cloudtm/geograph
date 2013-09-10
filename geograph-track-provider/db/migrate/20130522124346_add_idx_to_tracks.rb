class AddIdxToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :city_idx, :integer
    add_column :tracks, :country_idx, :integer
    add_column :tracks, :continent_idx, :integer
    add_index :tracks, [ :city, :city_idx ]
    add_index :tracks, [ :country, :country_idx ]
    add_index :tracks, [ :continent, :continent_idx ]
  end
end

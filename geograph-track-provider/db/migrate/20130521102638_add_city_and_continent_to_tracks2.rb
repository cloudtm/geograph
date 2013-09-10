class AddCityAndContinentToTracks2 < ActiveRecord::Migration
  def change
    add_column :tracks, :city, :string
    add_column :tracks, :continent, :string
    add_index :tracks, :city
    add_index :tracks, :continent
    add_index :tracks, :country
  end
end

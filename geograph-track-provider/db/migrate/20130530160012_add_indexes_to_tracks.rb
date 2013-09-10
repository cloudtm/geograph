class AddIndexesToTracks < ActiveRecord::Migration
  def change
    add_index :tracks, :citycountry
    add_index :tracks, [ :citycountry, :citycountry_idx ]
  end
end

class AddFirstPositionToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :first_position_latitude, :float
    add_column :tracks, :first_position_longitude, :float
    add_index :tracks, :first_position_latitude
    add_index :tracks, :first_position_longitude
    add_index :tracks, [:first_position_latitude, :first_position_longitude], :name => 'first_position_index'
  end
end

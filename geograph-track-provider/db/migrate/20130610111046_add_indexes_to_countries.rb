class AddIndexesToCountries < ActiveRecord::Migration
  def change
    add_index :countries, [ :name, :track_count ]
  end
end

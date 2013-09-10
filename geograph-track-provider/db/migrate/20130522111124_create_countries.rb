class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :name
      t.float :min_latitude
      t.float :max_latitude
      t.float :min_longitude
      t.float :max_longitude
      t.string :country
      t.string :continent

      t.timestamps
    end

    add_index :countries, :country
    add_index :countries, :name
  end
end

class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.float :min_latitude
      t.float :min_longitude
      t.float :max_latitude
      t.float :max_longitude

      t.timestamps
    end
  end
end

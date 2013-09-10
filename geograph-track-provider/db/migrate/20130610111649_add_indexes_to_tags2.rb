class AddIndexesToTags2 < ActiveRecord::Migration
  def change
    add_index :tags, [ :name, :track_count ]
  end
end

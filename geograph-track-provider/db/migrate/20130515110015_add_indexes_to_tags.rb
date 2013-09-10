class AddIndexesToTags < ActiveRecord::Migration
  def change
    add_index :tags, :country
    add_index :tags, :name
  end
end

class AddCountryToTags < ActiveRecord::Migration
  def change
    add_column :tags, :country, :string
  end
end

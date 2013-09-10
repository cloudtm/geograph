class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.string :title
      t.string :filename
      t.text :content

      t.timestamps
    end
  end
end

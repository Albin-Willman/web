class AddAlbumCategories < ActiveRecord::Migration
  def change
    create_table :albums_categories, id: false do |t|
      t.integer :album_id
      t.integer :category_id
      t.index   [:album_id,:category_id], unique: true
      t.index   :category_id
    end
  end
end

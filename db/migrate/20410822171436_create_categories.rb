class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string  :title
      t.text    :description
      t.string  :typ, index: true
      t.boolean :sub, default: false, index: true
      t.timestamps
    end
    if table_exists? :album_categories
      drop_table :album_categories
    end
    if table_exists? :subcategories
      drop_table :subcategories
    end
    if table_exists? :album_categories_albums
      drop_table :album_categories_albums
    end
    if table_exists? :albums_subcategories
      drop_table :albums_subcategories
    end
  end
end

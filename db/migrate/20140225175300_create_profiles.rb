class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :name
      t.string :program
      t.integer :start_year
      t.integer :user_id

      t.timestamps
    end
  end
end

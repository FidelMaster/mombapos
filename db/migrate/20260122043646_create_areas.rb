class CreateAreas < ActiveRecord::Migration[7.1]
  def change
    create_table :areas do |t|
      t.string :name
      t.boolean :is_active, default: true
      t.string :color

      t.timestamps
    end
  end
end

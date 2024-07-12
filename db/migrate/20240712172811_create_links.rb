class CreateLinks < ActiveRecord::Migration[7.1]
  def change
    create_table :links, id: :uuid do |t|
      t.string :title
      t.string :url
      t.references :trip, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end

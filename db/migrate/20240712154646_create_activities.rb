class CreateActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :activities, id: :uuid do |t|
      t.string :title
      t.datetime :occurs_at
      t.references :trip, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end

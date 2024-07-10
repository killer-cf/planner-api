class CreateTrips < ActiveRecord::Migration[7.1]
  def change
    create_table :trips, id: :uuid do |t|
      t.string :destination
      t.date :starts_at
      t.date :ends_at
      t.boolean :is_confirmed

      t.timestamps
    end
  end
end

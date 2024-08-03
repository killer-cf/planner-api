class RemoveIsConfirmedFromTrip < ActiveRecord::Migration[7.1]
  def change
    remove_column :trips, :is_confirmed, :boolean
  end
end

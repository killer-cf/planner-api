class AddUniqueIndexToParticipants < ActiveRecord::Migration[7.1]
  def change
    add_index :participants, [:trip_id, :email], unique: true
  end
end

class CreateParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :participants, id: :uuid do |t|
      t.string :name
      t.string :email
      t.boolean :is_confirmed, default: false
      t.boolean :is_owner, default: false
      t.references :trip, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end

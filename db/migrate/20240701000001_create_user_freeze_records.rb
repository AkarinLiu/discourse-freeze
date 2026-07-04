# frozen_string_literal: true

class CreateUserFreezeRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :user_freeze_records do |t|
      t.integer :user_id, null: false
      t.integer :frozen_by_id, null: false
      t.string :reason, null: false
      t.datetime :frozen_at, null: false
      t.integer :unfrozen_by_id
      t.datetime :unfrozen_at
      t.timestamps
    end

    add_index :user_freeze_records, :user_id
    add_index :user_freeze_records, :frozen_at
    add_index :user_freeze_records, %i[user_id unfrozen_at], name: "idx_freeze_active"
  end
end

class CreateRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :records do |t|
      t.integer :user_id
      t.date :work_date, null: false
      t.time :punch_in, null: false
      t.time :punch_out
      t.time :break_time
      t.string :address

      t.timestamps
    end
  end
end

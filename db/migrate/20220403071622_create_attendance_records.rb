class CreateAttendanceRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :attendance_records do |t|
      
      t.string :user_line_id
      t.date :work_date, null: false
      t.time :start_time, null: false
      t.string :start_address, null: false
      t.time :finish_time
      t.string :finish_address
      t.time :break_time
      t.timestamps
    end
  end
end

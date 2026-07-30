class DropJobQueueTable < ActiveRecord::Migration[8.1]
  def up
    drop_table :job_queue
  end

  def down
    create_table :job_queue do |t|
      t.string :job_type, null: false
      t.text :args
      t.string :status, null: false, default: "pending"
      t.string :error_message
      t.datetime :scheduled_at

      t.timestamps
    end

    add_index :job_queue, [:status, :job_type, :created_at],
              name: "index_job_queue_on_status_job_type_created_at"
  end
end

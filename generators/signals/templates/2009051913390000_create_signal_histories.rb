class CreateSignalHistories < ActiveRecord::Migration

	def self.up
		create_table :signal_histories, :force => true do |t|
			t.references :signalable, :polymorphic => true, :null_allowed => false
			t.integer :signal_id
			t.integer :user_id
			t.timestamp :end_at , :null_allowed => false
		end

		add_index :signal_histories, [:user_id, :signalable_type, :signalable_id, :signal_id], :uniq => true
		add_index :signal_histories, :end_at
	end

	def self.down
		remove_index :signal_histories, [:user_id, :signalable_type, :signalable_id, :signal_id]
		remove_index :signal_histories, :end_at
		drop_table :signal_histories
	end
end


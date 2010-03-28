class CreateSignals < ActiveRecord::Migration

	def self.up
		create_table :signals, :force => true do |t|
			t.references :signalable, :polymorphic => true, :null_allowed => false
			t.string :crud, :limit => 10, :null_allowed => false
			t.string :qname, :null_allowed => false
			t.boolean :multiple, :default => false, :null_allowed => false
			t.string :params, :default => nil, :null_allowed => true
			t.timestamp :end_at, :null_allowed => false
			t.timestamps
		end

		add_index :signals, [:signalable_type, :signalable_id]
		add_index :signals, :end_at
		add_index :signals, :created_at
		add_index :signals, :qname


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
		
		remove_index :signals, [:signalable_type, :signalable_id]
		remove_index :signals, :end_at
		remove_index :signals, :created_at
		remove_index :signals, :qname
		drop_table :signals
	end

end


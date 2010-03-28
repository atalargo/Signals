class SignalHistory < ActiveRecord::Base
	belongs_to :signalable, :polymorphic => true
	
end


class SignalHistory < ActiveRecord::Base
	belongs_to :signalable, :polymorphic => true


	def self.clean(time =nil)
		time ||= Time.new.to_i
		SignalHistory.delete_all(["end_at < ?", time]) # clean all old and all finded
	end

	def self.find_for(instance, user, time)
		SignalHistory.find(:all, :conditions => ['user_id = ? AND signalable_type = ? AND signalable_id = ? AND end_at > ?', user.id, instance.class.name, instance.id, time], :select => 'id').collect{|sh|sh.signal_id}
	end
end


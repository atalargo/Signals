class SignalEvent
	include Mongoid::Document
	include Mongoid::Timestamps

	field :end_at, :type => Integer
	field :crud #:limit => 10, :null_allowed => false
	field :qname #, :null_allowed => false
	field :multiple, :type => Boolean, :default => false #, :null_allowed => false
	field :params, :default => nil #, :null_allowed => true
	field :signalable_type
	field :signalable_id, :type => Object

	index([:signalable_type, :signalable_id])
	index :end_at

	attr_protected :_id

	store_in :signals

	def self.clean(time = nil, sids = nil)
		time ||= Time.new.to_i
		cond_or = [{:end_at => {'$lt' => time}}]
		cond_or.push({:_id => {'$in' => sids}}) unless sids.nil?

		Mongoid::Persistence::RemoveAll.new(SignalEvent, {}, '$or' => cond_or).persist
	end

	def self.find_for(instance, time, msids)
		if msids.empty?
			SignalEvent.where(:signalable_type => instance.class.name, :signalable_id => instance.id, :end_at.gt => time).ascending(:created_at)
		else
			SignalEvent.where(:signalable_type => instance.class.name, :signalable_id => instance.id, :end_at.gt => time, :_id => {'$nin' => msids}).ascending(:created_at)
		end
	end

	def self.find_for_automerge(signal)
		SignalEvent.where(:signalable_type => signal.signalable_type, :signalable_id => signal.signalable_id, :end_at.lt => signal.end_at, :qname => signal.qname, :crud => signal.crud, :multiple => signal.multiple, :params => signal.params).all
	end

	private
	def delete_now
	#	self.connection.execute("DELETE FROM signals WHERE id =#{self.id};")
# 		self.connection.execute("DELETE FROM signal_histories WHERE signal_id =#{self.id};")
	end
end


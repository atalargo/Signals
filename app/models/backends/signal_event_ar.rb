class SignalEvent < ActiveRecord::Base
	set_table_name 'signals'
	belongs_to :signalable, :polymorphic => true
	serialize :params
# 	@@end_in = 5.minutes

	def self.clean(time = nil, sids = nil)
		time ||= Time.new.to_i
		unless sids.nil?
			sids = ' OR id IN ('+(sids.join(','))+') ' unless sids.empty?
		end
		SignalEvent.delete_all(["end_at < ? #{sids}", t]) # clean all old and all finded
	end

	def self.find_for(instance, time, msids)
		msids = if msids.empty?
				''
			else
				 ' AND id NOT IN ('+msids.join(',')+') '
			end
		SignalEvent.find(:all, {:conditions => ['signalable_type = ? AND signalable_id = ? AND end_at > ? '+msids, instance.class.name, instance.id, time], :sort => 'created_at ASC'})
	end

	def self.find_for_automerge(signal)
		extracond = ( signal.params == nil ? ' params IS NULL ' : ' params = ? ')
		conditions = ['signalable_type = ? AND signalable_id = ? AND end_at < ? AND qname = ? AND crud = ? AND multiple = ? AND '+extracond, signal.signalable_type, signal.signalable_id, signal.end_at, signal.qname, signal.crud, signal.multiple]
		conditions.push s.params unless s.params.nil?

		 SignalEvent.find(:all, :conditions => conditions)
	end

# 	def self.check(instance, current_user = nil)
# 		msids = ''
# 		t = Time.new.utc
# 		unless current_user.nil?
# 			signalhistories = SignalHistory.find(:all, :conditions => ['user_id = ? AND signalable_type = ? AND signalable_id = ? AND end_at > ?', current_user.id, instance.class.name, instance.id, t])
# 			msids = ' AND id NOT IN ('+signalhistories.collect{|sh|sh.signal_id}.join(',')+') ' if signalhistories.size > 0 ##don't take already taked multiple signals
# 		end
#
# 		signals = SignalEvent.find(:all, {:conditions => ['signalable_type = ? AND signalable_id = ? AND end_at > ? '+msids, instance.class.name, instance.id, t]})
# 		sids = signals.collect{|s| (s.multiple ? nil : s.id)}.delete_if{|tid|tid.nil?}.join(',')
# 		sids = ' OR id IN ('+sids+') ' unless sids.empty?
# 		signals.each do |ms|
# 			next if !ms.multiple
# 			begin
# 				sh = SignalHistory.new
# 				sh.signalable = ms.signalable
# 				sh.signal_id = ms.id
# 				sh.user_id = current_user.id
# 				sh.end_at = ms.end_at
# 				sh.save
# 			rescue => e
# 				RAILS_DEFAULT_LOGGER.debug('SignalHistory add error : '+e.message)
# 			end
# 		end
#
#  		SignalEvent.delete_all(["end_at < ? #{sids}", t]) # clean all old and all finded
#  		SignalHistory.delete_all(["end_at < ?", t]) # clean all old and all finded
# #  		SignalHistory.connection.execute("DELETE FROM signal_histories WHERE end_at < '#{t}';") # clean all old histories
# 		signals
# 	end
#
# #	def after_find
#
# #		(self.destroy) if( self.multiple == false || self.end_date < Time.new)
#
# #	end
#
# 	def self.emit(instance, options)
# 		s = SignalEvent.new
# 		options = options ||{}
# 		s.signalable = instance
# 		s.end_at = (options[:end_in] || (Time.new + @@end_in).utc)
# 		s.multiple = options[:multiple] unless options[:multiple].nil?
# 		s.params = options[:params].to_json unless options[:params].nil?
# 		s.crud = (options[:crud].nil? ? 'update' : options[:crud].to_s)
# 		s.qname = options[:qname]
#
# 		extracond = ( s.params == nil ? ' params IS NULL ' : ' params = ? ')
# 		conditions = ['signalable_type = ? AND signalable_id = ? AND end_at < ? AND qname = ? AND crud = ? AND multiple = ? AND '+extracond, instance.class.name, instance.id, Time.new, s.qname, s.crud, s.multiple]
# 		conditions.push s.params unless s.params.nil?
#
# 		sn = SignalEvent.find(:all, :conditions => conditions)#['signalable_type = ? AND signalable_id = ? AND end_at < ? AND qname = ? AND crud = ? AND multiple = ? AND '+extracond, instance.class.name, instance.id, Time.new, s.qname, s.crud, s.multiple, s.params])
# 		if sn.size > 0
# 			# update existants in this case
# 			# push end_at later
# 			sn.first.end_at = s.end_at
# 			sn.first.save
# 		else
# 			s.save
# 		end
#
# 	end
#
# 	def to_struct
# 		{:type => self.qname, :crud => self.crud, :params => ActiveSupport::JSON.decode(self.params)}
# 	end

	private
	def delete_now
		self.connection.execute("DELETE FROM signals WHERE id =#{self.id};")
		self.connection.execute("DELETE FROM signal_histories WHERE signal_id =#{self.id};")
	end
end


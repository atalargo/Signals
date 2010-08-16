case SignalsEvent::backend
when 'ar' then require ::File.expand_path('../backends/signal_event_ar.rb',  __FILE__)
when 'mongoid' then require ::File.expand_path('../backends/signal_event_mongoid.rb',  __FILE__)
end



class SignalEvent

	@@end_in = 5.minutes

	def to_struct
		{:type => self.qname, :crud => self.crud, :params => ActiveSupport::JSON.decode(self.params)}
	end


	def self.check(instance, current_user = nil, session = nil)
		msids = []
		t = Time.new.to_i

		unless current_user.nil?
			shs = SignalHistory.find_for(instance, current_user, t.to_i)
			msids = shs.collect{|sh| sh.signal_id} ##don't take already taked multiple signals
		end
Rails.logger.info("MSIDS #{msids} #{current_user}")
		sigs = SignalEvent.find_for(instance, t.to_i, msids)
		signals = []
		sids = sigs.collect{|s| signals.push(s); (s.multiple ? nil : s.id)}.delete_if{|tid|tid.nil?}

		unless current_user.nil?
Rails.logger.info("MSIDS #{signals}")
			signals.each do |ms|
Rails.logger.info("MSIDS #{ms} #{ms.multiple}")
				next if !(ms.multiple)
				begin
					sh = SignalHistory.new
					sh.signalable_type = ms.signalable_type
					sh.signalable_id = ms.signalable_id
					sh.signal_id = ms._id
					sh.user_id = current_user.id
					sh.end_at = ms.end_at
					sh.save
				rescue => e
	 				Rails.logger.info('SignalHistory add error : '+e.message)
				end
			end
		end

		SignalEvent.clean(t.to_i, sids)
		SignalHistory.clean(t.to_i)

 		unless session.nil? || session['signals_cur'].nil?
			## recup signals saved in session in place of db because receiver was only the current user
			session['signals_cur'].each{|si| signals.push(si)}
			session.delete('signals_cur')
 		end

		signals
	end

	def self.emit(instance, options, current_user = nil, session = nil)

		end_in = if SignalsEvent::default_end_in.nil?
				@@end_in
			 else
				SignalsEvent::default_end_in
			end
		s = SignalEvent.new
		options = options ||{}
		s.signalable_type = instance.class.name
		s.signalable_id = instance.id
		s.end_at = (options[:end_in] || (Time.new + end_in)).to_i
		s.multiple = options[:multiple] unless options[:multiple].nil?
		s.params = options[:params].to_json unless options[:params].nil?
		s.crud = (options[:crud].nil? ? 'update' : options[:crud].to_s)
		s.qname = options[:qname]


		if (SignalsEvent.automerge && (options[:automerge].nil? || options[:automerge] == true)) || (!SignalsEvent.automerge && (!options[:automerge].nil? || options[:automerge] == true))
			#sn = SignalEvent.criteria.where(:signalable_type => instance.class.name, :signalable_id => instance.id, :end_at.lt => s.end_at, :qname => s.qname, :crud => s.crud, :multiple => s.multiple, :params => s.params).all
			sn = SignalEvent.find_for_automerge(s)
			Rails.logger.info(sn)
			Rails.logger.info(sn.count)
			if sn.count > 0
				# update existants in this case
				# push end_at later
				sa = sn.first
				sa.end_at = s.end_at
				sa.save
				return
			end
		end

		s.save unless self.store_in_session?(instance, current_user, s, session)
	end

	protected
	def self.store_in_session?(instance, current_user, signal, session)
		unless current_user.nil? || signal.multiple || session.nil?
			if current_user == instance
				## current_user is the unique receiver of the signal, don't save in db and put it in current session to be send at the end of the current query
				session['signals_cur'] = [] if session['signals_cur'].nil?
				session['signals_cur'].push(signal)
				return true
			end
		end
		false
	end

end
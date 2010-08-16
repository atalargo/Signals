module SignalsLib


	def SignalsLib.checkGroupSignals(user, session = nil)
		unless !user.has_attribute? :roles
			g = user.roles[0]
			if g.nil?
				[]
			else
				SignalEvent.check(g, user, session)
			end
		else
			[]
		end
	end
end


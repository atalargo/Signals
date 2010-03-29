module SignalsLib

	def self.checkGroupSignals(user)
		unless !user.has_attribute? :roles
			g = user.roles[0]
			if g.nil?
				[]
			else
				SignalEvent.check(g, user)
			end
		else
			[]
		end
	end
end


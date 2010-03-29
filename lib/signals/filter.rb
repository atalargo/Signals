module SignalsEvent
	class Filter
		class << self

			# Method that calls SignalsEvent to attach contents
			#
			def after(controller)
				if controller.request.xhr?
					#integrate base check
					sigs = {:u => []}
					begin
						unless controller.current_user.nil?
							begin
								SignalEvent.check(controller.current_user).each do |signal|
									sigs[:u].push signal.to_struct
								end
							rescue => e
								RAILS_DEFAULT_LOGGER.error('Plugin Signals Error: ' + e.message)
								sigs[:e] = ['error '+e.message]
							end

							SignalsLib.singleton_methods.each do |meth|
								begin
									SignalsLib.send(meth, controller.current_user).each do |signal|
										sigs[:u].push signal.to_struct
									end
								rescue => e
										RAILS_DEFAULT_LOGGER.error('Plugin Signals Error SignalsLib : ' + e.message)
										sigs[:e] = ['error '+e.message]
								end
							end
						end
					rescue => e
						RAILS_DEFAULT_LOGGER.error('Plugin Signals Error: ' + e.message)
						sigs[:e] = ['error '+e.message]
					end

					sigs[:t] = Time.new.utc.to_i


					case controller.response.headers['Content-Type'].to_s
					when /javascript/
						controller.response.body.insert(controller.response.body.size, js_signals(sigs))
					when /html/
						controller.response.body.insert(controller.response.body.size, '<script type="text/javascript>'+js_signals(sigs)+'</script>')
					when /json/
						json = ActiveSupport::JSON.decode(controller.response.body)
						json[:signals] = sigs
						controller.response.body = ActiveSupport::JSON.encode(json)
					end

				end
			end

			def js_signals(sigs)
				"Signals.signals(#{{:signals => sigs}.to_json});"
			end
		end
	end
end
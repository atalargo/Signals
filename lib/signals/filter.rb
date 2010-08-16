module SignalsEvent
	class Filter
		class << self

			# Method that calls SignalsEvent to attach contents
			#
			def after(controller)
					#integrate base check
					sigs = {:u => []}
					begin
						unless controller.current_user.nil?
							begin
								SignalEvent.check(controller.current_user, controller.current_user, controller.session).each do |signal|
									sigs[:u].push signal.to_struct
								end
							rescue => e
								(RAILS_DEFAULT_LOGGER.nil? ? Rails.logger : RAILS_DEFAULT_LOGGER).error('Plugin Signals Error: ' + e.message)
								sigs[:e] = ['error '+e.message]
							end

							SignalsLib.singleton_methods.each do |meth|
								begin
									SignalsLib.send(meth, controller.current_user, controller.session).each do |signal|
										sigs[:u].push signal.to_struct
									end
								rescue => e
										(RAILS_DEFAULT_LOGGER.nil? ? Rails.logger : RAILS_DEFAULT_LOGGER).error('Plugin Signals Error SignalsLib : ' + e.message)
										sigs[:e] = ['error '+e.message]
								end
							end
						end
					rescue => e
						(RAILS_DEFAULT_LOGGER.nil? ? Rails.logger : RAILS_DEFAULT_LOGGER).error('Plugin Signals Error: ' + e.message)
						sigs[:e] = ['error '+e.message]
					end

					sigs[:t] = Time.new.utc.to_i
begin
					Rails.logger.info("GET Sig 2 #{controller.response.content_type.to_s}")
					case controller.response.content_type.to_s
					when /javascript/
					Rails.logger.info("JS")
						controller.response.body += js_signals(sigs)
					when /html/
						controller.response.body = controller.response.body.gsub(/<\/body>.*<\/html>$/m,('<script type="text/javascript">Event.observe(window, "load", function() {'+js_signals(sigs)+'});</script></body></html>'))
					when /json/
					Rails.logger.info("JSON")
						json = ActiveSupport::JSON.decode(controller.response.body)
						json[:signals] = sigs
					Rails.logger.info(json)
						controller.response.body = ActiveSupport::JSON.encode(json)
					end
rescue => e
	Rails.logger.info("ERRR #{e.message}")
end
			end

			def js_signals(sigs)
				"Signals.signals(#{sigs.to_json});"
			end
		end
	end
end
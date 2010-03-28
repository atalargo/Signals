class SignalsController < ApplicationController


	def check
		#integrate base check
		sigs = {:u => []}
		begin
			unless current_user.nil?
				begin
					SignalEvent.check(current_user).each do |signal|
						sigs[:u].push signal.to_struct
					end
				rescue => e
					RAILS_DEFAULT_LOGGER.debug('Plugin Signals Error: ' + e.message)
					sigs[:e] = ['error '+e.message]
				end

				SignalsLib.singleton_methods.each do |meth|
					begin
						SignalsLib.send(meth, current_user).each do |signal|
							sigs[:u].push signal.to_struct
						end
					rescue => e
							RAILS_DEFAULT_LOGGER.debug('Plugin Signals Error SignalsLib : ' + e.message)
							sigs[:e] = ['error '+e.message]
					end
				end
			end
		rescue => e
		end

		sigs[:t] = Time.new.utc.to_i
		render :json => {:signals => sigs}.to_json
	end


end


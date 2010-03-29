# Signals
require 'signals/helpers'
require 'signals/filter'

module SignalsEvent

	module Manager
		def self.clean
			begin
				SignalEvent.connection.execute('DELETE FROM '+SignalEvent.table_name+" WHERE end_at < '#{Time.new.utc}';")
				SignalHistory.connection.execute('DELETE FROM '+SignalHistory.table_name+" WHERE end_at < '#{Time.new.utc}';")
			rescue => e
				RAILS_DEFAULT_LOGGER.info('SignalsEvent Manager Clean Error : '+e.message)
				return e
			end
			true
		end
	end
	module ControllerExtensions
		protected
		def emit_signal(instance, options)
			begin
				SignalEvent.emit(instance, options)
			rescue => e
				RAILS_DEFAULT_LOGGER.debug("Emit Signal Error: "+e)
			end
		end
	end

	module Routing
                module MapperExtensions
			def signals
				connect '/signal/check', :controller => 'signals', :action => 'check'
			end
		end
	end

end
ActionController::Routing::RouteSet::Mapper.send(:include, SignalsEvent::Routing::MapperExtensions)
ApplicationController.send(:include, SignalsEvent::ControllerExtensions)

class ActionController::Base
    after_filter SignalsEvent::Filter
end
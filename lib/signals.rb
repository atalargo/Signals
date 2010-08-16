# Signals
require 'signals/helpers'
require 'signals/filter'

module SignalsEvent

	def SignalsEvent.backend=(r)
		@@backend = r
	end

	def SignalsEvent.backend
		@@backend
	end

	def SignalsEvent.default_end_in=(defend)
		@@default_end_in = defend
	end
	def SignalsEvent.default_end_in
		@@default_end_in ||= nil
	end

	def SignalsEvent.automerge
		@automerge ||= false
	end

	def SignalsEvent.automerge=(automerge)
		@automerge = automerge
	end


	module Manager
		def self.clean
			begin
				case SignalsEvent.backend
				when 'ar'
					SignalEvent.connection.execute('DELETE FROM '+SignalEvent.table_name+" WHERE end_at < '#{Time.new}';")
					SignalHistory.connection.execute('DELETE FROM '+SignalHistory.table_name+" WHERE end_at < '#{Time.new}';")
				when 'mongoid'
					Mongoid::Persistence::RemoveAll.new(SignalEvent, {}, {:end_at => {'$lt' => Time.new}}).persist
					Mongoid::Persistence::RemoveAll.new(SignalHistory, {}, {:end_at => {'$lt' => Time.new}}).persist
				end
			rescue => e
				(RAILS_DEFAULT_LOGGER.nil? ? Rails.logger : RAILS_DEFAULT_LOGGER).debug('SignalsEvent Manager Clean Error : '+e.message)
				return e
			end
			true
		end
	end
	module ControllerExtensions
		protected
		def emit_signal(instance, options)
			begin
				SignalEvent.emit(instance, options, self.current_user, self.session)
			rescue => e
				(RAILS_DEFAULT_LOGGER.nil? ? Rails.logger : RAILS_DEFAULT_LOGGER).debug("Emit Signal Error: "+e)
			end
		end
	end

end


Rails.application.routes.draw do |map|
   map.connect '/signal/check', :controller => 'signals', :action => 'check'
end
#ActionController::Routing::RouteSet::Mapper.send(:include, SignalsEvent::Routing::MapperExtensions)
ActionController::Base.send(:include, SignalsEvent::ControllerExtensions)

class ::ActionController::Base
    after_filter SignalsEvent::Filter
end

## Assets installer
dest = "#{( RAILS_ROOT.nil? ? Rails.root : RAILS_ROOT )}/public/javascripts/signals.js"
`ln -sf #{File.dirname(File.dirname(__FILE__))}/assets/javascripts/signals.js  #{dest}` unless File.exist?(dest)

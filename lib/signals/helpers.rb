
module SignalsLib
	module Helpers
		extend ActiveSupport::Concern

		module ClassMethods
		end
		module InstanceMethods
			def activeSignalsJavascript(options = nil)
				options = options || {}
				javascript_include_tag('signals', :plugin => 'signals')+
					javascript_tag('Event.observe(window, \'load\', function(e){Signals.init(\''+request.host_with_port+'\', {'+options.collect {|key, value| "#{key.to_s}: #{value}"}.join(', ')+'});});')
			end
		end
	end
end

ActionView::Base.send(:include, SignalsLib::Helpers)

module ActionView::Helpers
	module AssetTagHelper
		def activeSignalsJavascript(options = nil)
			options = options || {}
			javascript_include_tag('signals', :plugin => 'signals')+
				'<script type="text/javascript">Event.observe(window, \'load\', function(e){Signals.init(\''+url_for(:root)+'\', {'+options.collect {|key, value| "#{key.to_s}: #{value}"}.join(', ')+'});});</script>'
		end
	end
end


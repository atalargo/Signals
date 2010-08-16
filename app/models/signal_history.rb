case SignalsEvent::backend
when 'ar' then require ::File.expand_path('../backends/signal_history_ar.rb',  __FILE__)
when 'mongoid' then require ::File.expand_path('../backends/signal_history_mongoid.rb',  __FILE__)
end

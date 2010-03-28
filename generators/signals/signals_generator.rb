class SignalsGenerator < Rails::Generator::Base
	def manifest
		@migration_name = "Create SignalsMigrations"
		@migration_action = "add"
		record do |m|
			m.migration_template '2009051821120000_create_signals.rb',"db/migrate", :migration_file_name => "create_signals"
		end
	end
end


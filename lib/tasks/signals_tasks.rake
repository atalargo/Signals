# desc "Explaining what the task does"
# task :signals do
#   # Task goes here
# end
namespace :signals do
  desc "Clean old Signals in db"
  task :clean  => :environment do
        print "Clean old signals in db..."
	r = SignalsEvent::Manager.clean
	if r
		print " Ok\n"
	else
		print "Error occurs : "+r.message
	end
  end
end

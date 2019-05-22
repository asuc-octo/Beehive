require 'date'

FactoryBot.define do
	factory :job do
		title { "beehive" }
		project_type { 1 }
		department_id { 1 }
		desc { "make website" }
		earliest_start_date { DateTime.new(2000,1,1) }
		latest_start_date { DateTime.new(3000,1,1) }
		end_date { DateTime.new(4000,1,1) }
	end

	factory :latest_lessthan_earliest, parent: :job do
		earliest_start_date { DateTime.new(2000,1,1) }
		latest_start_date { DateTime.new(1900,1,1) }
	end

	factory :end_lessthan_latest, parent: :job do
		latest_start_date { DateTime.new(2000,1,1) }
		end_date { DateTime.new(1900,1,1) }
	end

end

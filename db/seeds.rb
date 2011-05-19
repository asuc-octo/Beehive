***REMOVED*** This file should contain all the record creation needed to seed the database with its default values.
***REMOVED*** The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
***REMOVED***
***REMOVED*** Examples:
***REMOVED***
***REMOVED***   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
***REMOVED***   Mayor.create(:name => 'Daley', :city => cities.first)

***REMOVED*** Create departments
[ ['Elec Eng & Comp Sci', 'EECS'] ].each do |name, abbrev|
  ***REMOVED***Department.find_or_create_by_name_and_abbrev(name, abbrev)   ***REMOVED*** TODO: add abbrev
  Department.find_or_create_by_name abbrev
end

***REMOVED***   Development-specific seeds
if Rails.env == 'development' then
  [ ['Test Faculty', 'test@faculty.com']
  ].each do |name, email|
    f = Faculty.find_or_initialize_by_name_and_email(name, email)
    ***REMOVED***f.department_id = Department.first  ***REMOVED*** TODO
    f.save
  end
end


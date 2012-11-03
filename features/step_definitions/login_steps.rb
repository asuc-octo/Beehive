Given /^I am logged in as "(.*)"$/ do |user|
  CASClient::Frameworks::Rails::Filter.fake(user)
  visit "/login"
end

When /^I log out$/ do
  begin
    visit "/logout"
  rescue Exception=>e
  end
  visit "/"
end

Then /^I should see "(.)" after "(.)"$/ do |e1, e2|
  ***REMOVED***  ensure that that e1 occurs before e2.
  ***REMOVED***  page.content  is the entire content of the page as a string.
  regexp = /***REMOVED***{e2}.****REMOVED***{e1}/m
  assert_match regexp, page.body
end

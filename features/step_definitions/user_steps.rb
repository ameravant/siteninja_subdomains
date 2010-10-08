require File.dirname(__FILE__) + "/../../spec/factories"

def logout
  visit '/session/new'
end

Given /^I am not logged in$/ do
  logout  
end

Given /^I am logged in as "(.*)" with password "(.*)"$/ do |username, password|
  visit new_session_url
  fill_in "login", :with => username
  fill_in "password", :with => password
  click_button "Sign in"
end

Given /^I am logged in as the owner of "(.*)" with password "(.*)"$/ do |org_name, password|
  visit new_session_url
  fill_in "login", :with => Org.find_by_name(org_name).owner.user.login
  fill_in "password", :with => password
  click_button "Sign in"
end

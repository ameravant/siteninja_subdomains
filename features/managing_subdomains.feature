Feature: adding subdomains
  In order to have microsites
  As an admin 
  I want to create a new subdomain
  
  Scenario: adding a new subdomain
    Given I am logged in as "admin" with password "admin"
    When I go to the new admin accounts page
    Then I should see 'subdomain'
    And I should see 'title'
    When I fill in 'title' with 'My Subdomain'
    And I fill in 'subdomain' with 'mysub'
    And I press 'Create Subdomain'
    Then I should be on the homepage with the subdomain "mysub"
    
  
  
  

  

Feature: Client is referred via another agency
  As a council officer outside Hackney Works
  I want to refer clients to the programme
  So I can help them find a job
  
  Background:
    Given there is a hub covering homerton
    And there is a team leader for homerton
  
  @homerton_postcode
  Scenario: Referral creates a new client
    Given I am on the client referral page
    And I fill in the referral form
    Then a new client should be created in the database

  @homerton_postcode
  Scenario: team leader receives notification
    When I refer a client
    Then the team leader should receive a new client notification
    And the client should be auto assigned to homerton

  @homerton_postcode
  Scenario: client receives email confirmation
    When I refer a client as "client@example.com"
    Then "client@example.com" receive an email asking to confirm address
    
  @outside_hackney_postcode
  Scenario: client outside borough can't be referred
    When I refer a client with a postcode outside the borough
    Then I should be on the outside hackney page

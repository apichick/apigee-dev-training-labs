Feature: Identity API (v1) tests

  Scenario: Generate Access Token (Password Grant) - Success
    Given I have basic authentication credentials `clientId` and `clientSecret`
    And I set form parameters to
      | parameter  | value    |
      | grant_type | password |
      | username   | user     |
      | password   | valid    |
    When I POST to /token
    Then response code should be 200
    And response body should be valid json
    And response body path $.token_type should be bearer
    And response body path $.access_token should be (.+)
    And response body path $.refresh_token should be (.+)
    And response body path $.issued_at should be (\d+)
    And response body path $.expires_in should be (\d+)
    And response body path $.refresh_token_expires_in should be (\d+)

  Scenario: Generate Access Token (Client Credentials Grant) - Success
    Given I have basic authentication credentials `clientId` and `clientSecret`
    And I set form parameters to
      | parameter  | value              |
      | grant_type | client_credentials |
    When I POST to /token
    Then response code should be 200
    And response body should be valid json
    And response body path $.token_type should be bearer
    And response body path $.access_token should be (.+)
    And response body path $.issued_at should be (\d+)
    And response body path $.expires_in should be (\d+)
    And response body path $.refresh_token_expires_in should be (\d+)

  Scenario: Generate Access Token (Password Grant) - Missing Authorization header
    Given I set form parameters to
      | parameter  | value    |
      | grant_type | password |
      | username   | user     |
      | password   | valid    |
    When I POST to /token
    Then response code should be 400
    And response body should be valid json
    And response body path $.code should be 400.01.001
    And response body path $.message should be Invalid client
    And response body path $.info should be (.+)

  Scenario: Generate Access Token (Client Credentials Grant) - Missing Authorization header
    Given I set form parameters to
      | parameter  | value              |
      | grant_type | client_credentials |
    When I POST to /token
    Then response code should be 400
    And response body should be valid json
    And response body path $.code should be 400.01.001
    And response body path $.message should be Invalid client
    And response body path $.info should be (.+)

  Scenario: Generate Access Token (Password Grant) - Invalid client id
    Given I have basic authentication credentials invalid and `clientSecret`
    And I set form parameters to
      | parameter  | value    |
      | grant_type | password |
      | username   | user     |
      | password   | valid    |
    When I POST to /token
    Then response code should be 400
    And response body should be valid json
    And response body path $.code should be 400.01.001
    And response body path $.message should be Invalid client
    And response body path $.info should be (.+)

  Scenario: Generate Access Token (ClientCredentials Grant) - Invalid client id
    Given I have basic authentication credentials invalid and `clientSecret`
    And I set form parameters to
      | parameter  | value              |
      | grant_type | client_credentials |
    When I POST to /token
    Then response code should be 400
    And response body should be valid json
    And response body path $.code should be 400.01.001
    And response body path $.message should be Invalid client
    And response body path $.info should be (.+)

  Scenario: Generate Access Token (Password Grant) - Invalid client secret
    Given I have basic authentication credentials `clientId` and invalid
    And I set form parameters to
      | parameter  | value    |
      | grant_type | password |
      | username   | user     |
      | password   | valid    |
    When I POST to /token
    Then response code should be 400
    And response body should be valid json
    And response body path $.code should be 400.01.001
    And response body path $.message should be Invalid client
    And response body path $.info should be (.+)

  Scenario: Generate Access Token (Client Credentials Grant) - Invalid client secret
    Given I have basic authentication credentials `clientId` and invalid
    And I set form parameters to
      | parameter  | value              |
      | grant_type | client_credentials |
    When I POST to /token
    Then response code should be 400
    And response body should be valid json
    And response body path $.code should be 400.01.001
    And response body path $.message should be Invalid client
    And response body path $.info should be (.+)

  Scenario: Generate Access Token (Password Grant) Invalid client id and client secret
    Given I have basic authentication credentials invalid and invalid
    And I set form parameters to
      | parameter  | value    |
      | grant_type | password |
      | username   | user     |
      | password   | valid    |
    When I POST to /token
    Then response code should be 400
    And response body should be valid json
    And response body path $.code should be 400.01.001
    And response body path $.message should be Invalid client
    And response body path $.info should be (.+)

  Scenario: Generate Access Token (Client Credentials Grant) Invalid client id and client secret
    Given I have basic authentication credentials invalid and invalid
    And I set form parameters to
      | parameter  | value              |
      | grant_type | client_credentials |
    When I POST to /token
    Then response code should be 400
    And response body should be valid json
    And response body path $.code should be 400.01.001
    And response body path $.message should be Invalid client
    And response body path $.info should be (.+)

  Scenario: Generate Access Token (Password Grant) - Invalid end user credentials
    Given I have basic authentication credentials `clientId` and `clientSecret`
    And I set form parameters to
      | parameter  | value    |
      | grant_type | password |
      | username   | user     |
      | password   | invalid  |
    When I POST to /token
    Then response code should be 400
    And response body should be valid json
    And response body path $.code should be 400.01.002
    And response body path $.message should be Invalid user
    And response body path $.info should be (.+)

  Scenario: Refresh Token - Success
    Given I have a valid access token and refresh token for app credentials `clientId` and `clientSecret` and user credentials user and valid
    When I try to refresh the access token
    Then response code should be 200
    And response body should be valid json
    And response body path $.token_type should be bearer
    And response body path $.access_token should be (.+)
    And response body path $.refresh_token should be (.+)
    And response body path $.issued_at should be (\d+)
    And response body path $.expires_in should be (\d+)

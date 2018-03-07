Feature: Mock API tests

	Scenario: Success
		Given I set form parameters to
      		| parameter | value   |
      		| username  | user    |
      		| password  | valid   |
		When I POST to /authenticate
    	Then response code should be 200
		And response body should be valid json
		And response body path $.id should be (.+)
		And response body path $.firstName should be (.+)
		And response body path $.lastName should be (.+)
		And response body path $.email should be (.+)

	Scenario: Invalid credentials
		Given I set form parameters to
      		| parameter | value   |
      		| username  | user    |
      		| password  | invalid |
		When I POST to /authenticate
    	Then response code should be 401
		And response body should be valid json
		And response body path $.code should be unauthorized
		And response body path $.message should be User credentials are invalid

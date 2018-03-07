Feature: Book API (V1) Tests

    Scenario: Get Books - Success

        When I GET /books?apikey=`apikey`
        Then response code should be 200
        And response body should be valid json
        And response body path $.[0].id should be (.+)

    Scenario: Get Books - Unauthorized

        When I GET /books
        Then response code should be 401

    Scenario: Search Books - Success

        When I GET /books/search?apikey=`apikey`&q=War
        Then response code should be 200
        And response body should be valid json
        And response body path $.[0].title should be ^(.*[wW][Aa][rR].*)$

    Scenario: Search Books - Unauthorized

        When I GET /books/search?q=War
        Then response code should be 401

    Scenario: Search Books - Missing Search Term

        When I GET /books/search?apikey=`apikey`
        Then response code should be 400

    Scenario: Get Book By Id - Success

        When I GET /books/121b4bb3-c971-4080-b230-571148b71969?apikey=`apikey`
        Then response code should be 200
        And response body should be valid json
        And response body path $.id should be 121b4bb3-c971-4080-b230-571148b71969

    Scenario: Get Book By Id - Unauthorized

        When I GET /books/121b4bb3-c971-4080-b230-571148b71969
        Then response code should be 401

    Scenario: Get Book By Id - Not Found

        When I GET /books/invalid?apikey=`apikey`
        Then response code should be 404

    Scenario: Resource Not Found

        When I GET /other?apikey=`apikey`
        Then response code should be 404

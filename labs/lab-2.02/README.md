# Lab 2.01 - Mocking with Node.js

## Introduction

The objective of this lab is to learn how to create a mock using apimocker Node.js package. We will be creating a mock of a user authentication service, that we using during Day 3 lab sessions.

## Instructions

1. Create a directory called mock-api and open your preferred editor (Atom, Visual Studio,...) in it.

2. Add the files gulpfile.js and package.json from the solution inside the mock-api folder. 

3. Create the following structure inside the mock-api directory:

        mock-api
        |-- apiproxy
        |   |-- proxies
        |   |-- targets
        |   |-- resources
        |       |-- node
        |-- test
            |-- integration
                |-- features
                    |-- step_definitions


4. Create the feature file mock-api.feature inside mock-api/test/integration/features with the following content:

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

5. Create a file named init.js inside mock-api/test/integration/features/step_definitions directory with the following contents:

        /*jshint esversion: 6 */
        const _ = require('lodash');
        const apickli = require('apickli');
        const {
            defineSupportCode
        } = require('cucumber');

        defineSupportCode(function ({
            Before
        }) {
            Before(function () {
                this.apickli = new apickli.Apickli(this.parameters.scheme, this.parameters.domain);
                _.extend(this.apickli.scenarioVariables, this.parameters);
            });
        });

6. Create a file called settings.json inside mock-api/test/integration directory with the contents provided below:

        {
            "default": {
                "scheme": "https"
            }, 
            "ORGANIZATION":
                "ENVIRONMENT": {
                    "domain": "ORGANIZATION-TEST.apigee.net/mock"
                }
        }

7. Create the API proxy descriptor mock-api.xml inside mock-api/apiproxy directory with the following content:

        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <APIProxy name="mock-api">
            <Description>Mock API</Description>
        </APIProxy>

8. Create the ProxyEndpoint descriptor default.xml inside mock-api/apiproxy/proxies directory with the content below:

        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <ProxyEndpoint name="default">
            <HTTPProxyConnection>
                <BasePath>/mock</BasePath>
                <VirtualHost>secure</VirtualHost>
            </HTTPProxyConnection>
            <RouteRule name="default">
                <TargetEndpoint>default</TargetEndpoint>
            </RouteRule>
        </ProxyEndpoint>

9. Create the descriptor default.xml for the TargetEndpoint that we were referencing in the ProxyEndpoint descriptor. In our case the TargetEndpoint will be a Node.js application. Add an XML file with the following contents to the apiproxy/targets directory.

        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <TargetEndpoint name="default">
            <ScriptTarget>
                <ResourceURL>node://app.js</ResourceURL>
            </ScriptTarget>
        </TargetEndpoint>

10. The next step will be to initialize our Node.js app inside mock-api/apiproxy/resources/node directory and install the required node dependencies.

        $ npm init
        $ npm install --save apimocker@0.5.1

11. Create the Node.js app entry point, a file named app.js, inside mock-api/apiproxy/resources/node directory with the content below:

        var ApiMocker = require('apimocker');
        
        var options = {};
        
        var apiMocker = ApiMocker.createServer(options)
            .setConfigFile('config.json')
            .start();

12. Create a file named config.json inside the apiproxy/resources/node directory. This file is where we are going to configure the responses that our mock is going to send back to the invoking client. See below the content of the file:

        {
            "mockDirectory": "./mock",
            "quiet": false,
            "port": "8080",
            "latency": 50,
            "logRequestHeaders": false,
            "webServices": {
                "authenticate": {
                    "latency": 20,
                    "verbs": ["post"],
                    "switch": ["password"],
                    "responses": {
                        "post": {"httpStatus": 401, "mockFile": "error.json"}
                    },
                    "switchResponses": {
                        "passwordvalid": {"httpStatus": 200, "mockFile": "success.json"}
                    }
                }
            }
        }

13. Create the error and success mock responses inside mock-api/apiproxy/resources/node/mock:

    * mock-api/apiproxy/resources/node/mock/success.json

            {
                "id": "9532e495-bf0a-4554-b813-4cfc54e67976",
                "firstName": "John",
                "lastName": "Doe",
                "email": "john.doe@acme.com"
            }

    * mock-api/apiproxy/resources/node/mock/error.json

            {
                "code": "unauthorized",
                "message": "User credentials are invalid"
            }

13. Make sure that you have installed the dependencies for the gulp script

        $ npm install

14. Deploy and test using gulp.

        $ gulp deploy-and-test -o ORGANIZATION -e environment -s --verbose
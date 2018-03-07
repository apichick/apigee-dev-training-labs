# Lab 1.02 - Advanced API Proxy Development, Deployment and Testing

## Introduction

The objectives of this lab are listed below:

* Get yourself used to developing without using the Management UI wizards.
* Automate the deployment of the API proxy created in Lab 101. 
* Automate the setup of organization and environment configurations. 
* Write BDD tests using cucumber.js and apickli.

## Pre-requisites

The following software needs to be installed in your machine:

* Node.js (Preferably, the latest stable version)
* IDE (Visual Studio, Atom, ...) + Extensions / Packages

## Setting Up the API Proxy Directory Structure

1. Create a directory named book-api-v1.

2. Download the API proxy bundle for the proxy created in Lab 1.01 and place it in the directory that was created in the previous step.

3. Unzip the API proxy bundle inside the book-api-v1 directory and remove the archive. You should see a directory structure like the one shown below:

        +-- book-api-v1
            |-- apiproxy
                |-- policies
                |   |-- *.xml
                |-- proxies
                |   |-- default.xml
                |-- resources
                    |-- jsc
                    |-- *.js
                |-- targets
                |   |-- default.xml
            |-- book-api-v1.xml

NOTE: In order to save some time, we have not created the directory structure ourselves. In general, you will have to create this yourself, either manually or using a generator (yeoman, plop, slush, ...) and add the required policies, resources,... as you proceed with the implementation.

## Setting Up the Environment and Organization Configurations

1. Create a file named env-config.json with the **Environment** configuration.

        {
            "caches": [
                {
                    "name": "book-api-v1-response-cache",
                    "description": "Response cache for the Book API (v1)"
                }
            ],
            "keyvaluemaps": [
                {
                    "name": "book-api-v1-configuration",
                    "entry": [
                        {
                            "name": "cacheEntryExpiry",
                            "value": "3600"
                        }
                    ]
                }
            ],
            "targetservers": [{
                "name": "library-api-v1",
                "host": "apigee-dev-training.appspot.com",
                "isEnabled": true,
                "port": 443,
                "sSLInfo": {
                    "clientAuthEnabled": "false",
                    "enabled": "true",
                    "ignoreValidationErrors": "false"
                }
            }]
        }    

2. Create a file named publish-config.json for the Publish configuration

        {
            "apiproducts": [
                {
                    "name": "BookAPIProduct",
                    "displayName": "BookAPIProduct",
                    "description": "Book API Product",
                    "approvalType": "auto",
                    "environments": [
                        "test"
                    ],
                    "proxies": [
                        "book-api-v1"
                    ]
                }
            ],
            "developers": [
                {
                    "email": "john.doe@acme.com",
                    "firstName": "John",
                    "lastName": "Doe",
                    "userName": "john.doe"
                }
            ],
            "apps": [
                {
                    "apiProducts": [
                        "BookAPIProduct"
                    ],
                    "callbackUrl": "http://callback",
                    "name": "BookApp",
                    "scopes": [],
                    "developerEmail": "john.doe@acme.com"
                }   
            ]
        }

## Setting Up BDD Testing

1. Create the following folder structure for your tests

        +-- book-api-v1
            |-- test
                |-- integration
                    |-- features
                        |-- step_definitions 

2. Create a file name book-api-v1.feature inside the features folder with the following content. We are going to be using step definitions provided by [apickli](https://github.com/apickli/apickli) in our test scenarios. 

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

4. Create a file named init.js inside the step_definitions folder with the following contents:

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

3. Create a configuration file named settings.json inside the book-api-v1 folder with the following contents (set ORGANIZATION and ENVIRONMENT to the ones that you are using)

        {
            "default": {
                "scheme": "https"
            },
            "ORGANIZATION": {
                "ENVIRONMENT": {
                    "domain": "ORGANIZATION-ENVIRONMENT.apigee.net/book/v1",
                    "apikey": "APIKEY"
                }
            }
        }

## Deploying and Testing using Gulp

1. Download the gulpfile.js and package.json files from the solution and place them inside the book-api-v1 folder.

2. Install gulp

        $ npm install -g gulp-cli
        
3. If you want to avoid having to type your credentials in the command line, create a file named _netrc inside %USERPROFILE% if you are a Window user or a file named .netrc inside $HOME if you are a Lunix or Mac OS user. The file should contain the following:

        machine api.enterprise.apigee.com
        login APIGEE_USERNAME
        password APIGEE_PASSWORD

4. Install the required dependencies to run the gulp script:

        $ npm install

5. Import the environment configuration:

        $ gulp import-env-config -o <ORGANIZATION> -e <ENVIRONMENT> -c env-config.json -v

6. Deploy the API proxy:

        $ gulp deploy -o <ORGANIZATION> -e <ENVIRONMENT> -s -v

7. Import the publish configuration:

        $ gulp import-publish-config -o <ORGANIZATION> -c publish-config.json -v

    Copy the consumer key written in the output and replace the APIKEY in the settings.json file with it.

8. Test you API proxy:

        $ gulp test -o <ORGANIZATION> -e <TEST> -s -v

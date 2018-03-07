/*jshint esversion: 6 */
const _ = require('lodash');
const apickli = require('apickli');
const {
    defineSupportCode
} = require('cucumber');

defineSupportCode(function ({
    Before,
    Given,
    When,
    Then
}) {
    Before(function () {
        this.apickli = new apickli.Apickli(this.parameters.scheme, this.parameters.domain);
        _.extend(this.apickli.scenarioVariables, this.parameters);
    });

    Given(/^I have a valid access token and refresh token for app credentials (.*) and (.*) and user credentials (.*) and (.*)$/, function(clientId, clientSecret, username, password, callback) {
        var self = this;
        this.apickli.addHttpBasicAuthorizationHeader(clientId, clientSecret);
        var formParameters = [
            {
                parameter: "grant_type",
                value: "password"
            },
            {
                parameter: "username",
                value: username
            },
            {
                parameter: "password",
                value: password
            }
        ];
        this.apickli.setFormParameters(formParameters);
        this.apickli.post('/token', function(error, response) {
            if (error) {
                callback(new Error(error));
            }
            self.apickli.storeValueInScenarioScope('refreshToken', JSON.parse(response.body).refresh_token);
            callback();
        });
    });

    When(/^I try to refresh the access token$/, function(callback) {
        const scenarioVars = this.apickli.scenarioVariables;
        var formParameters = [
            {
                parameter: "grant_type",
                value: "refresh_token"
            },
            {
                parameter: "refresh_token",
                value: this.apickli.scenarioVariables.refreshToken
            }
        ];
        this.apickli.setFormParameters(formParameters);
        this.apickli.post('/token', function(error, response) {
            if (error) {
                callback(new Error(error));
            }
            callback();
        });
    });

});
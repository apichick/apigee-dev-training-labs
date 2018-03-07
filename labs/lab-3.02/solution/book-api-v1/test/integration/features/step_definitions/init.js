/*jshint esversion: 6 */
const _ = require('lodash');
const apickli = require('apickli');
const {
    defineSupportCode
} = require('cucumber');
const request = require('request-promise');

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

    Given(/^I have a valid access token$/, function (callback) {
        var self = this;
        request.post({
            uri: this.apickli.scenarioVariables.tokenEndpointUrl,
            auth: {
                user: this.apickli.scenarioVariables.clientId,
                pass: this.apickli.scenarioVariables.clientSecret
            },
            form: {
                grant_type: "client_credentials"
            },
            json: true
        }).then(body => {
            this.apickli.addRequestHeader('Authorization', `Bearer ${body.access_token}`);            
            callback();
        }).catch(error => {
            callback(error);
        });
    });

});

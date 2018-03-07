# Lab 4.01 - Edge Microgateway

# Introduction

The main objectives of this lab are:

* Become familiar with Edge Microgateway installation and configuration.
* Implement a custom plugin providing the same functionality as the API proxy developed in Lab 1.01. This time the target backend will be running on the trainee’s machine.

# Instructions

To begin with, go and fetch the sources of the target server app, available in a directory named library-api-v1 at the root of this repository. Then, run the following commands inside the folder containing the sources:

```
$ npm install
$ node app.js
```

Then proceed with the steps listed below to set up and configure Edge Microgateway:

1. Install the latest version of Edge Microgateway with npm as follows:

        $ npm install -g edgemicro

2. Initialize Edge Microgateway using the command below

        $ edgemicro init

    A configuration file called default.yaml should been created inside ~/.edgemicro. Check to make sure that the file exists

3. Configure Edge Microgateway for your organization and environment running the following command:

        $ edgemicro configure -o <organization> -e <environment> -u <apigee-username>

    When running that command you will be prompted for your apigee password.

    Make sure you copy the key and the secret displayed once the command is run, because you will need them later.

    A new configuration file called &lt;org&gt;-&lt;env&gt;-config.yaml should have been created inside the ~/.edgemicro. Double-check that it is available in that location.

    After running this command a new API proxy called edgemicro-auth should have been created in your organization. Verify that it exists.

4. Verify that Edge Microgateway has been correctly set up with the command below:

    $ edgemicro verify -o <organization> -e <environment> -k <key> -s <secret>

5. Create a new API proxy using Edge Management UI in your organization as follows:

    * Proxy type: reverse proxy
    * Name: edgemicro_book-api-v1
    * Base path: /book/v1
    * Target URL: http://localhost:8080/library/v1
    * Security: Pass through (none)

6. Create a new API product including both proxies: edgemicro-auth and edgemicro_book-api-v1.

7. Create a developer.

8. Create a developer app including the API product that was just created.

9. Start edge microgateway. You will need the key and the secret that were written to the standard output before when the edgemicro configure command was created.

        $ edgemicro start -o <organization> -e <environment> -k <key> -s <secret>

    By default the edge microgateway runs on port 8000 and the oauth plugin is enabled. So if you go now and make a request to http://localhost:8000/book/v1/books you should be getting a 401.

10. In order to get an access token, you can do any of the following things:

        $ edgemicro token get -o <organization> -e <environment> -i <dev-app-consumer-key> -s <dev-app-consumer-secret>

    Alternatively you can run the following command

        curl -v -X POST "https://<org>-<env>.apigee.net/edgemicro-auth/token" -d '{ "client_id": "<dev-app-consumer-key>", "client_secret": "<dev-app-consumer-secret>", "grant_type": "client_credentials" }' -H "Content-Type: application/json"

11. Once you have an access token, you can make the request as follows:

        curl -v -H'Authorization: Bearer <token>' http://localhost:8000/book/v1/books.

    This time you should get a 200 OK with an XML payload containing a lit of books.

The next thing for us to do to complete this lab will be to create a plugin that will be transforming the XML response sent back by the target backend into JSON. Please follow the steps included below:

1. Create a folder named plugins somewhere in your local file system and inside that folder another one named book-api-v1 that will contain the code of the plugin.

        $ mkdir -p plugins/book-api-v1

2. Change to the plugin directory and create a new Node.js plugin

        $ npm init

3. Install the required dependencies

        $ npm install --save debug xml2json

4. Create a file named index.js and paste the following contents in it:

        'use strict';
        var debug = require('debug');
        var parser = require('xml2json');

        module.exports.init = function(config, logger, stats) {

        return {

            onend_response: function(req, res, data, next) {
                var baseUrl = res.proxy.parsedUrl.pathname;
                var proxyBasepath = res.proxy.base_path;
                var proxyPathsuffix = req.reqUrl.pathname.replace(proxyBasepath, '');
                var result = '';
                if(proxyBasepath === '/book/v1') {
                    if(new RegExp("/books(\/.+)*").test(proxyPathsuffix)) {
                        result = parser.toJson(data.toString());
                    }
                }
                next(null, result);
            }
        };

5. Add the the following lines in the plugins sections in ~/.edgemicro/&lt;org&gt;-&lt;env&gt;-config.yaml.

        plugins:
            sequence:
            - oauth
            - book-api-v1
            - accumulate-response

    The accumulate-response plugin is available out of the box and it is to used to ensure that we receive the complete response payload in the onend_response handler.

6. Start microgateway supplying the path of the plugins folder as a command line option:

        $ edgemicro start -o <organization> -e <environment> -k <key> -s <secret> -d <plugins-dir>

7. Make a request a check that the payload returned in JSON.

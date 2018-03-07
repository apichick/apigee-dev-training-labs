# Apigee Developer Training

## Labs

### Lab 1.01: Basic API Proxy Development, Deployment and Testing

Objectives:

* Learn how to import an OpenAPI specification into your organization.
* Learn how to create a pass-through API proxy from an existing API specification and deploy it to an environment in your organization.
* Start using the Edge trace tool to debug your API proxy.
* Become familiar with the Edge out-of-the-box policies.
* Learn how to protect your API using an API key.
* Learn how to use a REST client (Postman, curl, httpie) to test your API.

### Lab 1.02: Advanced API Proxy Development, Deployment and Testing

Objectives: 

* Get used to developing without the Management UI wizards.
* Automate the deployment of the API proxy created in Lab 1.01. 
* Automate the setup of organization and environment configurations. 
* Write BDD tests using cucumber.js and apickli.

### Lab 2.01 - Advanced Error Handling

Objectives:

* Implement the required steps in the DefaultFaultRule to build and send custom error responses to the client. 
* Set up the required FaultRules to catch all the error conditions raised by the Apigee policies and populate the runtime variables required to build the error response.
* Learn how to raise your own errors in the API proxy.

### Lab 2.02: Mocking with Node.js

Objectives:

* Learn how to create a mock using apimocker Node.js package. We will be creating a mock of a user authentication service, that we will be using in Lab 3.02.

### Lab 2.03: Custom Analytics

Objectives:

* Learn how to collect custom analytics in the API proxy implemented on the first day of the training.
* Generate custom reports based on the collected statistics.

### Lab 3.01: Traffic Management

Objectives:

* Learn how to do traffic management in API proxies. We will be adding SpikeArrest and Quota to the API proxy created in Lab 2.01.

### Lab 3.02: API Security using OAuthV2	

Objectives:

* Implement an Identity API that will support the client credentials grant, the resource owner credentials grant and the refresh token grant. 
* Learn how to protect the API implemented on the first day of the training using OAuth V2. 
* Write API security BBD tests for the two APIs mentioned above. 



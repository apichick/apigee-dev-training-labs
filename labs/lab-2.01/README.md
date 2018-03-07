# Lab 2.01 - Advanced Error Handling 

## Introduction

The objectives of this lab are listed below:

* Implement the required steps in the API proxy DefaultFaultRule to build the error response and send it back to the client. 
* Set up the required FaultRules to catch all the error conditions raised by the * Apigee policies and populate the runtime variables required to build the error response.
* Learn how to raise your own errors in the API proxy.

We will take as starting point the solution of Lab 1.02.

## Adding a DefaultFaultRule to the API Proxy

* Create a new RaiseFault policy to build the error response sent to the client:

      <RaiseFault name="RaiseFault.JSON">
        <FaultResponse>
          <Set>
            <Headers>
              <Header name="Content-Type">application/json;charset=UTF-8</Header>
            </Headers>
            <Payload contentType="application/json" variablePrefix="@" variableSuffix="#">{"code":"@flow.error.code#","message":"@flow.error.message#","info":"@flow.error.info#"}</Payload>
            <StatusCode>{flow.error.status}</StatusCode>
          </Set>
        </FaultResponse>
        <IgnoreUnresolvedVariables>true</IgnoreUnresolvedVariables>
      </RaiseFault>

As you can see the error response will require certain runtime variables to be populate before it is actually invoked.

* Create a new AssignMessage policy to set some default values for the runtime variables.

      <AssignMessage async="false" continueOnError="false" enabled="true" name="AssignMessage.Error.InternalServerError">
        <AssignVariable>
          <Name>flow.error.message</Name>
          <Value>Proxy internal server error</Value>
        </AssignVariable>
        <AssignVariable>
          <Name>flow.error.code</Name>
          <Value>500.01.001</Value>
        </AssignVariable>
        <AssignVariable>
          <Name>flow.error.status</Name>
          <Value>500</Value>
        </AssignVariable>
        <AssignVariable>
          <Name>flow.error.info</Name>
          <Value>http://documentation</Value>
        </AssignVariable>
      </AssignMessage>

* Add the following DefaultFaultRule in the API ProxyEndpoint and TargetEndpoint:

      <DefaultFaultRule>
          <AlwaysEnforce>true</AlwaysEnforce>
          <Step>
              <Name>AssignMessage.Error.InternalServerError</Name>
              <Condition>flow.error.code = NULL</Condition>
          </Step>
          <Step>
              <Name>RaiseFault.JSON</Name>
          </Step>
      </DefaultFaultRule>

## Catching errors raised by Apigee policies

If we leave things as they are, we will get an 500 Internal Server Error, each time an Apigee policy that has been set with continueOnError=false raises an error. In order to avoid this, we will have to add FaultRules for the different error conditions that might raise. 

In our example, we will have to add a new FaultRule in case the API key supplied in the request is missing or invalid. In this fault rule we will be assigning the values of the variables required to build the error response accordingly. 

* FaultRule

      <FaultRules>
          <FaultRule name="Invalid API Key">
              <Step>
                  <Name>AssignMessage.Error.InvalidApiKey</Name>
              </Step>
              <Condition>fault.name = "InvalidApiKey" OR fault.name = "FailedToResolveAPIKey"</Condition>
          </FaultRule>
      </FaultRules>

  * AssignMessage policy

      <AssignMessage async="false" continueOnError="false" enabled="true" name="AssignMessage.Error.InvalidApiKey">
        <AssignVariable>
          <Name>flow.error.message</Name>
          <Value>Invalid API Key</Value>
        </AssignVariable>
        <AssignVariable>
          <Name>flow.error.code</Name>
          <Value>401.01.001</Value>
        </AssignVariable>
        <AssignVariable>
          <Name>flow.error.status</Name>
          <Value>401</Value>
        </AssignVariable>
        <AssignVariable>
          <Name>flow.error.info</Name>
          <Value>http://documentation</Value>
        </AssignVariable>
      </AssignMessage>

## Raising errors

In this section we will explain how to raise errors ourselves. For instance, let's raise a 400 Bad Request HTTP error in case the search term is metting when searchin for a book. The steps to follow are below:

* Create an AssignMessage policy to set the variables required when building the error response

      <AssignMessage async="false" continueOnError="false" enabled="true" name="AssignMessage.Error.MissingSearchTerm">
        <AssignVariable>
          <Name>flow.error.message</Name>
          <Value>Missing search tearm</Value>
        </AssignVariable>
        <AssignVariable>
          <Name>flow.error.code</Name>
          <Value>400.01.001</Value>
        </AssignVariable>
        <AssignVariable>
          <Name>flow.error.status</Name>
          <Value>400</Value>
        </AssignVariable>
        <AssignVariable>
          <Name>flow.error.info</Name>
          <Value>http://documentation</Value>
        </AssignVariable>
      </AssignMessage>

* Create a new RaiseFault policy that just raises an error

      <RaiseFault name="RaiseFault.GoToFaultRules"/>

* Modify the existing conditional flow for the book search so it looks as follows:

      <Flow name="Search Books">
        <Request>
          <Step>
            <Name>AssignMessage.Error.MissingSearchTerm</Name>
            <Condition>request.queryparam.q = NULL</Condition>
          </Step>
          <Step>
            <Name>RaiseFault.GoToFaultRules</Name>
            <Condition>flow.error.code != NULL</Condition>
          </Step>
        </Request>
        <Condition>request.verb = "GET" AND proxy.pathsuffix MatchesPath "/books/search"</Condition>
      </Flow>

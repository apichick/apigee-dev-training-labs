# Lab 3.01 - Traffic Management

## Introduction

Objectives:

* Learn how to do traffic management in API proxies. We will be SpikeArrest and Quota to the API proxy that we created the first day of the training.

## SpikeArrest

Please follow the steps available below to protect your API proxy against traffic spikes using a SpikeArrest policy:

1. The rate for the SpikeArrest policy will be stored as an entry in the KVM that we have for the API Proxy configurable parameters. Therefore, we will need to add a new entry in config/env/test/kvms.json file, so it looks as follows:

        [
            {
                "name": "book-api-v1-configuration",
                "encrypted": true
                "entry": [
                    {
                        "name": "cacheEntryExpiry",
                        "value": "3600"
                    },
                    {
                        "name": "spikeArrestRate",
                        "value": "2ps"
                    }
                ]
            }
        ]

2. Modify the KeyValueMapOperations policy used to read the API proxy configuration, so the new entry value is read too.

        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <KeyValueMapOperations async="false" continueOnError="false" enabled="true" name="KeyValueMapOperations.ReadConfiguration" mapIdentifier="book${deployment.suffix}-api-v1-configuration">
            <Scope>environment</Scope>
            <ExpiryTimeInSecs>300</ExpiryTimeInSecs>
            <Get assignTo="config.cacheEntryExpiry">
                <Key>
                    <Parameter>cacheEntryExpiry</Parameter>
                </Key>
            </Get>
            <Get assignTo="config.spikeArrestRate">
                <Key>
                    <Parameter>spikeArrestRate</Parameter>
                </Key>
            </Get>
        </KeyValueMapOperations>

3. Create a new SpikeArrest policy using the XML provided below:

        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <SpikeArrest async="false" continueOnError="false" enabled="true" name="SpikeArrest">
            <Rate ref="config.spikeArrestRate">10ps</Rate>
        </SpikeArrest>

4. Add a new step to the <Request> element of the PreFlow in the ProxyEndpoint with the SpikeArrest policy that has just been created in the position indicated below:

        <PreFlow>
            <Request>
                <Step>
                    <Name>KeyValueMapOperations.ReadConfiguration</Name>
                </Step>
                <Step>
                    <Name>SpikeArrest</Name>
                    <Condition>environment.name = "prod"</Condition>
                </Step>
                <Step>
                    <Name>VerifyAPIKey</Name>
                </Step>
                <Step>
                    <Name>ResponseCache</Name>
                </Step>
            </Request>
        </PreFlow>

5. Add the proper error handling for the errors that the SpikeArrest policy might raise. We will need a new AssignMessage policy to assign the values of the variables required to build the error message and a new FaultRule with the suitable condition.

    * AssignMessage policy

            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <AssignMessage async="false" continueOnError="false" enabled="true" name="AssignMessage.Error.SpikeArrestViolation">
            <AssignVariable>
                <Name>flow.error.message</Name>
                <Value>Too Many Requests</Value>
            </AssignVariable>
            <AssignVariable>
                <Name>flow.error.code</Name>
                <Value>429.01.001</Value>
            </AssignVariable>
            <AssignVariable>
                <Name>flow.error.status</Name>
                <Value>429</Value>
            </AssignVariable>
            <AssignVariable>
                <Name>flow.error.info</Name>
                <Value>http://documentation</Value>
            </AssignVariable>
            </AssignMessage>

    * FaultRule

            <FaultRule name="Spike Arrest Violation">
                <Step>
                    <Name>AssignMessage.Error.SpikeArrestViolation</Name>
                </Step>
                <Condition>fault.name = "SpikeArrestViolation"</Condition>
            </FaultRule>


## Quota

See below the steps required to enforce the quota check in the API proxy:

1. Add the quota settings in the API Product configuration file (org/apiProducts.json):

        [
            {
                "name": "BookAPIProduct${deployment.suffix}",
                "displayName": "BookAPIProduct",
                "description": "Book API Product",
                "approvalType": "auto",
                "environments": [
                    "test"
                ],
                "proxies": [
                    "book${deployment.suffix}-api-v1"
                ],
                "quota": "2",
                "quotaInterval": "1",
                "quotaTimeUnit": "minute"
            }
        ]

2. Create a new Quota policy looking as follows:

        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Quota async="false" continueOnError="false" enabled="true" name="Quota">
            <Interval ref="verifyapikey.VerifyAPIKey.apiproduct.developer.quota.interval">1</Interval>
            <TimeUnit ref="verifyapikey.VerifyAPIKey.apiproduct.developer.quota.timeunit">hour</TimeUnit>
            <Allow count="200" countRef="verifyapikey.VerifyAPIKey.apiproduct.developer.quota.limit"/>
        </Quota>

3. Add a new step to the <Request> element of the PreFlow in the ProxyEndpoint with the Quota policy that has just been created in the position indicated below:

        <PreFlow>
            <Request>
                <Step>
                    <Name>KeyValueMapOperations.ReadConfiguration</Name>
                </Step>
                <Step>
                    <Name>SpikeArrest</Name>
                    <Condition>environment.name = "prod"</Condition>
                </Step>
                <Step>
                    <Name>VerifyAPIKey</Name>
                </Step>
                <Step>
                    <Name>Quota</Name>
                    <Condition>environment.name = "prod"</Condition>
                </Step>
                <Step>
                    <Name>ResponseCache</Name>
                </Step>
            </Request>
        </PreFlow>

4. Add the proper error handling for the errors that the SpikeArrest policy might raise. We will need a new AssignMessage policy to assign the values of the variables required to build the error message and a new FaultRule with the suitable condition.

    * AssignMessage policy

            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <AssignMessage async="false" continueOnError="false" enabled="true" name="AssignMessage.Error.QuotaViolation">
            <AssignVariable>
                <Name>flow.error.message</Name>
                <Value>Quota Violation</Value>
            </AssignVariable>
            <AssignVariable>
                <Name>flow.error.code</Name>
                <Value>429.01.002</Value>
            </AssignVariable>
            <AssignVariable>
                <Name>flow.error.status</Name>
                <Value>429</Value>
            </AssignVariable>
            <AssignVariable>
                <Name>flow.error.info</Name>
                <Value>http://documentation</Value>
            </AssignVariable>
            </AssignMessage>

    * FaultRule

            <FaultRule name="Quota Violation">
                <Step>
                    <Name>AssignMessage.Error.QuotaViolation</Name>
                </Step>
                <Condition>fault.name = "QuotaViolation"</Condition>
            </FaultRule>

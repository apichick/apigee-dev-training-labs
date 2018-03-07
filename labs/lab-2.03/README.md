# Lab 2.03 - Custom Analytics

## Introduction

Objectives:

* Learn how to collect custom analytics in the API proxy implemented on the first day of the training.
* Generate custom reports based on the collected statistics.

## Collecting Custom Analytics

Whenever a new book is fetched using our API we would like to collect the book id and the book price so we can work out which the most sold book is and what is the average price that customers pay for a book.

We will take the solution available for lab 3.01 as starting point and follow the steps available below:

1. Create a new Javascript policy that parses the JSON reponse payload and extracts as runtime variables the book id and the bookprice:

    * Policy

            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Javascript async="false" continueOnError="false" enabled="true" timeLimit="200" name="Javascript.ParseBookResponse">
                <ResourceURL>jsc://parseBookResponse.js</ResourceURL>
            </Javascript>

    * Resource

            var payload = JSON.parse(context.getVariable('response.content'));
            context.setVariable('bookId', payload.id);
            context.setVariable('bookTitle', payload.title);
            context.setVariable('bookPrice', parseFloat(payload.price.replace(/[^\d.]/g, '')));

2. Create a new StatisticsCollector policy to collect the book id and book price:

        ?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <StatisticsCollector async="false" continueOnError="false" enabled="true" name="StatisticsCollector.Book">
            <Statistics>
                <Statistic name="bookId" ref="bookId" type="string"/>
                <Statistic name="bookTitle" ref="bookTitle" type="string"/>
                <Statistic name="bookPrice" ref="bookPrice" type="float"/>
            </Statistics>
        </StatisticsCollector>

3. Add these two policies and steps to the &lt;Response&gt; element of the "Get Book by Id" conditional flow.

        <Flow name="Get Book By Id">
            <Response>
                <Step>
                    <Name>Javascript.ParseBookResponse</Name>
                </Step>
                <Step>
                    <Name>StatisticsCollector.Book</Name>
                </Step>
            </Response>
            <Condition>request.verb = "GET" AND proxy.pathsuffix MatchesPath "/books/*"</Condition>
        </Flow>

# cfeoSocial ReadMe

### Overview
cfeoSocial is a set of gateways/test pages to integrate with Social Media APIs (Google,LinkedIn,Facebook).

```
  * Licensed under the Apache License, Version 2.0 (the "License"); you may
  * not use this file except in compliance with the License. You may obtain
  * a copy of the License at
  *
  * http://www.apache.org/licenses/LICENSE-2.0
  *
  * Unless required by applicable law or agreed to in writing, software
  * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
  * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
  * License for the specific language governing permissions and limitations
  * under the License.

```

```
### Using the files

NOTE:  We utilize some CF10 specific code like arrayEach so if you're using an earlier version of CF you may need to refactor to use CFLOOP or other compatible coding.

The goal of the project is to provide a general framework and jumpstart to integrating your application with social media sites using the OAuth2 authentication.  If there turns out to be more interest we'll work on cleaning up the project with more formal documentation and features, otherwise it's just what it is.

##Gateways (CFCs)
Facebook, Google, LinkedIn

Each component has an init() method which takes three parameters (apiKey,apiSecret,redirectURL) which will initialize the component with the basic information required for Authentication.

apiKey|apiSecret = provided by the social media site  

Read Ray Camdens 3 part blog about setting up applications & OAuth to learn more
 - http://www.raymondcamden.com/index.cfm/2013/4/1/ColdFusion-and-OAuth-Part-1--Facebook
 - http://www.raymondcamden.com/index.cfm/2013/4/3/ColdFusion-and-OAuth-Part-2--Facebook
 - http://www.raymondcamden.com/index.cfm/2013/4/17/ColdFusion-and-OAuth-Part-3--Google

 redirectURL = the OAuth.cfm file included in this project (wherever that fits within your website framework)

#Methods

Each method you create is handled within the invokeAPIService switch options and allows you to set simple values as shown;

st.method = "GET|POST|PUT|DELETE|etc.";
st.url="/rest/path/to/method/including/{variables}";
st.customVal=[]; Custom validation rules (e.g. variableName:variableType), checks for existence and validates type
st.customURL=[]; Custom url variables added to method (e.g. urlParameter:parameterValue)

Each gateway includes a few example methods to help understand how things work.

##Testing (CFMs)
Facebook, Google, LinkedIn

These pages provide your basic authentication workflow and test calls of the social media gateways.


```


##License
Copyright (c) 2013

Emerald Oceans Media Group, Inc. (eoMedia Group)

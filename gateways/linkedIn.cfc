/**
  * Copyright 2014 Emerald Oceans Media Group, Inc. (eoMedia Group)
  * Author: Ryan Smith (rsmith@eomedia.com)
  *
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
  *
  * @displayname LinkedIn Gateway
  * @hint A collection of functions to manage LinkedIn
  *
  */
component accessors="true" output="false" {

  // define the properties
  property string apiKey;
  property string apiSecret;
  property string redirectURL;

  // define the default variables for the component
  variables.OAuthBaseURL = 'https://www.linkedin.com/uas/oauth2';
  variables.apiBaseURL = 'https://api.linkedin.com/v1';
  variables.scope = 'r_fullprofile,r_emailaddress,r_network,r_contactinfo,rw_nus,w_messages';
  variables.timeout = 20;
  variables.returnFormat = 'struct';

  /**
  * @description base constructor
  * @hint I instantiated the component
  **/

  public any function init(required string apiKey, required string apiSecret, required string redirectURL) {
    setApiKey(arguments.apiKey);
    setApiSecret(arguments.apiSecret);
    setRedirectURL(arguments.redirectURL);
    return this;
  }


  public any function getOauthURL(required struct argCol) { 

    return '#variables.OAuthBaseURL#/authorization?response_type=code&client_id=#variables.apiKey#&scope=#variables.scope#&state=#urlEncodedFormat(argCol.state)#&redirect_uri=#urlEncodedFormat(variables.redirectURL)#';

  }

  public any function getOauthToken(required string OAuthCode) {

    st = {};
    st.method = 'GET';
    st.url = '/accessToken?grant_type=authorization_code&code=#arguments.OAuthCode#&redirect_uri=#urlEncodedFormat(variables.redirectURL)#&client_id=#variables.apiKey#&client_secret=#variables.apiSecret#';

    var httpService = new http(url=variables.OAuthBaseURL&st.url,method=st.method,timeout=variables.timeout);

    var result = httpService.send().getPrefix();

    return result;
  }


  /**
    * @description API handler
    * @hint I handle requests to the API
    **/

    private any function callAPIservice(required http httpService) {
      
      // get response from the httpService call
      var response = arguments.httpService.send().getPrefix();

      // manage the results from the httpService call
      var result = {};

      if (isJSON(response.fileContent)) {

        // check returnFormat
        if (variables.returnFormat EQ "json") {
          result.response = response.fileContent.toString();  // toString() CF9 required (http://cfmlblog.adamcameron.me/2013/01/weird-behaviour-with-cfhttp-and-json.html)
        } else {
          result.response = deserializeJSON(response.fileContent);  
        }

      } else if (isSimpleValue(response.fileContent) && response.statusCode == "200 OK") {
         result.response = response.fileContent;

      } else if (isBinary(response.fileContent) && response.statusCode == "200 OK") {
         result.response = response.fileContent;

      } else {

        if (variables.returnFormat EQ "json") {
          result.response = serializeJSON(response.responseHeader); 
        } else {
          //throw(message="#response.statusCode#", type="fbHTTP");
          result.response = response.responseHeader;  
        }

      }

      // return the response   
      return result.response;  
     
    } // end callAPIservice



    public any function invokeAPIService(required string service, required string token, required struct args) {

      // create all available services
        switch (arguments.service) {

          case "getMe": 
            st.method = "GET";
            st.url="/people/~:(id,first-name,last-name,industry,headline,location:(name),num-connections,summary,picture-url,email-address,primary-twitter-account)";
            st.customVal=[];
            st.customURL=[];
            break;

          case "getFriend":
            // default start/count params
            param name="args.start" default="1";
            param name="args.count" default="500";
            st.method="GET";
            st.url="/people/~/connections:(id,first-name,last-name,industry,headline,location:(name),num-connections,summary,picture-url)";
            st.customVal=[]; 
            st.customURL=['start:#structKeyExists(args,'start')?args.start:1#','count:#structKeyExists(args,'count')?args.count:500#'];
            break;

          case "createMessage":
            st.method = "POST";
            st.url="/people/~/mailbox";
            st.customVal=[];
            st.customURL=[];
            break;

        } // end switch

/* VALIDATION CHECKS */

      // create structure to hold argument validation checks
      var valArg = {};

      // custom validation (if provided) against required and Datatype
      arrayEach(st.customVal, function(obj) {
        try {
            local.argName = listFirst(obj,":");
            local.argType = listLast(obj, ":");

            // check if required argument exists in passed arguments
            if (structKeyExists(args, local.argName)) {
                 
                // arg exists, validate it's Datatype
                if (local.argType EQ "regex") {
                    // set the appropriate regex expression based on the argumentName
                    switch (local.argName) {
                      // create custom regEx expession for every argument name that uses RegEx to validate
                      case "ipAddress": local.regEx = "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"; break;
                      default: local.regEx = ""; 
                    }
                    // validate using regex
                    isValid("regex", args[local.argName], local.regEx) ? '' : structInsert(valArg, local.argName, "datatype error (#local.argType#)");
                  } else {
                     // validate using argType
                    isValid(local.argType, args[local.argName]) ? '' : structInsert(valArg, local.argName, "datatype error (#local.argType#)");
                  }

              } else {
                // required argument not provided, add to validation structure
                structInsert(valArg, local.argName, "is required (#local.argType#)") ;
            }
        } catch (any e) {
          // error code goes here
        }
      });

  
     // if valiation found issues we want to return them to the caller
     if (!structIsEmpty(valArg)) {

        var response = {
          'status' = 400,
          'statusText' = 'Bad Request',
          'responseText' = valArg
        };

        // check returnFormat and if json serialize the response
        if (variables.returnFormat EQ "json") { response = serializeJSON(response);   }

        return response;
     }


    // if there are no errors create the httpService
    var httpService = new http(url=variables.apiBaseURL&st.url,method=st.method,timeout=variables.timeout,getAsBinary='auto');

    // add access token
    httpService.addParam(type="url",name="oauth2_access_token",value=arguments.token);

    // review and add any custom URL parameters for the service
    if (structKeyExists(st, "customURL")){

      arrayEach(st.customURL, function(obj){
        try {
          local.paramName = listFirst(obj,":");
          local.paramValue = listLast(obj, ":");
          // add custom URL parameters
          httpService.addParam(type="url",name=local.paramName,value=local.paramValue);

          // try to remove the parameter from args (if exists) to clean up the call
          if (structKeyExists(args, local.paramName)) { structDelete(args, local.paramName); }

        } catch (any e) { 
          // error code goes here
        } 
        // end try
      });
    } // end customURL if statement

    /* add header/body variables to service */

      // tell the server that we are sending/receiving json (LinkedIn uses XML by default)
      httpService.addParam(type="header", name="x-li-format", value="json");

      // serialize all arguments into a JSON body parameter (FaceBook does not seem to support)
      httpService.addParam(type="body", value=serializeJSON(args));

    var result = {};
    result = callAPIservice(httpService, args);
    return result;

  } // end invokeAPIService



} // end linkedIn



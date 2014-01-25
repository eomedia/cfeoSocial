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
  * @displayname Google Gateway
  * @hint A collection of functions to manage Google
  *
  */
component accessors="true" output="false" {

  // define the properties
  property string apiKey;
  property string apiSecret;
  property string redirectURL;

  // define the default variables for the component
  variables.OAuthBaseURL = 'https://accounts.google.com/o/oauth2';
  variables.apiBaseURL = 'https://www.googleapis.com';
  variables.apiContactURL = 'https://www.google.com/m8/feeds';
  variables.scope = 'openid profile email https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/calendar https://www.google.com/m8/feeds';
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

    return '#variables.OAuthBaseURL#/auth?client_id=#variables.apiKey#&response_type=code&scope=#variables.scope#&redirect_uri=#urlEncodedFormat(variables.redirectURL)#&state=#urlEncodedFormat(argCol.state)#&access_type=offline';
  }

  public any function getOauthToken(required string OAuthCode) {

    st = {};
    st.method = 'POST';
    st.url = '/token';
    st.postBody = 'grant_type=authorization_code&code=#arguments.OAuthCode#&redirect_uri=#urlEncodedFormat(variables.redirectURL)#&client_id=#variables.apiKey#&client_secret=#variables.apiSecret#';

    var httpService = new http(url=variables.OAuthBaseURL&st.url,method=st.method,timeout=variables.timeout);

    httpService.addParam(type="header",name="Content-Type",value="application/x-www-form-urlencoded");
    httpService.addParam(type="body", value=st.postBody);

    var result = httpService.send().getPrefix();

    return result;
  }

  public any function getOauthToken_refresh(required string refresh_token) {
    st = {};
    st.method = 'POST';
    st.url = '/token';
    st.postBody = 'grant_type=refresh_token&refresh_token=#arguments.refresh_token#&client_id=#variables.apiKey#&client_secret=#variables.apiSecret#';

    var httpService = new http(url=variables.OAuthBaseURL&st.url,method=st.method,timeout=variables.timeout);

    httpService.addParam(type="header",name="Content-Type",value="application/x-www-form-urlencoded");
    httpService.addParam(type="body", value=st.postBody);

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

      // set st structure before calling any services
      st = {};

      // create all available services
        switch (arguments.service) {

          case "getMe": 
            st.method = "GET";
            st.url="#variables.apiBaseURL#/oauth2/v1/userinfo";
            st.customVal=[];
            st.customURL=['alt:json'];
            break;

          case "getContact": 
            st.method = "GET";
            st.url="#variables.apiContactURL#/contacts/#structKeyExists(args,'userEmail')?args.userEmail:''#/full";
            st.customVal=['userEmail:email'];
            st.customURL=['alt:json','max-results:#structKeyExists(args,'maxResults')?args.maxResults:100#'];
            break;

          case "getContactPhoto": 
            st.method = "GET";
            st.url="#variables.apiContactURL#/photos/media/#structKeyExists(args,'userEmail')?args.userEmail:''#/#structKeyExists(args,'contactID')?args.contactID:''#";
            st.customVal=['userEmail:email','contactID:string'];
            st.customURL=[];
            break;            

          case "getContactGroup": 
            st.method = "GET";
            st.url="#variables.apiContactURL#/groups/#structKeyExists(args,'userEmail')?args.userEmail:''#/full";
            st.customVal=['userEmail:email'];
            st.customURL=['alt:json'];
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
    var httpService = new http(url=st.url,method=st.method,timeout=variables.timeout,getAsBinary='auto');

    // googleAPIs pass access token in header
    httpService.addParam(type="header",name="Authorization",value="OAuth #arguments.token#");

    // every request to API's should specify a version (e.g. Contacts API should specifiy version 3 of the API)
    httpService.addParam(type="header",name="GData-Version",value="3.0");


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

      // serialize all arguments into a JSON body parameter 
      httpService.addParam(type="body", value=serializeJSON(args));


    var result = {};
    result = callAPIservice(httpService);
    return result;

  } // end invokeAPIService



} // end Google API



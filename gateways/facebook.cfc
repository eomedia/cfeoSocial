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
  * @displayname Facebook Gateway
  * @hint A framework for functions to manage Facebook
  *
  */
component accessors="true" output="false" {

	// define the properties
	property string apiKey;
	property string apiSecret;
	property string redirectURL;

	// define default variables for component
	variables.graphBaseURL = "https://graph.facebook.com";
  variables.scope = "email,publish_actions,user_birthday,friends_birthday,user_location,friends_location,user_status,friends_status,user_website,friends_website,read_friendlists,read_stream";
  variables.timeout = 20;
  variables.pictureType = 'square';  // square(50x50)|small(50xheight)|normal(100xheight)|large(200xHeight)
  variables.returnFormat = "struct";
	

	/**
    * @description base constructor
    * @hint I instantiated the component
    **/

    public any function init(required string apiKey, required string apiSecret, string redirectURL) {
      setApiKey(arguments.apiKey);
      setApiSecret(arguments.apiSecret);
      setredirectURL(arguments.redirectURL);
      return this;
    }

    public any function getOauthURL(required struct argCol) {	

    	return 'https://www.facebook.com/dialog/oauth?client_id=#variables.apiKey#&redirect_uri=#urlEncodedFormat(variables.redirectURL)#&state=#urlEncodedFormat(argCol.state)#&scope=#variables.scope#';
    }

    public any function getOauthToken(required string OAuthCode) {

    	st = {};
    	st.method	= 'GET';
    	st.url 		= '/oauth/access_token?client_id=#variables.apiKey#&redirect_uri=#urlEncodedFormat(variables.redirectURL)#&client_secret=#variables.apiSecret#&code=#arguments.OAuthCode#';

    	var httpService = new http(url=variables.graphBaseURL&st.url,method=st.method,timeout=variables.timeout);

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

        /* FQL API */
          case "getFQL":

            /* helpful FQL examples at - http://steve.veerman.ca/2012/facebook-api-fql-tutorial/ */

            // set the appropriate FQL string based on the fql argument
            switch (args.fql) {
              
              case "getMe":
                args.fql = 'SELECT uid, name, pic_square, email, username, about_me, age_range, activities, birthday, can_post, contact_email, current_location, devices, education, friend_count 
                            FROM user 
                            WHERE uid = me()';
                break;

              case "getLike":
                args.fql = 'SELECT user_id, object_id, post_id, object_type FROM like WHERE user_id = me()';
                break;

              case "getGroupLike":
                args.fql = 'SELECT user_id, object_id, post_id, object_type FROM like WHERE object_type = "group" AND user_id = me()';
                break;

              case "getLinkLike":
                args.fql = 'SELECT url FROM url_like WHERE user_id = me()';
                break;

              case "getStreamList":
                args.fql = 'SELECT name, type, value, filter_key FROM stream_filter WHERE uid = me()';
                break;

              case "getStream":
                args.fql = 'SELECT post_id, viewer_id, app_id, source_id, updated_time, created_time, filter_key, attribution, actor_id, target_id, message, app_data, action_links, attachment, impressions, comments, like_info, likes, privacy, permalink, xid, tagged_ids, message_tags, description, description_tags 
                            FROM stream 
                            WHERE source_id = me() 
                              AND created_time >= "#args.since#"';
                break;

              case "getNewsfeed":
                args.fql = 'SELECT post_id, app_id, source_id, updated_time, filter_key, attribution, message, action_links, likes, permalink 
                            FROM stream 
                            WHERE filter_key IN (SELECT filter_key FROM stream_filter WHERE uid = me() AND type = "newsfeed")
                              AND created_time >= "#args.since#"';
                break;

              case "getStreamByApplicationID":
                args.fql = 'SELECT post_id, actor_id, target_id, message 
                            FROM stream 
                            WHERE filter_key IN (SELECT filter_key FROM stream_filter WHERE uid = me()) 
                              AND app_id = "#args.appID#"';
                break;

              case "getStreamByAttribution":
                args.fql = 'SELECT post_id, viewer_id, app_id, source_id, updated_time, created_time, filter_key, attribution, actor_id, target_id, message, app_data, action_links, attachment, impressions, comments, likes, privacy, permalink, xid, tagged_ids, message_tags, description, description_tags 
                            FROM stream 
                            WHERE source_id = me() 
                              AND attribution = "#args.attribution#"';
                break;

              case "getFriend":
                args.fql = 'SELECT uid, name, pic_square, email, username, current_location, devices, friend_count
                            FROM user 
                            WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me())
                            ORDER BY last_name ASC';
                break;

              case "getFriendByID":
                args.fql = 'SELECT uid, name, pic_square, email, username, current_location 
                            FROM user 
                            WHERE uid = #args.friendID#';
                break;

              case "getFriendWithApplication":
                args.fql = 'SELECT uid, name, pic_square FROM user WHERE is_app_user AND uid IN (SELECT uid2 FROM friend WHERE uid1 = me())';
                break;

              case "getFriendStream":
                args.fql = 'SELECT post_id, actor_id, message, updated_time, attribution FROM stream WHERE source_id = "#args.friendID#"';
                break;

              case "getPlace":
                args.fql = 'SELECT page_id,name,latitude,longitude,checkin_count,display_subtext,description,pic,search_type,type 
                            FROM place 
                            WHERE distance(latitude, longitude, "#args.latitude#", "#args.longitude#") < #args.meters#';
                break;

              case "custom":
                args.fql = args.customFQL;
                break;

              default:
                // no fql is set which should trigger error in st.customVal[] check
                break;


            } // end argments.fql

            st.method = "GET";
            st.url = "/fql";
            st.customVal=['fql:string']; 
            st.customURL=['q:#args.fql#'];
            
            break;

        /* USER FEED - things a user posts to Facebook */

          // post to my feed
          case "createFeed":  
            st.method = "POST";   
            st.url="/me/feed";   
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

		  // if there are no errors call the API service
	    var httpService = new http(url=variables.graphBaseURL&st.url,method=st.method,timeout=variables.timeout);

      // add access token
      httpService.addParam(type="url",name="access_token",value=arguments.token);

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

      // set the variable to use in the structEach loop below
      var httpAttributes = httpService.getAttributes();

      // loop over args and create formField params
      structEach(args, function(key,value){
        // if value included in httpService URL, exclude from formField (causes malformed access token response from FaceBook otherwise)
        if (!findNoCase(value, httpAttributes.url)){
          httpService.addParam(type="formField",name="#lCase(key)#",value="#value#"); 
        }  
      });

	    var result = {};
      result = callAPIservice(httpService);
      return result;

	} // end invokeAPIService
    
    


} // end facebook
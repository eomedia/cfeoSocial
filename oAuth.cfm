<!--- VIEW - MAIN/oAuth 

Author:			Ryan Smith
Created Date:  	2014
Last Updated:  
Descrption:		OAuth - site managed oAuth requests (Facebook, LinkedIn, Google)

--->


<!--- PAGE CONTENT --->

<cfscript>

	st = {};

	// validate the OAuth type
	switch(url.oid){
		case "fb":
			// FaceBook authentication - 
			app = createObject("component", "gateways.facebook");
			
			if (isDefined("url.error")){
				// ERROR
				
				st.error = #url.error#;
				st.errorCode = #url.error_code#;
				st.errorDescription = #url.error_description#;
				st.errorReason = #error_reason#;
				st.state = #url.state#;

				// redirect user to an error page
				// eg. location("/main/accessDenied", false);
				writeDump(st);

			} else if (isDefined("url.code")) {
				// SUCCESS

				// VALIDATE that returned "STATE" matches what you set in initial call (not included in this example)

				// get the OAuth token
				result = app.getOauthToken(url.code);  // writeDump(result);
				content = listToArray(result.fileContent, "&"); // writeDump(parts); writeOutput("<br>");
				tokenString = content[1];  writeDump(tokenString);  writeOutput("<br>");
				fbAccessToken = listGetAt(tokenString, 2, "="); // writeDump(fbAccessToken); writeOutput("<br>");

				session.fbToken = fbAccessToken; // temporary testing set of token
			}

		break;

		case "li":
			// LinkedIn authentication - 
			app = createObject("component", "gateways.linkedIn");
			
			if (isDefined("url.error")){
				// ERROR
				
				st.error = url.error;
				st.errorDescription = url.error_description;
				st.item = url.item;
				st.oid = url.oid;
				st.section = url.section;
				st.state = url.state;

				// redirect user to an error page
				// eg. location("/main/accessDenied", false);
				writeDump(st);

			} else if (isDefined("url.code")) {
				// SUCCESS

				// VALIDATE that returned "STATE" matches what you set in initial call (not included in this example)

				// get the OAuth token
				result = app.getOauthToken(url.code);  // writeDump(result);

				if (isJson(result.fileContent)){
					response = deserializeJSON(result.filecontent);
					session.liToken = response.access_token;  // temporary testing set of token
				} else {
					// error
					writeDump(result);
				}
			}

		break;


		case "go":
			// Google authentication - 
			app = createObject("component", "gateways.google");
			
			if (isDefined("url.error")){
				// ERROR

				st.error = url.error;
				st.state = url.state;

				// redirect user to an error page
				// eg. location("/main/accessDenied", false);
				writeDump(st);

			} else if (isDefined("url.code")) {
				// SUCCESS

				// VALIDATE that returned "STATE" matches what you set in initial call (not included in this example)

				// get the OAuth token
				result = app.getOauthToken(url.code);  // writeDump(result);

				if (isJson(result.fileContent)){
					response = deserializeJSON(result.filecontent);
					session.goToken = response.access_token;  // temporary testing set of token
					if (structKeyExists(response, "refresh_token")) { session.goToken_refresh = response.refresh_token; }
				} else {
					// error
					writeDump(result);
				}

			}

		break;
	
		default:
			// redirect user to an error page
			// eg. location("/main/accessDenied", false);
			writeOutput("error");
		break;
	}


	// redirect user to the starting location ( I used STATE variables as my location | e.g. facebook.cfm, google.cfm or linkedIn.cfm)
	location(url.state, false);

</cfscript>




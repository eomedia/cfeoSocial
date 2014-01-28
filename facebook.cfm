
<!--- FACEBOOK TESTING PAGE --->

	<!--- generate the authentication URL --->
	<cfset fbApp = createObject("component", "gateways.facebook")>>

	<cfif NOT isDefined("session.fbToken") OR isDefined("url.reinit")>
		<cfscript>
			
			st.state = "/test/facebook";
			OAuthLogin = fbApp.getOauthURL(st);

			// try to authenticate
			location(OAuthLogin, false);

		</cfscript>
	</cfif>


	<!--- if we have valid fbToken in session attempt calls --->
	<cfif !structKeyExists(session, "fbToken")>
		<cfdump var="#session#" label="fbToken does not exist">
	<cfelse>
		<cfdump var="#session#" label="fbToken exists">
		<cfscript>

			/* FQL */
			
			// Get my profile using FQL
			st = {};
			st.fql = 'getMe'; 
			getFQL = fbApp.invokeAPIService("getFQL",session.fbToken,st);
			writeDump(var=getFQL,label="API /getFQL (fb fql)");
			writeOutput("<hr>");

			// Get custom FQL data (e.g. Friends birthdays sorted by month)
			st = {};
			st.fql = 'custom';
			st.customFQL = 'SELECT first_name, last_name, birthday_date FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) AND birthday_date ORDER BY birthday_date'; 
			getFQL = fbApp.invokeAPIService("getFQL",session.fbToken,st);
			writeDump(var=getFQL,label="API /customFQL (fb fql)");
			writeOutput("<hr>");


			/* GRAPH API */

			// CREATE A FEED 
			if (isDefined("url.feed")){
				st = {};
				st.message = 'This is my message';
				st.link = 'http://vimeo.com/11111111';
					// st.name = 'short name';
					// st.caption = 'quick caption';
					// st.description = 'another short description';
					//st.picture = 'path to picture.png';
				st.privacy = '{"value":"SELF"}';
				//st.actions = '';
				//st.tags = '';

				// createFeed = fbApp.invokeAPIService("createFeed",session.fbToken,st);
				// writeDump(var=createFeed,label='create feed');
			}
			
		</cfscript>
	</cfif>

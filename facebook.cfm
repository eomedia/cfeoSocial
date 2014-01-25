
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

			// GET INFO ON ME
			dataOnMe = fbApp.invokeAPIService("getMe",session.fbToken,{});
			writeDump(var=dataOnMe,label="API /getMe (data on user)");
			writeOutput("<hr>");

			picOnMe = fbApp.invokeAPIService("getMePicture",session.fbToken,{});
			//writeDump(picOnMe);
			writeOutput('API /getMePicture <img src="#picOnMe.picture.data.url#">');


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
			
			// GET MY FEED INFO
			getFeed = fbApp.invokeAPIService("getFeed",session.fbToken,{});
			writeDump(var=getFeed,label="API /getFeed (feed on user)");
			writeOutput("<hr>");


			// GET A FRIEND BY ID
			st = {};
			st.friend = '100007615111111';  // use an ID for a friend
			getFriendByID = fbApp.invokeAPIService("getFriendByID",session.fbToken,st);  // writeDump(getFriendByID);

			//writeDump(getFriendByID);
			if (isDefined("getFriendByID.data")){
				arrayEach(getFriendByID.data, function(obj){
					writeDump(var=obj,label="API /getFriendByID");
					if (structKeyExists(obj, "picture")) {writeOutput('FriendByID PICTURE:  <img src="#obj.picture.data.url#">');}
					//image = imageRead(obj.picture.data.url);
					//imageScaleToFit(image, 100,100);
					writeOutput("<hr>");
				});
			} else {
				writeDump(var=getFriendByID,label="getFriendByID");
			}
				
			

			// GET ALL FRIENDS
			getFriend = fbApp.invokeAPIService("getFriend",session.fbToken,{});
			//writeDump(var=getFriend,label="API /getFriend (all)");
			arrayEach(getFriend.data, function(obj){
				// writeDump(obj);
				writeOutput('<img src="#obj.picture.data.url#"> ');
				writeOutput(obj.name);
				writeOutput(' | <b>ID</b>: #obj.id#');
				writeOutput(' | <b>b-day</b>: #structKeyExists(obj, "birthday")?obj.birthday:''#');
				writeOutput(' | <b>location</b>: #structKeyExists(obj, "location")?obj.location.name:''#');
				writeOutput(' | <b>email</b>: #structKeyExists(obj, "username")?obj.username:''#@facebook.com');
				
				writeOutput("<br>");
				
			});
		</cfscript>
	</cfif>

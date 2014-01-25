<!--- GOOGLE TESTING PAGE --->

	<!--- generate the authentication URL --->
	<cfset goApp = createObject("component", "gateways.google")>

	<cfif NOT isDefined("session.goToken") OR isDefined("url.reinit")>
		<cfscript>
			
			st.state = "/google.cfm";
			OAuthLogin = goApp.getOauthURL(st);

			// try to authenticate
			location(OAuthLogin, false);

		</cfscript>
	</cfif>

	<!--- if we have valid fbToken in session attempt calls --->
	<cfif !structKeyExists(session, "goToken")>
		<cfdump var="#session#" label="goToken does not exist">
	<cfelse>


		<cfdump var="#session#" label="goToken EXISTS">	

		<cfscript>

			//get the OAuth token_refresh
			// result = goApp.getOauthToken_refresh(session.goToken_refresh);  // writeDump(result);
			// writeDump(session.goToken_refresh);
			// writeDump(result);


		 	// get me
			getMe = goApp.invokeAPIService("getMe",session.goToken,{});
			writeDump(var=getMe,label="API /getMe");
			writeOutput("<hr>");

			// get contacts
			st.userEmail = 'user@domain.com';
			getContact = goApp.invokeAPIService("getContact",session.goToken,st);
			//writeDump(var=getContact,label="API /getContact");

			arrayEach(getContact.feed.entry, function(obj){
			 	
			 	//writeDump(obj);
			 	writeOutput("contact info:");

			 	// if name array exists get the name
			 	if (structKeyExists(obj, "gd$name")){
					arrayObj = obj.gd$name["gd$fullName"]["$t"];
					writeDump(arrayObj);
			 	} else {writeOutput(" | no name ");}

			 	// if email array exists get the address
			 	if (structKeyExists(obj, "gd$email")){
					arrayObj = obj.gd$email[1]["address"];
					writeOutput(arrayObj);
			 	} else {writeOutput(" | no email ");}

			 	// if link array exists find the image link
			 	if (structKeyExists(obj, "link")){
			 		arrayEach(obj.link, function(link){
			 			// look for a type of image/*
			 			if(link.type EQ "image/*"){
			 				
			 				arrayObj = link.href;
			 				writeOutput(listLast(arrayObj, "/"));

			 				st.userEmail = 'user@domain.com';
			 				st.contactID = '#listLast(arrayObj, "/")#';
			 				getPhoto = goApp.invokeAPIService("getContactPhoto",session.goToken,st);
			 				writeDump(getPhoto); // dump as binary if image, otherwise responseHeader
			 			}
			 		});
			 	} else {writeOutput(" | no links ");}


			 	writeOutput("<hr>");
			});

			

			// CONTACT GROUPS
			st.userEmail = 'user@domain.com';
			getContactGroup = goApp.invokeAPIService("getContactGroup",session.goToken,st);
			//writeDump(var=getContactGroup,label="API /getContactGroup");
			arrayEach(getContactGroup.feed.entry, function(obj){
				
				//writeDump(obj);
				writeOutput("group info:");

				if (structKeyExists(obj, "gContact$systemGroup")){
					writeOutput(obj.gContact$systemGroup["id"]);
				} else {writeOutput(" | not a system group");}

				writeOutput("<hr>");
			});


		</cfscript> 


<!--- image from top item --->
<!--- <cfimage action="writetobrowser" source="#getPhoto#" /> --->

		

	</cfif>
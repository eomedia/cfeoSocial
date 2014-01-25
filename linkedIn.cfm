<!--- LINKEDIN TESTING PAGE --->

	<!--- generate the authentication URL --->
	<cfset liApp = Application.beanFactory.getBean("linkedIn")>

	<cfif NOT isDefined("session.liToken") OR isDefined("url.reinit")>
		<cfscript>
			
			st.state = "/test/linkedIn";
			OAuthLogin = liApp.getOauthURL(st);

			// try to authenticate
			location(OAuthLogin, false);

		</cfscript>
	</cfif>

	<!--- if we have valid fbToken in session attempt calls --->
	<cfif !structKeyExists(session, "liToken")>
		<cfdump var="#session#" label="liToken does not exist">
	<cfelse>
		<!--- <cfdump var="#session#" label="liTOken EXISTS"> --->

		<cfscript>
			getMe = liApp.invokeAPIService("getMe",session.liToken,{});
			writeDump(var=getMe,label="API /getMe");
			writeOutput("<hr>");


			st.start = 1; // for pagination
			st.count = 500; // limit the returned records
			getFriend = liApp.invokeAPIService("getFriend",session.liToken,st);
			//writeDump(var=getFriend,label="API /getFriend");
			arrayEach(getFriend.values, function(obj){
				if (structKeyExists(obj, "pictureURL")){
					writeOutput("<img src='#obj.pictureURL#'>");
					writeOutput(obj.firstName & ' ' & obj.lastName);
					writeOutput(" | ID: #obj.id# | #obj.headline#");
					
				} else { writeOutput("No Picture | #obj.firstName# #obj.lastName# | ID: #obj.id# "); }
			
			writeOutput("<hr>");		
			}); 
			


			// generating a single structure with multiple people will send it as a CC instead of multiple unique messages
			st = {};
			st.recipients = {};
			st.recipients["values"] = [];

			st.recipients["values"][1]["person"]["_path"] = "/people/{ENTER ID HERE}";

			st.recipients["values"][2]["person"]["_path"] = "/people/~";

			st.subject = "test subject";
			st.body = "test";
			
			writeDump(serializeJSON(st));
			writeOutput("<hr>");

			// createMessage = liApp.invokeAPIService("createMessage",session.liToken,st);
			// writeDump(var=createMessage,label="API /createMessage");
			// writeOutput("<hr>");
		</cfscript>

	</cfif>

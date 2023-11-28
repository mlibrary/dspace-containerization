 <html>
    <head>
      <title>StatsReport</title>      
      <meta content="template generated html">
    </head>
    
<body bgcolor="ffffff" marginwidth="10" leftmargin="10" topmargin="10" marginheight="10">
<h2>Stats Added Report&nbsp;<a href="$SCRIPT_NAME/logout"><span class="normalfont">LOGOUT</span></a></h2>
<hr size="1">


<table width="100%" border="0" cellpadding="20">
  <tr>
    <td> 
	
		<!-- begin orginal template content  --> 
	
	

      <p class="normalfont">Request for stats on items added in <B> $COLLNAME </B></p>
   
      <form method="get" action="$SCRIPT_NAME" name="submit" target="_top">
      <input type="hidden" name="collid" value="$COLLID">
      <input type="hidden" name="restrict" value="$RESTRICT">
      <input type="hidden" name="pagenum" value="1">
      <input type="hidden" name="stattype" value="added">

	Search On: <SELECT NAME="searchtype">
	           <OPTION VALUE="title">Title
	  	   <OPTION VALUE="handle">Handle
		   <OPTION VALUE="authors">Author
		   $FOR_PR_ONLY
		   </SELECT>

	<Input type="text" name="searchvalue">
<P>
	Start Month:$START_DATE
	End Month:$END_DATE

	 Note: Start Date must be less than or equalled to  End Date (Start <= End)

<p>

   
	<p><input type="submit" name="submit" value="Get Stats" class="formfont"><input type="submit" name="submit" value="Choose Collection" class="formfont"></p>

      </form>
	  
	<!-- end orginal template content  --> 
	  
	  </td>
	 </tr>
	</table> 
	
	<p>&nbsp;</p>
    </body>
  </html>



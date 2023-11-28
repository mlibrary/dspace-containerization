  <html>
    <head>
<link rel="stylesheet" href="/m/metamgr/metamgr.css" type="text/css">
<title>Access Report Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>
    
    
<body bgcolor="ffffff" marginwidth="10" leftmargin="10" topmargin="10" marginheight="10">
<h2>Access Report Page&nbsp;<a href="$SCRIPT_NAME/logout"><span class="normalfont">LOGOUT</span></a></h2>
<hr size="1">


<table STYLE="font: 10pt"  width="100%" border="1" cellpadding="1">
  <tr>
    <td>
      <form  enctype="multipart/form-data" method="get" action="$SCRIPT_NAME" name="submit" target="_top">
	      <input type="hidden" name="collid" value="$COLLID">
              <input type="hidden" name="restrict" value="$RESTRICT">		
              <input type="hidden" name="pagenum" value="$PAGENUM">	
              <input type="hidden" name="enddt" value="$ENDDT">	
              <input type="hidden" name="stattype" value="$STATTYPE">	
              <input type="hidden" name="startdt" value="$STARTDT">	
              <input type="hidden" name="searchvalue" value="$SEARCHVALUE">
              <input type="hidden" name="searchtype" value="$SEARCHTYPE">	

        <P>Stats from $STARTDT to $ENDDT for <B>$COLLNAME</B> Total Records= $TOTALRECS Total Pages= $TOTALPAGES </P> $EMAIL_STATUS
        <br>
	 	
	$PAGE_REPORT
          $DOWNLOAD_REQ
	  $NEXT_PAGE
          <input type="submit" name ="submit" value="Back" class="formfont">
        </td></tr></table>
	
		
      </form>
    </td>
  </tr>
</table>
<p>&nbsp;</p>
<p>&nbsp;</p>


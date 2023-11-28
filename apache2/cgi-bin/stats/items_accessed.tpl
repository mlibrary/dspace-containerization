 <html>
    <head>
      <title>Stats Report</title>      
      <meta content="template generated html">
    </head>
    
<body bgcolor="ffffff" marginwidth="10" leftmargin="10" topmargin="10" marginheight="10">
<h2>Stats Access Report&nbsp;<a href="$SCRIPT_NAME/logout"><span class="normalfont">LOGOUT</span></a></h2>
<hr size="1">


<table width="100%" border="0" cellpadding="20">
  <tr>
    <td> 
	
		<!-- begin orginal template content  --> 
	
	

      <p class="normalfont">Request for stats on items accessed in <B> $COLLNAME </B></p>
   
      <form method=get action="$SCRIPT_NAME" name="submit" target="_top">
      <input type="hidden" name="collid" value="$COLLID">
      <input type="hidden" name="restrict" value="$RESTRICT">
      <input type="hidden" name="pagenum" value="1">
      <input type="hidden" name="stattype" value="access">

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


<P><B>The following is a key to the column headings for the report generated when stats are requested.</B></P>


<P>Handle
<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Deep Blue's handle (persistent URL).  Append this to
   "http://hdl.handle.net/" to access the item via Deep Blue. </BR></P>

<P>Title
<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Title of the item.</BR></P>

<P>Authors
<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Author(s) of the item.</BR></P>

<P>Inside
<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Number of times item was visited from inside Deep Blue. In
   other words, it was discovered via a browse/search using
   Deep Blue's interface.</BR></P>

<P>InsideUM
<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Number of times the "Inside" access was from a UM I.P.
   address, providing a rough measure of uses by UM faculty,
   staff, or student only. (Though visitors also have access
   to these items when in campus buildings.) </BR></P>

<P>InsideNonUM
<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Number of times the above "Inside" access was from a
   non-UM I.P. address, providing a rough measure of whether
   the user was not UM faculty, staff, or student. NOTE: This
   number is an even less accurate measure of non-UM use than
   "InsideUM" is of UM use, since any access from off campus
   will be counted in this category -- including UM faculty
   working from home, UM students working from apartments,
   etc.</BR></P>

<P>Outside
<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Number of times item is visited via just the handle. For
   example, if someone discovered the item via Google or
   OAIster, they will almost certainly bypass the Deep Blue
   search/browse interface to get to it and will be counted
   in this group.</BR></P>


<P>OutsideUM
<BR>OutsideNonUM
<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;As per InsideUM and InsideNonUM above.</BR></P>

<P>Download
<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Number of times the file(s), a.k.a. bitstreams, in the
   item were downloaded.  As alluded to above, this can
   happen either via someone going to an item's handle first,
   or just by going to the file directly. (So this number can
   be greater than the sum of Inside + Outside.)</BR></P>

<P>DownloadUM
<BR>DownloadNonUM
<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;As per InsideUM and InsideNonUM above.</BR></P>

<P>Publisher
<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Publisher of the item, if available.</BR></P>

<P>DateAdded
<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Date the item was made available in Deep Blue.</BR></P>

<P>BitCount
<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Number of files in the item.</BR></P>

<P>DOI
<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DOI for the item, if available.</BR></P>

<P>ISSN
<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ISSN(s) for the item, if available.</BR></P>


      </form>
	  
	<!-- end orginal template content  --> 
	  
	  </td>
	 </tr>
	</table> 
	
	<p>&nbsp;</p>
    </body>
  </html>



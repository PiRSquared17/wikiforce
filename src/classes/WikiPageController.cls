/**
*@author Yuri Alvarez @ 05/02/2008
*/
public with sharing class WikiPageController {

	public String idWikiSite = '';
	
	public String idWikiPage = '';
	WikiPage__c	wikiPageBody;
	public List<WikiPage__c> results;
	public String theParent = '';
	public String parent = ''; 
	public Integer first = 0;
	public Integer maxView = 5;	  

   	public Info infoWP = new Info();
		
	public String linkpart1 = 'switchOverlay(true);;A4J.AJAX.Submit(\'_viewRoot\',\'WikiPage:auxForm\',event,{\'parameters\':{\'WikiPage:auxForm:auxLink\':\'WikiPage:auxForm:auxLink\',\'idWP2\':\'';
	public String linkpart2 = '\'} ,\'actionUrl\':\'/apex/WikiPage?javax.portlet.faces.DirectLink=true\',\'oncomplete\':function(request,event,data){switchOverlay(false);}} );return false;\" name=\"WikiPage:auxForm:auxLink\" id=\"WikiPage:auxForm:auxLink\" href=\"#\">';

	public String paramIdWP = System.currentPageReference().getParameters().get('idWP');
	
	/**
	* Costructor
	*/
	public WikiPageController () {
		contructMethods();
	}
		
	/**
	*@param String
	*/
	public void setParamIdWP (String paramIdWP){
		this.paramIdWP = paramIdWP;
	}
	
	/**
	*@param String
	*/
	public void setIdWikiPage (String idWikiPage) {
		this.idWikiPage = idWikiPage;
	}
	
	public String wikiPageName = '';
	
	/**
	*@param String
	*/
	public void setWikiPageName (String wikiPageName) {
		this.wikiPageName = wikiPageName;
	}
	
	/**
	*@return String
	*/
	public String getWikiPageName () {
		String trunkName;
		if (wikiPageName.length() > 25) {
			trunkName = wikiPageName.substring(0,23) + '..';
		}
		else {
			trunkName = wikiPageName;
		}
		return '<strong>' + trunkName + '</strong>';	
	}
	
	public List<WikiPage__c> wikiPageBodyList = new List<WikiPage__c>();
	
	/**
	* Gets the first wikipage whose id is paramIdWp, stores its name and id,
	* parses the page and generates the relates information.
	*@throws CustomException
	*/
	public void contructMethods () {
		if(paramIdWP != null) {
			wikiPageBodyList = [SELECT Id, 
									   Name, 
									   ShortDescription__c, 
									   Body__c, 
									   Parent__c, 
									   LastModifiedDate,
									   PageCreatedBy__c,
									   Wiki__c,
									   Wiki__r.Name,
									   Wiki__r.Id 
							    From WikiPage__c WHERE id =:paramIdWP];
			if (wikiPageBodyList.size() > 0) {
				wikiPageBody = wikiPageBodyList[0];
			}
			else {
				throw new CustomException('Insufficient Privileges');	
			}
			
			wikiPageName = wikiPageBody.Name;
			idWikiPage = paramIdWP; // no reason for this var...clean it up!
			
			idWikiSite = wikiPageBody.Wiki__r.Id;
			
			parseHTML();
			infoGen();
			
			genPermissions(wikiPageBody.PageCreatedBy__c);
			
		}
	}
	
	
	/* ---------------------------- */
   	/*   	 SHARING RULES			*/
   	/* ---------------------------- */	
	public UserPermissions userPermissions = new UserPermissions();
	
	/**
	* Generates the user permissions
	*@param Id
	*/
	public void genPermissions (Id OwnerId) {
		userPermissions.setId(UserInfo.getUserId());
		userPermissions.setTeam(idWikiSite);
		userPermissions.setOwnerId(OwnerId);
		userPermissions.setObjectType('Wiki');
		userPermissions.setPermissions();		
	}
	
	/**
	*@return UserPermissions
	*/
	public UserPermissions getUserPermissions () {
		return userPermissions;
	}
	/* ---------------------------- */		
		
	/**
	*@param String
	*/
	public void setIdWikiSite (String idWikiSite) {
		this.idWikiSite = idWikiSite;
	}
	
	/**
	*@return String
	*/
	public String getWikiHome () {
		return [select Id from WikiPage__c where Wiki__c =:idWikiSite limit 1].Id;
	}
	
	/**
	*@return String
	*/
	public String getWikiSiteName () {
		String teamName = '';
		if (idWikiSite != null) {
			Wiki__c teamNameResult = [select id, Name from Wiki__c where id=:idWikiSite];
			
			if (teamNameResult != null) {
				teamName = '<a href="/apex/TeamsRedirect?id=' + teamNameResult.Id + '">' + teamNameResult.name + '</a> > <a href="/apex/WikiTeamOverview?tid=' + teamNameResult.Id + '">Wiki</a> > ';	
			}
		}
		return teamName;
	}
	
	/**
	*@return String
	*/
	public String getidWikiPage () {
		return idWikiPage;
	}
	
	
	
   	/* ---------------------------- */
   	/*   	 SHOW WIKI PAGES		*/
   	/* ---------------------------- */	

	/**
	*@return WikiPage__c
	*/
	public WikiPage__c getWikiBody () {
		return wikiPageBody;	
	}

	
	/**
	* Gets the wiki page and stores it in wikiPageBody
	*/
    public void getWiki() {
    	
    	WikiPage__c wiki;
    	
    	if (System.currentPageReference().getParameters().get('idWP2') == '' || System.currentPageReference().getParameters().get('idWP2') == null || System.currentPageReference().getParameters().get('idWP2') == '0') {
    		idWikiPage = getWikiHome();
    	}
    	else {
    		idWikiPage = System.currentPageReference().getParameters().get('idWP2');
    	}
    	  	
    	wiki = [SELECT Id, Name, ShortDescription__c, Body__c, Parent__c, LastModifiedDate FROM WikiPage__c WHERE id = : idWikiPage ];
		
		Integer cntTempView = [select count() from WikiRecentlyViewed__c where User__c =:UserInfo.getUserId() AND WikiPage__c =:idWikiPage];
		if (cntTempView == 0 ) {
    		WikiRecentlyViewed__c wikiView = new WikiRecentlyViewed__c();
    		wikiView.User__c = UserInfo.getUserId();
    		wikiView.WikiPage__c = idWikiPage;
    		wikiView.Name = wiki.Name;
    		insert wikiView;
    		
    		Integer totalCnt = getCntViews(); 
			if ( totalCnt > maxView) {
				Integer delNum = totalCnt - maxView; 
				List<WikiRecentlyViewed__c> delView = [SELECT Id, Name FROM WikiRecentlyViewed__c WHERE User__c = :UserInfo.getUserId() ORDER BY LastModifiedDate limit :delNum];
				delete delView;	
			}
		}
		else {
			WikiRecentlyViewed__c tempView;
			tempView = [select User__c, WikiPage__c from WikiRecentlyViewed__c where User__c =:UserInfo.getUserId() AND WikiPage__c =:idWikiPage limit 1];
			update tempView;
		}
     	
    	wikiPageBody = wiki;
    	
    }
	
	
   	/* ---------------------------- */
   	/*   	  PARSE WIKI PAGE		*/
   	/* ---------------------------- */	 
 	public String html = null;
 	
 	
 	/**
	* Parses the wikipage and stores its HTML code in the html attribute
	*/
 	public void parseHTML() {
		
		WikiPage__c wikiHTML = new WikiPage__c();
    	String toc = '';
    	
    	if (idWikiPage != null && idWikiPage != '') {
    	wikiHTML = [SELECT Name, ShortDescription__c, Body__c, Parent__c, LastModifiedDate FROM WikiPage__c WHERE id = : idWikiPage ];		
    	}
 		
  		html = wikiHTML.Body__c;
  		
		if (html != null && html!= '') {
	 		html = html.replaceAll('[\n\r]','<br>');
			html = html.replaceAll('&nbsp;',' ');
			html = html.replaceAll('&gt;','>');
			html = html.replaceAll('&lt;','<');
			
			
			/* ------------------------ */
	 		/* 		Code (No parsed) 	*/
	 		String noparsedOpen = '{{{';	
	 		String noparsedClose = '}}}';
	 		String splitOpen = '\\{\\{\\{';
	 		String splitClose = '\\}\\}\\}';
	 		String replacementCode = '%-%-%-%';
	 		List<String> noparsedText = new List<String>();
	 		while (html.lastIndexOf(noParsedOpen) != -1) {
		 		List<String> temp = new List<String>();
		 		temp = html.split(splitOpen ,2);
		 		List<String> temp2 = new List<String>();
		 		String code;
		 		if (temp[1].indexOf(noparsedClose) != -1) {
			 		temp2 = temp[1].split(splitClose ,2);
			 		code = temp2[0];
		 		}
		 		else {
		 			temp2.add(temp[1]);
				 	temp2.add('');
				 	code = temp[1];
		 		}
		 		
		 		html = temp[0] + replacementCode + temp2[1];
	 			noparsedText.add(code);
	 		}
	 		
	 		
	 		/* ------------------------ */
	 		/* 			Tables 		 	*/
			
			String tableStart = '{|';
	 		String tableStartExp = '\\{\\|';
	 		
	 		String tableEnd = '|}';
	 		String tableEndExp = '\\|\\}';
	 		
	 		String tableCaption = '|+';
	 		String tableCaptionExp = '\\|\\+';
	 		
	 		String tableRow = '|-';
	 		String tableRowExp = '\\|-';
	 		
	 		String tableHeader = '!';
	 		
	 		String tableData = '|';
	 		String tableDataExp = '\\|';
	 		
	 		while (html.lastIndexOf(tableStart) != -1) {
				List<String> htmlParts = new List<String>();
				htmlParts = html.split(tableStartExp,2);
				
				String bodyTable = '';
				String tableTag = '<table ';
				String tailHtml = '';
				
				if (htmlParts[1].indexOf(tableEnd) != -1) {
					List<String> tailParts = new List<String>();
					tailParts = htmlParts[1].split(tableEndExp,2);
					String tableContent = '';
					
					tableContent = tailParts[0];
					
					tailHtml = tailParts[1];
					if (tableContent != '') {
						if (tableContent.toLowerCase().indexOf('<br>') != -1) {
							List<String> tableAttParts = new List<String>();
							tableAttParts = tableContent.split('(?i)<br>',2);
							List<String> tableAtts = new List<String>();
							bodyTable = tableAttParts[1].trim();
							
							// If the table have attributes
							if (tableAttParts[0].length() != 0) {
								tableTag += tableAttParts[0].trim(); //support all attributes
							}	
						}
						tableTag += '>';
						
						// If have caption Syntax
						List<String> captionTextParts = new List<String>();
						
						if (bodyTable.toLowerCase().indexOf('<br>') != -1) {
							captionTextParts = bodyTable.substring(2).split('(?i)<br>',2);
							
							if (bodyTable.trim().indexOf(tableCaption) == 0 && bodyTable.toLowerCase().indexOf('<br>') != -1) {
								String captionText = captionTextParts[0].trim();
								if (captionText.indexOf(tableData) == -1) {
									tableTag += '<caption>' + captionText + '</caption>';
								}
								else {
									List<String> captionParts = new List<String>();
									captionParts = captionText.split(tableDataExp,2);
									tableTag += '<caption ' + captionParts[0].trim() + '>' + captionParts[1] + '</caption>';	
								}
								bodyTable = captionTextParts[1];
							}
							else {
								if (bodyTable.trim().indexOf(tableRow) != 0) {
									bodyTable = '<br>' + bodyTable;
								}	
							}
							
							List<String> tableRows = new List<String>();
							if (bodyTable.indexOf(tableRow) != -1) {
								tableRows = bodyTable.split(tableRowExp);	
							}
							else {
								tableRows.add(bodyTable);
							}
							
							for (String itemRow : tableRows) {
								String iterRow = itemRow;
								List<String> rowAtt = new List<String>();
								rowAtt = iterRow.split('(?i)<br>',2);
								
								if (rowAtt.size() == 2) {
									tableTag += '<tr ';
									if (rowAtt[0] != '' && rowAtt[0] != null ) {
										tableTag += rowAtt[0].trim();
									}
									tableTag += '>';
									
									iterRow = rowAtt[1].trim();
									
									for (String itemCell : iterRow.split('(?i)<br>')) {
										if (itemCell.trim().indexOf(tableHeader) == 0) {
											tableTag += '<th ';
											String tdContent = '';
											if (itemCell.length() > 1) {
												itemCell = itemCell.substring(1);
												if (itemCell.indexOf(tableData) != -1) {
													List<String> tdAtts = new List<String>();
													tdAtts = itemCell.split(tableDataExp, 2);
													String tdAtt = '';
													if (tdAtts[0] != null) {
														tdAtt = tdAtts[0].trim();
													}
													if (tdAtts[1] != null) {
														tdContent = tdAtts[1].trim();
													}
													tableTag += tdAtt.trim();	 
												}	
												else {
													tdContent = itemCell.trim();	
												}
											}
											tableTag += '>';
											tableTag += tdContent;
										}
										
										else {
											if (itemCell.trim().indexOf(tableData) == 0) {
												tableTag += '<td ';
												String tdContent = '';
												if (itemCell.length() > 1) {
													itemCell = itemCell.substring(1);
													if (itemCell.indexOf(tableData) != -1) {
														List<String> tdAtts = new List<String>();
														tdAtts = itemCell.split(tableDataExp, 2);
														String tdAtt = '';
														if (tdAtts[0] != null) {
															tdAtt = tdAtts[0].trim();
														}
														if (tdAtts[1] != null) {
															tdContent = tdAtts[1].trim();
														}
														tableTag += tdAtt;	 
													}	
													else {
														tdContent = itemCell.trim();	
													}
												}
												tableTag += '>';
												tableTag += tdContent;
											}
											
											tableTag += '</td>';
										}
									}
									tableTag += '</tr>';	
								}
							}
						}
						tableTag += '</table>';
						html = htmlParts[0] + tableTag + tailHtml;
					}
					else {
						html = htmlParts[0] + '<table></table>' + tailHtml;	
					}
				}
				else {
					html = htmlParts[0] + '<table></table>' + htmlParts[1];
				}
				
			}	
	 		
	 		
	 		
			/* ------------------------ */
	 		/* 		Background color  	*/
	 		
	 		String bgcolorOpen = '[Bgcolor:';	
			while (html.IndexOf(bgcolorOpen) != -1) {
				List<String> temp = new List<String>();
				List<String> temp2 = new List<String>();
				temp = html.split('\\[Bgcolor:', 2);
				String tail = temp[1].trim();
				String endChar = '';
				
				if (tail.indexOf('rgb(') == 0) {
					temp2 = tail.split('\\)', 2);
					temp2[0] += ')';
					endChar = ' ';
				}
				else {
					if (tail.indexOf(' ') != -1 || tail.indexOf('<br>') != -1) {
						if((tail.indexOf(' ') < tail.indexOf('<br>')) || (tail.indexOf('<br>') == -1)) {
							temp2 = tail.split(' ', 2);
							endChar = ' ';
						}
						else {
							temp2 = tail.split('(?i)<br>', 2);	
							endChar = '<br>';
						}
					}
					else {
						temp2.add(tail);
						temp2.add(' ');	
					}
				}
				
				String bgcolorClose = 'Bgcolor\\]';
				String restHtml = temp2[1].replaceFirst(bgcolorClose,'</span>');
				html = temp[0] + '<span style="background-color:' + temp2[0] + ';">' + endChar + restHtml;	
			}
	
	 		/* ------------------------ */
	 		/* 		   Text Color	  	*/
	 		
	 		String colorOpen = '[Color:';	
			while (html.IndexOf(colorOpen) != -1) {
				List<String> temp = new List<String>();
				List<String> temp2 = new List<String>();
				temp = html.split('\\[Color:', 2);
				String tail = temp[1].trim();
				String endChar;
				if (tail.indexOf('rgb(') == 0) {
					temp2 = tail.split('\\)', 2);
					temp2[0] += ')';
					endChar = ' ';
				}
				else {
					if (tail.indexOf(' ') != -1 || tail.indexOf('<br>') != -1) {
						if((tail.indexOf(' ') < tail.indexOf('<br>')) || (tail.indexOf('<br>') == -1)) {
							temp2 = tail.split(' ', 2);
							endChar = ' ';
						}
						else {
							temp2 = tail.split('(?i)<br>', 2);	
							endChar = '<br>';    
						}
					}
					else {
						temp2.add(tail);
						temp2.add('');
					}
				}
				
				String colorClose = 'Color\\]';
				String restHtml = temp2[1].replaceFirst(colorClose,'</span>');
				html = temp[0] + '<span style="color:' + temp2[0] + ';">' + endChar + restHtml;	
			}
			
			
	 		/* ------------------------ */
	 		/* 			Text Ident 		*/
	 		
	 		String identOpen = '[[-';	
			while (html.IndexOf(identOpen) != -1) {
				List<String> temp = new List<String>();
				List<String> temp2 = new List<String>();
				temp = html.split('\\[\\[-', 2);
				String identClose;
				Integer identPx;
				if (temp[1].indexOf('>') != -1) {
					temp2 = temp[1].split('>', 2);
					identPx = (temp2[0].length() + 1) * 20;
					if (temp2[0].length() != 0 ) {
						identClose = temp2[0] + '->\\]\\]';
					}
					else {
						identClose = '->\\]\\]';
					}
				}
				else {
					identPx = 0;
					identClose = '';
					temp2.add(temp[1]);
					temp2.add('');	
				}
				
				String restHtml = temp2[1].replaceFirst(identClose,'</p>');
				html = temp[0] + '<p style="margin-left:' + identPx + 'px;">' + restHtml;	
			}
	 			
	  		/* ------------------------ */
	 		/* 		Horizontal Line 	*/
	 		String line = '----';
	 		html = html.replace(line ,'<hr>');
	
	
			/* ------------------------ */
	 		/* 			Emoticons	 	*/
	 		String resourceId = '1211555009000';
			String surprised = ':\\|';
			html = html.replaceAll(surprised , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/whatchutalkingabout_smile.gif\'>');
	
			/* ------------------------ */
	 		/* 			Text Align	 	*/
			
			String alignRightOpen = '\\[\\[>';
			String alignLeftOpen = '\\[\\[<';
			String alignCenterOpen = '\\[\\[=';
			String alignJustifyOpen = '\\[\\[<>';
			
			String alignRightClose = '>\\]\\]';
			String alignLeftClose = '<\\]\\]';
			String alignCenterClosen = '=\\]\\]';
			String alignJustifyClose = '<>\\]\\]';
			
			html = html.replaceAll(alignJustifyOpen ,'<p style="text-align: justify;">');
			html = html.replaceAll(alignRightOpen ,'<p style="text-align: right;">');
			html = html.replaceAll(alignLeftOpen ,'<p style="text-align: left;">');
			html = html.replaceAll(alignCenterOpen ,'<p style="text-align: center;">');
			
			html = html.replaceAll(alignJustifyClose ,'</p>');
			html = html.replaceAll(alignRightClose ,'</p>');
			html = html.replaceAll(alignLeftClose ,'</p>');
			html = html.replaceAll(alignCenterClosen ,'</p>');
	 		
	   		/* ------------------------ */
	 		/* 		UnOrdered List	 	*/
	 		String listSyntax = '*';
	 		Boolean first = true;
	 		Boolean last = false;
	 		while (html.lastIndexOf(listSyntax) != -1) {	
		 		String listS = '\\*';
		 		List<String> temp;
		 		temp = html.split(listS,2);
		 		html = html.replaceFirst(listS , '<li>');
		 		if ((temp[1].indexOf(listSyntax) >= temp[1].toLowerCase().indexOf('<br>') && temp[1].toLowerCase().indexOf('<br>') != -1) || temp[1].indexOf(listSyntax)== -1 ) {
		 			if (temp[1].toLowerCase().indexOf('<br>') == -1) {
		 				temp[1] = '>' + temp[1] + '</li></ul>';
		 				last = true;
		 			}
		 			else {	 
		 				List<String> temp2;	
		 				temp2 = temp[1].split('(?i)<br>',2);	
		 				if ((temp2[1].indexOf(listSyntax) < 3) && (temp2[1].indexOf(listSyntax) != -1) ) {	
		 					temp[1] = '>' + temp[1].replaceFirst('(?i)<br>', '</li>');
		 				}
		 				else {
		 					temp[1] = '>' + temp[1].replaceFirst('(?i)<br>', '</li></ul>');
		 					last = true;
		 				}
		 			}
		 		}
		 		else {
		 			temp[1] = temp[1].replaceFirst(listS,'');
		 			if (temp[1].toLowerCase().indexOf('<br>') == -1) {
		 				temp[1] = ' style="padding-left:10px;">' + temp[1] + '</li></ul>';
		 				last = true;
		 			}
		 			else {	 		
		 				temp[1] = ' style="padding-left:10px;">' + temp[1].replaceFirst('(?i)<br>', '</li>');
		 			}
		 		}	
		 		if (first) {
		 			html = temp[0] + '<ul><li' + temp[1];
		 			first = false;
		 		}
		 		else {
		 			html = temp[0] + '<li' + temp[1];
		 		}
		 		if (last) {
		 			first = true;
		 			last = false;
		 		}
	 		}
	 		
	   		/* ------------------------ */
	 		/* 		Ordered List		*/
	 		String listSyntaxOL = '~';
	 		Boolean firstOL = true;
	 		Boolean lastOL = false;
	 		
	 		while (html.lastIndexOf(listSyntaxOL) != -1) {	
		 		String listS = '~';
		 		List<String> temp;
		 		temp = html.split(listS,2);
		 		html = html.replaceFirst(listS , '<li>');
		 		if ((temp[1].indexOf(listSyntaxOL) >= temp[1].toLowerCase().indexOf('<br>') && temp[1].toLowerCase().indexOf('<br>') != -1) || temp[1].indexOf(listSyntaxOL)== -1 ) {
		 			if (temp[1].toLowerCase().indexOf('<br>') == -1) {
		 				temp[1] = '>' + temp[1] + '</li></ol>';
		 				lastOL = true;
		 			}
		 			else {	 
		 				List<String> temp2;	
		 				temp2 = temp[1].split('(?i)<br>',2);	
		 				if (temp2[1].indexOf(listSyntaxOL) == 0) {	
		 					temp[1] = '>' + temp[1].replaceFirst('(?i)<br>', '</li>');
		 				}
		 				else {
		 					temp[1] = '>' + temp[1].replaceFirst('(?i)<br>', '</li></ol>');
		 					lastOL = true;
		 				}
		 			}
		 		}
		 		else {
		 			temp[1] = temp[1].replaceFirst(listS,'');
		 			if (temp[1].toLowerCase().indexOf('<br>') == -1) {
		 				temp[1] = ' style="padding-left:10px;">' + temp[1] + '</li></ol>';
		 				lastOL = true;
		 			}
		 			else {	 		
		 				temp[1] = ' style="padding-left:10px;">' + temp[1].replaceFirst('(?i)<br>', '</li>');
		 			}
		 		}	
		 		if (firstOL) {
		 			html = temp[0] + '<ol><li' + temp[1];
		 			firstOL = false;
		 		}
		 		else {
		 			html = temp[0] + '<li' + temp[1];
		 		}
		 		if (lastOL) {
		 			firstOL = true;
		 			lastOL = false;
		 		}
	 		}
	 		/* ------------------------ */
	 		/* 			HEADINGS 		*/
	 		 	String header = '=======';
	 		 	for (Integer i = 6; i > 1; i--) {
			 		if (header.length() > 1) {
			 			header = header.substring(1);
			 		}
			 				
		 	 		while (html.lastIndexOf(header) != -1) {
				 		List<String> temp = new List<String>();
				 		List<String> temp2 = new List<String>();
				 		Integer indexOfHeader = html.indexOf(header);
				 		temp = html.split(header, 2);
				 		html = html.replaceFirst(header,'<h' + i + '>');
				 		String linkName = '';
				 		if (temp[1].indexOf(header) != -1 && ((temp[1].indexOf(header) < temp[1].indexOf('<br>')) || temp[1].indexOf('<br>') == -1 ) ) {
				 			temp2 = temp[1].split(header, 2);
				 			linkName = temp2[0].trim();
				 			html = html.replaceFirst(header,'</h' + i + '><hr>');
				 		}
				 		else {
				 			temp2.add(temp[1]);
				 			temp2.add('');
				 		}
						
						Integer fontSize;
						if (i == 2) { fontSize = 20; }
						if (i == 3) { fontSize = 18; }
						if (i == 4) { fontSize = 16; }
						if (i == 5) { fontSize = 14; }
						if (i == 6) { fontSize = 13; }
						
						if (temp[1].indexOf(header) != -1) {
				 			html = temp[0] + i + '%%%%<a name="' + linkName + '"></a>%%%%<h' + i + ' style="font-size:' + fontSize + 'px;">' + temp2[0] + '</h' + i + '><hr>' + temp2[1];
						}
						else {
							html = temp[0] + i + '%%%%<a name="' + linkName + '"></a>%%%%<h' + i + ' style="font-size:' + fontSize + 'px;">' + temp2[0];
						} 
				 		
			 		} 
		
	 		
	 		 	}
		 		
	 		/* ------------------------ */
	 		/* 			Bold Text 		*/ 			
	 		String bold = '\'\'\'';
	 		while (html.lastIndexOf(bold) != -1) {
		 		html = html.replaceFirst(bold , '<b>');
		 		html = html.replaceFirst(bold , '</b>');
	 		}
	 		
	 		/* ------------------------ */
	 		/* 		UnderLine Text 		*/ 			
	 		String under = '__';
	 		while (html.lastIndexOf(under) != -1) {
		 		html = html.replaceFirst(under , '<u>');
		 		html = html.replaceFirst(under , '</u>');
	 		}
	 		
	 		
	 		/* ------------------------ */
	 		/* 		SubScript Text 		*/ 			
	 		String sub = ',,';
	 		while (html.lastIndexOf(sub) != -1) {
		 		html = html.replaceFirst(sub , '<sub>');
		 		html = html.replaceFirst(sub , '</sub>');
	 		}
	 		
	 		/* ------------------------ */
	 		/* 		SuperScript Text 	*/ 			
	 		String sup = '^';
	 		String supExp = '\\^';
	 		while (html.lastIndexOf(sup) != -1) {
		 		html = html.replaceFirst(supExp , '<sup>');
		 		html = html.replaceFirst(supExp , '</sup>');
	 		}
	 		 		
	 		/* ------------------------ */
	 		/* 			Italic Text 	*/ 		
	 		String italic = '\'\'';
	 		while (html.lastIndexOf(italic) != -1) {
		 		html = html.replaceFirst(italic , '<i>');
		 		html = html.replaceFirst(italic , '</i>');
	 		}
	 		
			/* ------------------------ */
	 		/* 		Strike Text 		*/ 			
	 		String strikeOpen = '\\-\\-\\(';
	 		String strikeClose = '\\)\\-\\-';
		 	html = html.replaceAll(strikeOpen , '<strike>');
		 	html = html.replaceAll(strikeClose , '</strike>');
	
	 		/* ------------------------ */
	 		/* 		External Link 		*/
	 		/*		HTTPS SUPORT		*/  
	 		String extLink = '[http';
	 		while (html.lastIndexOf(extLink) != -1) {
	 			List<String> temp;
	 			String extL = '\\[http'; 
	 			temp = html.split('(?i)' + extL , 2);
	 			
	 			if (temp[1].indexOf(' ') != -1 && temp[1].indexOf(']') != -1) {
		 			html = temp[0] + '<a href="http';
		 			String[] temp2 = temp[1].split(' ', 2);
		 			html += temp2[0] + '"';
		 			List<String> temp3 = new List<String>();
		 			if (temp2[1].indexOf('[Image:') != -1 && (temp2[1].indexOf('[Image:') < temp2[1].indexOf(']'))) {
		 				temp3 = temp2[1].split('\\]\\]', 2);
		 				temp3[0] += ']';
		 			}
		 			else {
		 				temp3 = temp2[1].split('\\]', 2);
		 			}
		 			html += '>' + temp3[0] + '</a>';
		 			html += temp3[1];
	 			}
	 			else {
	 				html = temp[0] + '<a href="javascript:;">Malformed Link</a>' + temp[1];	
	 			}
	 		}  
	 				
	 		/* ------------------------ */
	 		/* 		Embedded Image		*/ 
	 		Map<String, Attachment> attachmentsMap = new Map<String, Attachment>();
	 		for (Attachment iterAttach : [select Name, Id, parentId, ContentType from Attachment where parentid=:idWikiPage]) {
	 			if (attachmentsMap.get(iterAttach.Name) == null) {
	 				attachmentsMap.put(iterAttach.Name, iterAttach);
	 			}	
	 		}
	 		
	 		String image = '[Image:';
	 		while (html.lastIndexOf(image) != -1) {
	 			List<String> temp;
	 			String img = '\\[Image:'; 
	 			temp = html.split('(?i)' + img , 2);
	 			if (temp[1].indexOf(']') != -1) {
		 			String[] temp2 = temp[1].split('\\]', 2);
		 			String contentImg = temp2[0];
		 			String imgTag = '<img';
		 			
		 			if (contentImg.indexOf(';') != -1) {
	
			 			List<String> attributesImg = contentImg.split(';');
			 			
			 			for(String item : attributesImg) {
			 				if (item.indexOf(':') != -1) {
			 					List<String> attVals = item.split(':',2);
			 					String attName = attVals[0].trim();
			 					String attVal = attVals[1].trim();
			 					if (attName == 'w') {
			 						imgTag += ' width="' + attval + '"';	
			 					}
			 					if (attName == 'a') {
			 						imgTag += ' align="' + attval + '"';	
			 					}
			 					if (attName == 'h') {
			 						imgTag += ' height="' + attval + '"';	
			 					}
			 					if (attName == 'src') {
			 						String srcImg = '';
			 						if (attVal.toLowerCase().indexOf('http') != -1 || attVal.toLowerCase().indexOf('file:') != -1) {
			 							srcImg = attVal;
			 						}
			 						else {
				 						String imageName = attVal;
							 			if (attachmentsMap.get(imageName) != null) {	
								 			Attachment AttachmentsImage = attachmentsMap.get(imageName);	
								 			String idSrc = AttachmentsImage.Id;
								 			srcImg = 'https://na1.salesforce.com/servlet/servlet.FileDownload?file=' + idSrc;
							 			}
			 						}
			 						imgTag += ' src="' + srcImg + '"';	
			 					}
			 				}
			 			}
		 			}
		 			else {
		 				if (contentImg.indexOf(':') != -1) {
			 				List<String> attVals = contentImg.split(':',2);
		 					String attName = attVals[0].trim();
		 					String attVal = attVals[1].trim();
		 					if (attName == 'src') {
		 						String srcImg = '';
		 						if (attVal.toLowerCase().indexOf('http') != -1 || attVal.toLowerCase().indexOf('file:') != -1) {
		 							srcImg = attVal;
		 						}
		 						else {
			 						String imageName = attVal;
						 			if (attachmentsMap.get(imageName) != null ) {	
								 		Attachment AttachmentsImage = attachmentsMap.get(imageName);
							 			String idSrc = AttachmentsImage.Id;
							 			srcImg = 'https://na1.salesforce.com/servlet/servlet.FileDownload?file=' + idSrc;
						 			}
		 						}
		 						imgTag += ' src="' + srcImg + '"';	
		 					}
		 				}
		 			}
		 			
		 			imgTag += '/>';
		 			html = temp[0] + imgTag + temp2[1];
	 			}
	 			else {
	 				html = temp[0] + '<img title="Malformed Image" alt="Malformed Image" />' + temp[1];
	 			}
	 		}
	 	
	 		
	 		/* ------------------------ */
	 		/* 		Embedded File		*/ 
	 		String fileS = '[File:';
	 		while (html.lastIndexOf(fileS) != -1) {
	 			List<String> temp;
	 			String file = '\\[File:'; 
	 			temp = html.split('(?i)' + file , 2);
	 			if (temp[1].indexOf(']') != -1) {
		 			String[] temp2 = temp[1].split('\\]', 2);
		 			
		 			String fileName = temp2[0].trim();
		 			String href = '';
		 			String fileType = '';
		 			if (attachmentsMap.get(fileName) != null) {	
			 			Attachment AttachmentsImage = attachmentsMap.get(fileName);	
			 			String idHref = AttachmentsImage.Id;
			 			href = 'https://na1.salesforce.com/servlet/servlet.FileDownload?file=' + idHref;
			 			
			            String ContentType2 = AttachmentsImage.ContentType;
			            String image2 = '';
			            if (ContentType2 == null || ContentType2 == '') {
			            	// EXTENSION WAY
			            	Integer extPos2 = AttachmentsImage.Name.lastIndexOf('.') + 1;
			            	String extension2 = AttachmentsImage.Name.substring(extPos2);	
			            	Map<String, String> typesExt2 = new Map<String, String>{'rar' => 'rar.gif', 'xls' => 'xls.gif', 'ppt' => 'ppt.gif', 'avi' => 'video.gif', 'mpeg' => 'video.gif', 'flv' => 'video.gif','mpg' => 'video.gif', 'mp3' => 'audio.gif' , 'wav' => 'audio.gif'};	
			           		if(typesExt2.containsKey(extension2)) {
			           			image2 = typesExt2.get(extension2);
			           		}
			           		else {
			           			image2 = 'generic.gif';
			           		}
			            }
			            else {
			           		// MIME TYPE WAY
			           		Map<String, String> typesMime2 = new Map<String, String>{'image/jpeg' => 'images.gif', 'image/png' => 'images.gif', 'image/gif' => 'images.gif', 'image/bmp' => 'images.gif', 'application/pdf' => 'pdf.gif', 'text/plain' => 'txt.gif','application/msword' => 'doc.gif', 'application/x-zip-compressed' => 'zip.gif'};	
			           		if(typesMime2.containsKey(ContentType2)) {
			           			image2 = typesMime2.get(ContentType2);
			           		}
			           		else {
			           			image2 = 'generic.gif';
			           		}
			            }	 			
			 			
			 			fileType = '<img style="vertical-align:bottom;" src="https://na1.salesforce.com/resource/1204814978000/FileTypeIcons/' + image2 + '"/>';
		 			}
		 			else {
		 				href = '';
		 				fileType = '';
		 				fileName = '';
		 			}
		 			html = temp[0] + '<a href="';
		 			html += href + '">' + fileName + '</a>';
			 		html += temp2[1];
	 			}
	 			else {
	 				html = temp[0] + '<a href="javascript:;">Malformed Link</a>' + temp[1];
	 			}
	 		}
	 		
	 		 		
	 		/* ------------------------ */
	 		/* 		Internal Link 		*/  		
	 		
	 		
	 		String intLink = '[[';
	 		String htmlLinks = html;
	 		
	 		Map<String, WikiPage__c> wikiMap = new Map<String, WikiPage__c>();
	 		List<String> wikiNamesList = new List<String>();
	 		List<String> teamNamesList = new List<String>();
	 		
	 		while (htmlLinks.lastIndexOf(intLink) != -1) {		
	 			List<String> temp;
	 			String intL = '\\[\\[';
	 			temp = htmlLinks.split(intL , 2);
	 			if (temp[1].indexOf(']]') != -1) {
	 				String[] temp2 = temp[1].split('\\]\\]', 2);
		 			String nameWiki = '';
		 			String nameTeam = '';
		 			String linkContent = '';
		 			linkContent = temp2[0];
			 		
			 		if (linkContent.indexOf(':') != -1) {
			 			List<String> linkParts = new List<String>();
			 			linkParts = linkContent.split(':',2);
			 			nameWiki = linkParts[1].trim();
			 			nameTeam = linkParts[0].trim();
			 		}
			 		else {
			 			nameWiki = linkContent.trim();
			 		}
			 		
			 		if (nameWiki != '') {
				 		if (nameTeam != '') {
				 			teamNamesList.add(nameTeam);
				 		}
				 		else {
				 			teamNamesList.add(wikiPageBody.Wiki__r.Name);	
				 		}
				 		wikiNamesList.add(nameWiki);
				 		
				 		htmlLinks = temp[0] + temp2[1];	
				 		
			 		}
			 		else {
			 			htmlLinks = temp[0] + temp2[1];	
			 		}
	 			}
	 			else {
	 				htmlLinks = temp[0] + temp[1];
	 			}
	 		}
	 		
	 		for (WikiPage__c iterWP : [select id, Name, Wiki__c, Wiki__r.Name from WikiPage__c where Name in:wikiNamesList and Wiki__r.Name in:teamNamesList]) {
	 			wikiMap.put(iterWP.Wiki__r.Name + ':' + iterWP.Name, iterWP);	
	 		}
	 		
	 		while (html.lastIndexOf(intLink) != -1) {		
	 			List<String> temp;
	 			String intL = '\\[\\[';
	 			temp = html.split(intL , 2);
	 			if (temp[1].indexOf(']]') != -1) {
	 				String[] temp2 = temp[1].split('\\]\\]', 2);
		 			String nameWiki = '';
		 			String nameTeam = '';
		 			String linkContent = '';
		 			linkContent = temp2[0];
			 		
			 		if (linkContent.indexOf(':') != -1) {
			 			List<String> linkParts = new List<String>();
			 			linkParts = linkContent.split(':',2);
			 			nameWiki = linkParts[1].trim();
			 			nameTeam = linkParts[0].trim();
			 		}
			 		else {
			 			nameWiki = linkContent.trim();
			 			nameTeam = wikiPageBody.Wiki__r.Name;
			 		}
			 		
			 		if (nameWiki != '' && nameTeam != '') {
				 		WikiPage__c wiki;
				 		if (wikiMap.get(nameTeam + ':' + nameWiki) != null) {
				 			wiki = wikiMap.get(nameTeam + ':' + nameWiki); 	
				 		}
				 		if (wiki != null) {
					 		String id;
					 		id = wiki.Id;
								 		
							html = temp[0] + '<a href=\"/apex/WikiPage?idWP=' + id + '\">' + nameWiki + '</a>' + temp2[1];	 		
					 	}
					 	else {
					 		html = temp[0] + '<a href="javascript:;" onclick="viewOverlayForm(\'' + idWikiPage + '\',\'AddChildForm\');newChildPreField(\'' + nameWiki + '\')">Create Page ' + nameWiki + '</a>' + temp2[1];
					 	}
			 		}
			 		else {
			 			html = temp[0] + temp2[1];	
			 		}
	 			}
	 			else {
	 				html = temp[0] + temp[1];
	 			}
	 		}				 		
	 		
	 		
	 		html = html.replaceAll('  ','&nbsp;');
	  		
	  		
	  		/* ------------------------ */
	 		/* 	   Table of Content 	*/ 	
	 		String tocSintax = '%TOC%';
	 		String tocCentinel = '%%%%';
	 		String tocCentinelStart = '%%%%<a name="';
	 		String tocCentinelEnd = '"></a>%%%%';  
	 		while (html.indexOf(tocCentinel) != -1) {
		 		List<String> tempToc1;
		 		List<String> tempToc2;
		 		
		 		tempToc1 = html.split('(?i)' + tocCentinelStart, 2);
		 		html = html.replaceFirst('(?i)' + tocCentinel,'');
		 		
		 		tempToc2 = tempToc1[1].split('(?i)' + tocCentinelEnd, 2);
		 		html = html.replaceFirst('(?i)' + tocCentinel,'');
				
				Integer a = tempToc1[0].length() - 1;
				String part1 = tempToc1[0].substring(0,a);
				String numH = tempToc1[0].substring(a,a + 1);
		 		html = part1 + '<a name="'+ tempToc2[0] + '"></a>' + tempToc2[1]; 
		 		
		 		toc += '<a  href="#' + tempToc2[0] + '" style="padding-left:' + numH + '0px;padding-bottom:5px;">' + tempToc2[0] + '</a><br>\n';
	
	 		}	
	 		toc = '<table style="padding:20px;background-color:#FFFFFF;border:1px solid #AAAAAA;"><tr><td>' + toc + '</td></tr></table>';
	 		html = html.replaceAll(tocSintax, toc);	
	 		
	 		/* ------------------------ */
	 		/* 		Code (No parsed) 	*/
	 		Integer countCode = 0;
	 		String codeText;
	 		codeText = html;
	 		while (codeText.lastIndexOf(replacementCode) != -1) {
		 		codeText = codeText.replaceFirst(replacementCode,'<table style="border: 1px solid rgb(175, 175, 175); padding: 20px; background-color: rgb(250, 250, 250);"><tbody><tr><td>' + noparsedText.get(countCode) + '<span></span></td></tr></tbody></table>');
	 			countCode++;
	 		} 		
	 		html = codeText;
	 		
	 		
	 		/* ------------------------ */
	 		/* 		  Emoticons 		*/		
	 		
	 		String happy = ':\\)';
	 		String veryHappy = ':D';
	 		String sad = ':\\(';
			String crying = ':\'\\(';
			String wink = ';\\)';
			String evil = '\\(6\\)';
			String idea = '\\(I\\)';
			String thumbsUp = '\\(Y\\)';
			String thumbsDown = '\\(N\\)';
			String heart = '\\(L\\)';
			String brokenHeart = '\\(U\\)';
			String kiss = '\\(K\\)';
			String email = '\\(E\\)';
			String glasses = '\\(H\\)';
			String angry = ':@';
			String tongue = ':P';
	 		String shame = ':\\$';
	 		String oh = ':O'; 		
	 		String confused = ':S';
	 		String angel = '\\(A\\)';
	
	 		html = html.replaceAll(happy , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/regular_smile.gif\'>');
			html = html.replaceAll(veryHappy , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/teeth_smile.gif\'>');
			html = html.replaceAll(sad , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/sad_smile.gif\'>');
			html = html.replaceAll(crying , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/cry_smile.gif\'>');
			html = html.replaceAll(wink , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/wink_smile.gif\'>');
			html = html.replaceAll(evil , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/devil_smile.gif\'>');
			html = html.replaceAll(idea , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/lightbulb.gif\'>');
			html = html.replaceAll(thumbsUp , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/thumbs_up.gif\'>');
			html = html.replaceAll(thumbsDown , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/thumbs_down.gif\'>');
			html = html.replaceAll(heart , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/heart.gif\'>');
			html = html.replaceAll(brokenHeart , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/broken_heart.gif\'>');
			html = html.replaceAll(kiss , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/kiss.gif\'>');
			html = html.replaceAll(email , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/envelope.gif\'>');
			html = html.replaceAll(glasses , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/shades_smile.gif\'>');
			html = html.replaceAll(angry , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/angry_smile.gif\'>');
			html = html.replaceAll(tongue , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/tounge_smile.gif\'>');
			html = html.replaceAll(shame , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/embaressed_smile.gif\'>');
			html = html.replaceAll(oh , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/omg_smile.gif\'>');
			html = html.replaceAll(confused , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/confused_smile.gif\'>');
			html = html.replaceAll(angel , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/angel_smile.gif\'>'); 		
	
	 		/**/
		}
		else {
			html = '';
		}
 		
 	}   
 	
 	/**
	*@return String
	*/
 	public String getHtml () {
 		return html;	
 	}
 	
 	/**
	*@return String
	*/
 	public String getHtml2 () {
 		String html2;
 		html2 = html;
 		html2 = html2.replaceAll('&nbsp;','  ');
 		html2 = html2.replaceAll('<br>','\n');
 		html2 = html2.replaceAll('\"','"');
		html = html.replaceAll('&gt;','>');
		html = html.replaceAll('&lt;','<');
 		return html2;	
 	}


   	/* ---------------------------- */
   	/*   CHILDREN OF A WIKI PAGE	*/
   	/* ---------------------------- */
   
	/**
	*@return List<WikiPage__c>
	*/   
   	public List<WikiPage__c> getChilds () {
   		
   		List<WikiPage__c> childs = new List<WikiPage__c>();
	   	childs = [SELECT Id, Name, ShortDescription__c, Body__c, Parent__c FROM WikiPage__c WHERE Parent__c = :idWikiPage order by Name];
	
   		return childs;
   	} 
   	 	
   	/**
	*@return Integer
	*/   	
   	public Integer getChildsCount () {
   		Integer count;
		count = [select count() from WikiPage__c where Parent__c = :idWikiPage];
   		return count;
   	}   	

   	/* ---------------------------- */
   	/*   	 EDIT WIKI PAGE			*/
   	/* ---------------------------- */
   	
	public WikiPage__c editWP;
	WikiVersions__c editWV;
	
	
   	/* ---------------------------- */
   	/*   	   NEW WIKI PAGE		*/
   	/* ---------------------------- */	
	WikiPage__c newWP = new WikiPage__c();
	WikiVersions__c newWV = new WikiVersions__c();
	
	public Boolean newPage = false;
	
	/**
	*@return Boolean
	*/  
	public Boolean getNewPage () {
		return this.newPage;
	}
	 
	/**
	* Sets the newPage status to false
	*/ 
	public void cancelNew () {
		newPage = false;
	}
	
	/**
	* Sets the newPage status to true
	*/ 
	public void newWiki () {
		newPage = true;
		newWP = null;	
		newWV = null;
	}

	/**
	*@param WikiPage__c
	*/  
	public void setnewWP (WikiPage__c newWP) {
		this.newWP = newWP;
	}

	/**
	*@param WikiVersions__c
	*/ 
	public void setnewWV (WikiVersions__c newWV) {
		this.newWV = newWV;
	}		
	
	/**
	* Saves the new wiki page and sets ints newPage status to false.
	*/ 
	public void SaveNew () {
		newWP.Parent__c = idWikiPage;
		newWP.Wiki__c = idWikiSite; 
		newWP.Body__c = '=== Congratulations! === \n You created a new wiki page for your team. Begin by clicking the "Edit" button above to modify this page.';
		insert newWP;	
		newWV = new WikiVersions__c();
		newWV.revisionCount__c = 1;
		newWV.WikiPageId__c = newWP.Id;
		newWV.Name = newWP.Name;
		newWV.Body__c = '=== Congratulations! === \n You created a new wiki page for your team. Begin by clicking the "Edit" button above to modify this page.';
		insert newWV;
		
		
		newPage = false;	
	}   	

	/**
	*@return WikiPage__c
	*/
	public WikiPage__c getnewWP () {
		if (newWP == null) {
			newWP = new WikiPage__c();
		}		
		return newWP;	
	}    	   	

	/**
	*@return WikiVersions__c
	*/
	public WikiVersions__c getnewWV () {
		if (newWV == null) {
			newWV = new WikiVersions__c();
		}		
		return newWV;	
	}
	
   	
	/**
	* Class Info
	*/
	public class Info {
        
        String name;
        String createdBy;
        String createdById;
        String createdDate;
        String lastModifiedBy;
        String lastModifiedDate;
        String shortDescription;
        String lastModifiedById;
        
        /**
        *@return String
        */
        public String getName() {
                return name;
        }

		/**
        *@param String
        */
        public void setName(String name) {
                if (name.length() > 60) {
	            	this.name = name.substring(0,58) + '..';
	            }
	            else {
	            	this.name = name;
	            }
        }  
        
        /**
        *@return String
        */
        public String getShortDescription() {
                return shortDescription;
        }

		/**
        *@param String
        */
        public void setShortDescription (String shortDescription) {
                this.shortDescription = shortDescription;
        }
        
        /**
        *@return String
        */
        public String getCreatedBy() {
                return createdBy;
        }

		/**
        *@param Id
        */
        public void setCreatedBy(Id id) {
                User user;
                user = [select Name from User where id = :id];
                this.createdBy = user.Name;
        }  
        
        /**
        *@return String
        */
        public String getCreatedById() {
                return createdById;
        }

		/**
        *@param	Id
        */
        public void setCreatedById(Id id) {
                this.createdById = id;
        }
        
        /**
        *@return String
        */
        public String getLastModifiedBy() {
                return lastModifiedBy;
        }

		/**
        *@param Id
        */
        public void setLastModifiedBy (Id id) {
                User user;
                user = [select Name from User where id = :id];
                this.lastModifiedBy = user.Name;
        } 
        
        /**
        *@param Id
        */
        public void setLastModifiedById (Id id) {
        	this.lastModifiedById = id;	
        }	
		
		/**
        *@return String
        */
		public String getLastModifiedById () {
			return lastModifiedById;	
		}
		
		/**
        *@return String
        */
        public String getCreatedDate() {
                return createdDate;
        }

		/**
        *@param Datetime
        */
        public void setCreatedDate(Datetime createdDate) {
                this.createdDate = createdDate.format();
        } 
        
        /**
        *@return String
        */
        public String getLastModifiedDate() {
                return lastModifiedDate;
        }

		/**
        *@param Datetime
        */
        public void setLastModifiedDate(Datetime lastModifiedDate) {
                this.lastModifiedDate = lastModifiedDate.format();
        }                
                                        
	} // end of the class	
   	

    /**
    * Stores the wike page info in infoWP.
    */  	
   	public void infoGen () {
   		
   		WikiPage__c wiki;
		String idInfo = idWikiPage;	
    	if (idInfo == '0' || idInfo == null) {
    		wiki = [SELECT Name, ShortDescription__c, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate  From WikiPage__c WHERE Wiki__c =: idWikiSite  limit 1];	
    	}
    	else {
    		wiki = [SELECT Name, ShortDescription__c, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate From WikiPage__c WHERE id = : idInfo ];
    	}
		
		infoWP.setName(wiki.Name);
		infoWP.setCreatedBy(wiki.CreatedById);
		infoWP.setCreatedById(wiki.CreatedById);
		infoWP.setCreatedDate(wiki.CreatedDate);
		infoWP.setLastModifiedById(wiki.LastModifiedById);
		infoWP.setLastModifiedBy(wiki.LastModifiedById);
		infoWP.setLastModifiedDate(wiki.LastModifiedDate);
		infoWP.setShortDescription(wiki.ShortDescription__c);  
			
		
	}    		
   		
   	/**
	*@return Info
	*/
 	public Info getInfoWiki () {
 		return infoWP;
 	}


   	/* ---------------------------- */
   	/*   	  ATTACH WIKI PAGE		*/
   	/* ---------------------------- */	  	  
	
	public Attachment wikiAttach = new Attachment();
	
	/**
	*@param Attachment
	*/
	public void setWikiPage (Attachment attach) {
		this.wikiAttach = attach;
	}
	 
	/**
	*@return Attachment
	*/
	public Attachment getWikiAttach () {     
		return wikiAttach;
	}
	
	/**
	*@return PageReference
	*/
	public PageReference saveWikiAttach () {
		wikiAttach.ParentId = idWikiPage;
		insert wikiAttach;		
		PageReference pageRef = Page.WikiPage;
		pageRef.getParameters().put('idWP', idWikiPage);
		pageRef.setRedirect(true);
		return pageRef;
	}
	
	/**
	* Class AttachmentInfo
	*/
	public class AttachmentInfo {
        
        String name;
        String attachImage;
		String id;
        String lastModifiedDate;
        String lastModifiedBy;
        String createdDate;
        String lastModifiedById;
        
        /**
        *@return String
        */
        public String getCreatedDate () {
        	return createdDate;
        }
        
        /**
        *@param String
        */
        public void setCreatedDate (String createdDate) {
        	this.createdDate = createdDate;
        }
        
        /**
        *@return String
        */
        public String getId () {
        	return id;
        }
        
        /**
        *@param String
        */
        public void setId (String id) {
        	this.id = id;
        }
        
        /**
        *@return String
        */
        public String getLastModifiedDate () {
        	return lastModifiedDate;
        }
        
        /**
        *@param String
        */
        public void setLastModifiedDate (String lastModifiedDate) {
        	this.lastModifiedDate = lastModifiedDate;
        }
        
        /**
        *@return String
        */
        public String getName() {
                return name;
        }

		/**
        *@param String
        */
        public void setName(String name) {
                this.name = name;
        }  
        
        /**
        *@return String
        */
        public String getAttachImage() {
                return attachImage;
        }

		/**
        *@param String
        */
        public void setAttachImage (String attachImage) {
                this.attachImage = attachImage;
        } 
        
        /**
        *@return String
        */
        public String getLastModifiedBy () {
        	return lastModifiedBy;
        }
        
        /**
        *@param String
        */
        public void setLastModifiedBy (String lastModifiedBy) {
        	this.lastModifiedBy = lastModifiedBy;
        }
        
        /**
        *@return String
        */
        public String getLastModifiedById () {
        	return lastModifiedById;
        }
        
        /**
        *@param String
        */
        public void setLastModifiedById (String lastModifiedById) {
        	this.lastModifiedById = lastModifiedById;
        }
                                        
	}
	   
	/**
	*@return List<AttachmentInfo>
	*/
    public List<AttachmentInfo> getAttachments() {
    	
    	List<Attachment> Attachments = [select name, id, parentid, ContentType, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name, CreatedDate from Attachment where parentid=:idWikiPage order by name];		
		List<AttachmentInfo> infos = new List<AttachmentInfo>();

		for (Attachment item: Attachments){	
            AttachmentInfo info = new AttachmentInfo();
            info.setId(item.Id);
            info.setName(item.Name);
            info.setCreatedDate(item.CreatedDate.format());
            info.setLastModifiedDate(item.LastModifiedDate.format());
            info.setLastModifiedBy(item.LastModifiedBy.Name);
            info.setLastModifiedById(item.LastModifiedBy.Id);
            
            String ContentType = item.ContentType;
            String image = '';
            
       		if (ContentType == null || ContentType == '') {
            	// Using extension
            	Integer extPos = item.Name.lastIndexOf('.') + 1;
            	String extension = item.Name.substring(extPos);
            	// containsKey does a case sensitive comparison
            	extension = extension.toLowerCase();
            	Map<String, String> typesExt = new Map<String, String>{
           			'png' => 'images.gif',
           			'jpg' => 'images.gif',
           			'gif' => 'images.gif', 
           			'rar' => 'rar.gif', 
           			'xls' => 'xls.gif', 
           			'ppt' => 'ppt.gif', 
           			'avi' => 'video.gif', 
           			'mpg' => 'video.gif', 
           			'mpeg' => 'video.gif', 
           			'flv' => 'video.gif', 
           			'mp3' => 'audio.gif', 
           			'doc' => 'doc.gif'
       			};
           		if(typesExt.containsKey(extension)) {
           			image = typesExt.get(extension);
           		}
           		else {
           			image = 'generic.gif';
           		}
            }
            else {
           		// Using mime type
           		Map<String, String> typesMime = new Map<String, String>{
           			'image/jpeg' => 'images.gif', 
           			'image/pjpeg' => 'images.gif', 
           			'image/png' => 'images.gif', 
           			'image/x-png' => 'images.gif', 
           			'image/gif' => 'images.gif', 
           			'image/bmp' => 'images.gif', 
           			'text/plain' => 'txt.gif', 
           			'application/pdf' => 'pdf.gif', 
           			'application/msword' => 'doc.gif', 
           			'application/x-zip-compressed' => 'zip.gif', 
           			'audio/wav' => 'audio.gif', 
           			'audio/mpeg' => 'audio.gif', 
           			'video/mpeg' => 'video.gif', 
           			'video/avi' => 'video.gif'
       			};	
           		if(typesMime.containsKey(ContentType)) {
           			image = typesMime.get(ContentType);
           		}
           		else {
           			image = 'generic.gif';
           		}
            }
            
            info.setAttachImage(image);
            infos.add(info);
        }	
		return infos;   	    									
    }     
    
    /**
	*@return Integer
	*/
    public Integer getAttachCount () {
    	return [select count() from attachment where parentid=:idWikiPage];
    }
    
    public void refreshAttachs () {
    	
    }

   	/* ---------------------------- */
   	/*   	  DELETE ATTACH			*/
   	/* ---------------------------- */  
   	
   	public void DeleteAttach () { 
   		String idAttach = System.currentPageReference().getParameters().get('idAttach');
   		Attachment delAttach;
   		delAttach = [select Id, Name from Attachment where id =:idAttach ];
   		delete delAttach; 
   	}
 
   	/* ---------------------------- */
   	/*   	  BREADCRUMBING			*/
   	/* ---------------------------- */ 
	  	
	/**
	*@return String
	*/
	public String getBreadCrumbing () {
	   	WikiPage__c wikiBC;
	   	String breadCrumbing = '';
	   	String parentBC = null;
		Integer crumbingLength = 1;
		Integer crumbingMaxLength = 2;
		
		if (idWikiPage == null) {
			idWikiPage = getWikiHome();
		}
   		wikiBC = [SELECT Id, Name, ShortDescription__c, Body__c, Parent__c, LastModifiedDate FROM WikiPage__c WHERE id = : idWikiPage ];
   		
   		parentBC = wikiBC.Parent__c;
	   	while (parentBC != null) {
	   		
	   		wikiBC = [select Name, Id, Parent__c from WikiPage__c where id =:parentBC];
	   		parentBC = wikiBC.Parent__c;
	   		
	   		String trunkName;
	   		if (wikiBC.Name.length() > 25) {
	   			trunkName = wikiBC.Name.substring(0,23) + '..';
	   		}
	   		else {
	   			trunkName = wikiBC.Name; 	
	   		}
	   		
	   		if (crumbingLength < crumbingMaxLength) {
	   			breadCrumbing = '<a href=\"/apex/WikiPage?idWP=' + wikiBC.Id + '\">' + trunkName + '</a> >'; 
	   		}
	   		else {
	   			if (parentBC == null) {
	   				breadCrumbing = '<a href=\"/apex/WikiPage?idWP=' + wikiBC.Id + '\">' + trunkName + '</a> >'; 
	   			}
	   			else {
	   				if (crumbingLength == crumbingMaxLength) {
	   					breadCrumbing = ' .. > ' + breadCrumbing;
	   				}
	   			}
	   		}
	   		crumbingLength++;
	   	} 
	   	return breadCrumbing;
	}
 
   	/* ---------------------------- */
   	/*   	OUTGOING / INCOMING		*/
   	/* ---------------------------- */  
   	
   	/**
	*@return List<WikiLink__c>
	*/
    public List<WikiLink__c> getOutgoing() {		
		return [select ToLink__r.ShortDescription__c, ToLink__r.Name, ToLink__r.Id from WikiLink__c where FromLink__c =:idWikiPage order by Name];   	    									
    }    	

	/**
	*@return Integer
	*/
    public Integer getCntOutgoing() {		
		return [select count() from WikiLink__c where FromLink__c =:idWikiPage];   	    									
    } 
       	
    /**
	*@return List<WikiLink__c>
	*/
    public List<WikiLink__c> getIncoming() {		
		return [select FromLink__r.ShortDescription__c, FromLink__r.Name, FromLink__r.Id from WikiLink__c where ToLink__c =:idWikiPage order by Name];   	    									
    }  

	/**
	*@return Integer
	*/
    public Integer getCntIncoming() {		
		return [select count() from WikiLink__c where ToLink__c =:idWikiPage];   	    									
    }
    
   	/* ---------------------------- */
   	/*   	RECENTLY UPDATED		*/
   	/* ---------------------------- */
   	
   	/**
	*@return List<WikiPage__c>
	*/
   	public List<WikiPage__c> getRecentlyUpdated () {
   		return	[ SELECT Id, Name, ShortDescription__c, Parent__c, LastModifiedDate FROM WikiPage__c WHERE Wiki__c =: idWikiSite ORDER BY LastModifiedDate desc limit 5];
   	}
   	    
   	/* ---------------------------- */
   	/*   	     TAG CLOUD			*/
   	/* ---------------------------- */
   	public Integer linksNum = 0;
   	
   	/**
	* Class Links
	*/
 	public class Links {
 		String linkName;
 		Integer linkCount;
 		String linkId;
 		String linkClass;
 		
 		/**
        *@return String
        */
        public String getLinkName () {
        	return linkName;
        }
        
        /**
        *@return String
        */
        public String getLinkId () {
        	return linkId;
        }
        
        /**
        *@return Integer
        */
        public Integer getLinkCount () {
        	return linkCount;
        } 
        
        /**
        *@return String
        */
        public String getLinkClass () {
        	return linkClass;
        }    
        
        /**
        *@param String
        */
        public void setLinkName (String linkName) {
        	this.linkName = linkName;
        }
        
        /**
        *@param String
        */
        public void setLinkClass (String linkClass) {
        	this.linkClass = linkClass;
        }   
        
        /**
        *@param String
        */     
        public void setLinkId (String linkId) {
        	this.linkId = linkId;
        }        
        
        /**
        *@param Integer
        */
        public void setLinkCount (Integer linkCount) {
        	this.linkCount = linkCount;
        }                              		
 	
 	}
	
	/**
	*@param List<Links>
	*@return List<WikiPage__c>
	*/
	public List<Links> upsetting (List<Links> result) {
	    Integer resultSize = result.size() - 1;
	    Integer i;
	    for (i = 0; i <= resultSize; i++) {
	        Integer alea = Integer.valueOf(String.valueOf(Math.roundToLong(Math.ceil(Math.random() * resultSize))));
	        Links tempLink;
	 		tempLink = result.get(i);
	 		result.set(i, result.get(alea));
	 		result.set(alea, tempLink); 
	    }		
		return result;
	} 
	
	/**
	*@return List<Links>
	*/
 	public List<Links> getLinkCount () {
 		
 		List<Links> popularLinks = new List<Links>();
 		
 		for (WikiPage__c item: [select Name, id, linkCount__c from WikiPage__c where Wiki__c =:idWikiSite order by Name desc limit 15]) {
 			Links link = new Links();
 			if (item.linkCount__c != 0 && item.linkCount__c != null) {
 				Integer intCount = Integer.valueOf(String.valueOf(Math.roundToLong(item.linkCount__c)));
	 			if (intCount < 2) { link.setLinkClass('tag1');}
	 			if (intCount == 2 || intCount == 3) { link.setLinkClass('tag2');}
	 			if (intCount > 3 && intCount <= 5) { link.setLinkClass('tag3');}
	 			if (intCount > 5 && intCount <= 7) { link.setLinkClass('tag4');}
	 			if (intCount > 7 && intCount <= 10) { link.setLinkClass('tag5');}
	 			if (intCount > 10 && intCount <= 13) { link.setLinkClass('tag6');}
	 			if (intCount > 13 && intCount <= 17) { link.setLinkClass('tag7');}
	 			if (intCount > 17 && intCount <= 21) { link.setLinkClass('tag8');}
	 			if (intCount > 21 && intCount <= 25) { link.setLinkClass('tag9');}
	 			if (intCount > 25) { link.setLinkClass('tag10');}
	 			
	 			link.setLinkCount(intCount);
	 			link.setLinkName(item.Name);
	 			link.setLinkId(item.Id);
	 			popularLinks.add(link);
 			}		
 		}	
 		linksNum = popularLinks.size(); 
 		return upsetting(popularLinks);	
 	}  
 	
 	/**
	*@return Integer
	*/
 	public Integer getLinksNum () {
 		return linksNum;
 	}	   	
   	/* ---------------------------- */
   	/*   	   MY FAVOURITES		*/
   	/* ---------------------------- */
   	
   	/**
	*@return List<FavoriteWikis__c>
	*/
   	public List<FavoriteWikis__c> getFavorite () {
   		return	[ SELECT WikiPage__r.Name, WikiPage__r.Id FROM FavoriteWikis__c WHERE User__c = :UserInfo.getUserId() and WikiPage__r.Wiki__c =:idWikiSite order by WikiPage__r.Name];
   	}   	
   	
   	
   	/**
	* Class FavoriteSharing
	*/
   	public without sharing class FavoriteSharing {
   		
   		/**
		*@param String
		*@param String
		*/
   		public void setFavorites (String idWikiPage, String userId) {
   			Integer countFav = [ SELECT count() FROM FavoriteWikis__c WHERE User__c = :userId AND WikiPage__r.Id =: idWikiPage];	
	   		if (countFav == 0 ) {
	   			FavoriteWikis__c  newFav = new FavoriteWikis__c();
	   			WikiPage__c favWiki = [Select Name, Wiki__c from WikiPage__c where Id = :idWikiPage];
	   			newFav.User__c = userId;
	   			newFav.Wiki__c = favWiki.Wiki__c;
	   			newFav.WikiPage__c = idWikiPage;
	   			newFav.Name = favWiki.Name;
	   			insert newFav;
	   		}
	   		else {
	   			FavoriteWikis__c favWiki;
				favWiki = [ SELECT WikiPage__r.Name, WikiPage__r.Id FROM FavoriteWikis__c WHERE User__c = :userId AND WikiPage__r.Id =: idWikiPage];  
				delete favWiki; 			
	   		}
	   				
   		}
   		
   	}
   	 

   	public void save_del_fav () {
   		FavoriteSharing favClass = new FavoriteSharing();
   		favClass.setFavorites(idWikiPage, UserInfo.getUserId());
   	} 
   	
   	/**
	*@return Boolean
	*/
   	public Boolean getIsFav () {
   		Integer countFav = [ SELECT count() FROM FavoriteWikis__c WHERE User__c = :UserInfo.getUserId() AND WikiPage__r.Id =: idWikiPage];
   		if (countFav == 0 ) {
   			return false;
   		}
   		else {
   			return true;
   		}
   	}  
   	
   	/**
	*@return Integer
	*/
   	public Integer getCntFav () {
   		return [select count() from FavoriteWikis__c where User__c = :UserInfo.getUserId() and WikiPage__r.Wiki__c =:idWikiSite];
   	} 
   	
   	
   	/**
	* Class RecentlyView
	*/
	public class RecentlyView {
		String wikiId;
		String wikiName;
		String parentName;
		Boolean belong;
		
		/**
		*@param String
		*/
		public void setWikiId (String wikiId) {
			this.wikiId = wikiId;
		}
		
		/**
		*@param String
		*/
		public void setWikiName (String wikiName) {
			this.wikiName = wikiName;
		}
		
		/**
		*@param String
		*/
		public void setParentName (String parentName) {
			this.parentName = parentName;
		}
		
		/**
		*@param Boolean
		*/
		public void setBelong (Boolean belong) {
	   		this.belong = belong;			
		}
		
		/**
		*@return String
		*/
		public String getWikiId () {
			return wikiId;
		}
		
		/**
		*@return String
		*/
		public String getWikiName () {
			return wikiName;
		}
		
		/**
		*@return String
		*/
		public String getParentName () {
			return parentName;
		}
		
		/**
		*@return Boolean
		*/
		public Boolean getBelong () {
			return belong;
		}	
		
	}
	 
	/**
	* Returns a list of the recently viewed wikies.
	*@return List<RecentlyView>
	*/
   	public List<RecentlyView> getRecentlyView () {
   		List<RecentlyView> views = new List<RecentlyView>();
   		for (WikiRecentlyViewed__c item :	[ SELECT WikiPage__r.Wiki__r.Id, WikiPage__r.Wiki__r.Name , WikiPage__r.Name, WikiPage__r.Id FROM WikiRecentlyViewed__c WHERE User__c = :UserInfo.getUserId()  ORDER BY LastModifiedDate desc limit :maxView]) { //and WikiId__r.WikiSpace__c =:idWikiSite
   			RecentlyView view = new RecentlyView();
   			view.setWikiId(item.WikiPage__r.Id);
   			view.setWikiName(item.WikiPage__r.Name);
   			view.setParentName(item.WikiPage__r.Wiki__r.Name);
   			if (item.WikiPage__r.Wiki__r.Id == idWikiSite) {
   				view.setBelong(true);
   			}
   			else {
   				view.setBelong(false);
   			}
   			views.add(view);
   		} 
   		return views;  	
   	}    	
   	
   	
   	/**
	*@return Integer
	*/
   	public Integer getCntViews () {
   		return	[ SELECT count() FROM WikiRecentlyViewed__c WHERE User__c = :UserInfo.getUserId()];
   	}
   	
   	
   	/* ---------------------------- */
   	/*   		 COMMENTS			*/
   	/* ---------------------------- */
	public Boolean addComment = false;
   	public String commentName = '';
   	public String commentBody = '';
	
	
	/**
	* Class Comments
	*/
   	public class Comments {
   		String commentDate;
   		String comment;
   		String commentName;
   		String commentBy;
   		String commentPicture;
   		
   		/**
		*@param String
		*/
   		public void setCommentName (String commentName) {
   			this.commentName = commentName;
   		}
   		
   		/**
		*@param String
		*/
	   	public void setComment (String comment) { 
	   		this.comment = comment;
	   	}
	   	
	   	/**
		*@param Datetime
		*/
	   	public void setCommentDate (Datetime commentDate) {
	   		this.commentDate = commentDate.format(); 
	   	}
	   	
	   	/**
		*@param String
		*/
	   	public void setCommentBy (String name) {
	   		this.commentBy = name;
	   	}
	   	
	   	/**
		*@return String
		*/
	   	public String getCommentName () {
	   		return commentName;
	   	}
	   	
	   	/**
		*@param PeopleProfile__c
		*/
	   	public void setCommentPicture (Wiki__c wiki) {
			String PictureId;
			
			if(wiki.PictureId__c == null || wiki.PictureId__c == ''){
				PictureId = 'nopicture';
			}else{
				PictureId = wiki.PictureId__c;
			}
   			this.commentPicture = PictureId ;
   		}
   		
   		/**
		*@return String
		*/
	   	public String getCommentPicture () {
	   		return commentPicture;
	   	}
	   	
	   	/**
		*@return String
		*/
	   	public String getCommentDate () {
	   		return commentDate;
	   	}
	   	
	   	/**
		*@return String
		*/
	   	public String getCommentBy () {
	   		return commentBy;
	   	}
	   	
	   	/**
		*@return String
		*/
	   	public String getComment () {
	   		return comment;
	   	}
	   	
	   	/**
		*@return String
		*/
		public String getShowShortCommentBy(){
			Integer charDisplayed = 20;
	        		
			if(commentBy.length() > charDisplayed){
	           return commentBy.substring(0,charDisplayed-1) + '...';            	
	        }else{
	        	return commentBy;
	        }
		}
   	}
   	   	
   	/**
	*@return String
	*/
   	public String getCommentName () {
   		return commentName;
   	}
   	
   	/**
	*@param String
	*/
   	public void setCommentName (String commentName) {
   		this.commentName = commentName;
   	}
   	
   	/**
	*@return String
	*/
   	public String getCommentBody () {
   		return commentBody;
   	}
   	
   	/**
	*@param String
	*/
   	public void setCommentBody (String commentBody) {
   		this.commentBody = commentBody;
   	}   
   	
   	/**
	*@return List<Comments>
	*/
   	public List<Comments> getComments () {
   		List<Comments> commentsList = new List<Comments>();
      		
   		List<String> userComment = new List<String>(); 
   		
   		for (Comment__c item: [ SELECT Message__c, CreatedBy.Name, CreatedById, LastModifiedDate FROM Comment__c WHERE ParentWikiPage__c =:idWikiPage ORDER BY LastModifiedDate desc]){
   			userComment.add(item.CreatedById);
   		}
		List<Wiki__c> pictureId = [SELECT PictureId__c FROM Wiki__c WHERE Id =: idWikiPage limit 1];
		Integer countComment = [select count() from Comment__c WHERE ParentWikiPage__c =:idWikiPage];
   		if (countComment != 0) {
	   		for (Comment__c item: [ SELECT Message__c, CreatedBy.Name,CreatedById, LastModifiedDate FROM Comment__c WHERE ParentWikiPage__c =:idWikiPage ORDER BY LastModifiedDate desc]) {
	   			Comments itemComment = new Comments();
	   			itemComment.setCommentBy(item.CreatedBy.Name);
	   			itemComment.setComment(item.Message__c);
	   			itemComment.setCommentDate(item.LastModifiedDate);
	   			//itemComment.setCommentPicture(pictureId[0]);
	   			commentsList.add(itemComment);
	   		}	
   		}
   		return	commentsList;
   	}
   	 
   	/**
	*@return Integer
	*/   	
   	public Integer getCntComments () {
   		return	[ SELECT count() FROM Comment__c WHERE ParentWikiPage__c =: idWikiPage];
   	}  
   	  
   	/**
	*@return Boolean
	*/ 
   	public Boolean getAddComment () {
   		return addComment;	
   	}
   	 
    /**
	* Sets addComent to true
	*/ 
   	public void addCommentLink () {
   		addComment = true;
   	}
   	
   	/**
	* Saves the current comment
	*/ 
   	public void saveComment () {
   		Comment__c newComment = new Comment__c();
   		newComment.Message__c = commentBody;
   		newComment.ParentWikiPage__c = idWikiPage;
   		insert newComment;
   		commentBody = '';
   		addComment = false;
   	}
   	
   	/**
	* Cancels the current coment
	*/
   	public void cancelComment () {
   		commentBody = '';
   		addComment = false;
   	}
   	
   	/* ---------------------------- */
   	/*   		REVISIONS			*/
   	/* ---------------------------- */   	
   	
   	/**
	*@return String
	*/ 
	public String getCurrentRevision () {
   		Integer revCount;
   		Integer resultCount = [select count() from WikiVersions__c where WikiPageId__c =:idWikiPage];
	   	if (resultCount != 0) {	
	   		WikiVersions__c wikiVersion = [select Name from WikiVersions__c where WikiPageId__c =:idWikiPage order by CreatedDate desc limit 1];
	   		
	   		revCount = 1;
	   	}
	   	else {
	   		revCount = 1;
	   	} 
   		return ('Revision v' + revCount);
   		
   	}
   	
   	/* ---------------------------- */
   	/*   		DELETE PAGE			*/
   	/* ---------------------------- */  
   	
   	/**
	* Class DeleteWiki
	*/
   	public without sharing class DeleteWiki {
   		
   		/**
		*@return PageReference
		*@throws CustomException
		*/
   		public PageReference deleteWikiPage (List<WikiPage__c> wikiPageBodyList, UserPermissions userPermissions) {
   			PageReference pageRef;
   			if (userPermissions.getCanManage()) {
		   		String wikiParent = '';
		   		String idWikiSite = '';
		   		if (wikiPageBodyList.size() > 0) {
		   			if (wikiPageBodyList[0].Parent__c != null) {
		   				wikiParent = wikiPageBodyList[0].Parent__c;	
		   			}
		   			idWikiSite = wikiPageBodyList[0].Wiki__c;
		   			delete wikiPageBodyList;
		   		}
		   		if (wikiParent != '') {
		   			pageRef = Page.WikiPage;
		   			pageRef.getParameters().put('idWP', wikiParent);
		   		}
		   		else {
		   			pageRef = Page.WikiTeamOverview;
		   			pageRef.getParameters().put('tid', idWikiSite);
		   		}
	   		}
	   		else {
	   			throw new CustomException('Insufficient Privileges');		
	   		}
	   		pageRef.setRedirect(true);
			return pageRef;
   		}	
   	}
   	
   	/**
	*@return PageReference
	*/ 
   	public PageReference deletePage () {
   		DeleteWiki delW = new DeleteWiki();
   		return delW.deleteWikiPage(wikiPageBodyList,userPermissions);
   	}
   	  		  		 		
}
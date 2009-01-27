/**
*@author Yuri Alvarez @ 5-2-2008
*/
public without sharing class WikiPageEditController {
  	
  	public Info infoWP = new Info();
  	public Boolean info = false;
	public String idWikiSite;
    public String idWikiPage = System.currentPageReference().getParameters().get('id'); 
	public WikiPage__c editWP = new WikiPage__c();   
	public Replace replace = new Replace();

   	// SHARING RULES
	public UserPermissions userPermissions = new UserPermissions();
	
    /**
    * Constructor
    */
    public WikiPageEditController () {
 		constWikiPageEdit();		
 	}	
	
	/**
	* Generate user permissions
	*@param Id OwnerId
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
    
    /**
    * Function for sply refresh
    */
    public void dummyRefresh () {}

 	/**
 	* Inner class for WikiEditSharing
 	*@class
 	*/
 	public with sharing class WikiEditSharing {
 		
 		/**
 		*@return List<WikiPage__c>
 		*@param String
 		*/
 		public List<WikiPage__c> getWikiEditView (String idWikiPage) {
 			return [SELECT Id From WikiPage__c WHERE id =:idWikiPage];
 		}	
 	}
 	
 	/**
 	* Build wiki page edit enviroment
 	*@void
 	*/
 	
 	public String nameCurrentTeam;
 	public List<String> nameTeamList = new List<String>();
 	public List<String> nameWikiList = new List<String>();
 	
 	public void constWikiPageEdit () {
 		if (idWikiPage != null && idWikiPage != '') {
	 		WikiEditSharing wikiView = new WikiEditSharing();
						    
			if(wikiView.getWikiEditView(idWikiPage).size() == 0) {
				throw new CustomException('Insufficient Privileges');	
			}else {
		 		iniReplace();
		 		genEditWP();
		 		idWikiSite = editWP.Wiki__r.Id;
		 		nameCurrentTeam = editWP.Wiki__r.Name;
		 		parseHTML();
		 		infoGen();
		 		iniBody = html;	
		 		genPermissions(editWP.PageCreatedBy__c); 
		 		
		 		if(!userPermissions.getCanManage()) {
					throw new CustomException('Insufficient Privileges');	
				}
			}
 		}
 	}
    
    /**
    * Select wiki to edit
    *@void
    */
    public void genEditWP () {
    	editWP = [SELECT Name, ShortDescription__c, Body__c, Parent__c,PageCreatedBy__c, Wiki__r.Id, Wiki__c, Wiki__r.Name FROM WikiPage__c WHERE id = : idWikiPage];
    }
    
    /**
    *@param String idWiki
    */
    public void setIdWikiPage (String idWikiPage){
		this.idWikiPage = idWikiPage;
	}
    
    /**
    *@return Replace
    */
    public Replace getReplace (){
    	return replace; 
    }
 	
 	/**
    * Created By Miguel Angel Sosa 14.01.09
    *@return String
    */
    private String getMatch(String regExp,String theString) {
        // convert the parameters to lower case to campare
        regExp = regExp.toLowerCase();
        theString = theString.toLowerCase();
        // Declare variables to use
        String regExpResult;
        String tempString;
        String beforeString;
        String afterString;
        // List to save string before and string after the match 
        List<String> tempBeforeAndAfterString;
        
        if(theString.trim().split(regExp,2).size() > 1) {

            tempBeforeAndAfterString = theString.trim().split(regExp,2);

            beforeString = tempBeforeAndAfterString[0].trim().replaceAll('\\(','\\\\(');
            beforeString = beforeString.replaceAll('\\)','\\\\)');
            beforeString = beforeString.replaceAll('\\]','\\\\]');
            beforeString = beforeString.replaceAll('\\[','\\\\[');
            beforeString = beforeString.replaceAll('\\{','\\\\{');
            beforeString = beforeString.replaceAll('\\}','\\\\}');
            beforeString = beforeString.replaceAll('\\*','\\\\*');
            
            afterString = tempBeforeAndAfterString[1].trim().replaceAll('\\(','\\\\(');
            afterString = afterString.replaceAll('\\)','\\\\)');
            afterString = afterString.replaceAll('\\[','\\\\[');
            afterString = afterString.replaceAll('\\]','\\\\]');
            afterString = afterString.replaceAll('\\{','\\\\{');
            afterString = afterString.replaceAll('\\}','\\\\}');
            afterString = afterString.replaceAll('\\*','\\\\*');
            
            tempString = theString.replaceFirst(beforeString,'');
            
            tempString = tempString.trim().replaceAll(afterString.trim(),'');
            
            regExpResult = tempString.trim();
        
            return regExpResult.trim();
        } else {
            return theString.trim();
        }
    }
 	
 	private Boolean found(String regExp, String theString) {
        regExp = regExp.toLowerCase();
        //System.debug('El indice de ' + getMatch(regExp,theString) + ' dentro de ' + theString + ' es ' + theString.indexOf(getMatch(regExp,theString)));
        if(theString.trim().split(regExp,2).size() > 1) {
            return true;
        } else {
            return false;
        }
    }
    
    private String regExpression(String theString){
        theString = theString.replaceAll('\\)','\\\\)');
        theString = theString.replaceAll('\\(','\\\\(');
        theString = theString.replaceAll('\\[','\\\\[');
        theString = theString.replaceAll('\\]','\\\\]');
        theString = theString.replaceAll('\\{','\\\\{');
        theString = theString.replaceAll('\\}','\\\\}');
        theString = theString.replaceAll('\\*','\\\\*');
        return theString;
    }
 	
 	private String getSubstringByRegExp(String regExpBefore, String regExpAfter, String theString) {
        // ACA YA TENGO EL INDICE DEL COMIENZO
        Integer startIndex = (theString.indexOf(getMatch(regExpBefore,theString)) + getMatch(regExpBefore,theString).length());

        // CON EL INDICE DE COMIENZO CREO UN SUBSTRING PARA CONTINUAR
        theString = theString.substring(startIndex);
        
        // ACA YA TENGO EL INDICE DEL FINAL     
        Integer finishIndex = theString.indexOf(getMatch(regExpAfter,theString));

        // TENGO LA NUEVA CADENA Y EL INDICE FINAL CON LO CUAL PUEDO CREAR EL SUBSTRING FINAL
        if(finishIndex > 0) {
            theString = theString.substring(0,finishIndex);
        }

        return theString;
    }
 	
 	/**
 	*@param Replace
 	*/
 	public void setReplace (Replace replace) {
 		this.replace = replace;
 	}
 	
 	/**
 	* Select the original Wiki's HTML
 	*/
 	public void iniReplace () {
 		WikiPage__c wikiHTML = [SELECT Body__c FROM WikiPage__c WHERE id =:idWikiPage]; 
 		replace.setContent(wikiHTML.Body__c); 
 	}
 	
 	/**
 	*@return String id
 	*/
 	public String getIdWikiPage () {
 		return idWikiPage;
 	}
 	
 	public String iniBody;
 	
 	/**
 	* Return original Wiki's HTML
 	*@return String
 	*/
 	public String getIniBody () {
 		return iniBody;
 	}
 	
 	/**
 	* Set the Wiki's HTML
 	*@param String wikiBody
 	*/
 	public void setIniBody (String iniBody) {
 		this.iniBody = iniBody;
 	} 
 	
 	/**
 	* Inner class for Replace type
 	*@class
 	*/
	public class Replace {       
        String content; 
        
        /**
        *@return String
        */
        public String getContent() {
                return content;
        }

		/**
        *@param String content
        */
        public void setContent(String content) {
                this.content = content;
        }            
	}

	public String idLink1 = '0:j_id226';
	public String linkpart1 = 'switchOverlay(true);;A4J.AJAX.Submit(\'_viewRoot\',\'WikiHome:wikisPageBlock:formTree\',event,{\'parameters\':{\'WikiHome:wikisPageBlock:formTree:wikiTable:' + idLink1 + '\':\'WikiHome:wikisPageBlock:formTree:wikiTable:' + idLink1 + '\',\'idWP\':\'';
	public String linkpart2 = '\'} ,\'actionUrl\':\'/apex/WikiHome?javax.portlet.faces.DirectLink=true\',\'oncomplete\':function(request,event,data){switchOverlay(false);}} );return false;\" name=\"WikiHome:wikisPageBlock:formTree:wikiTable:' + idLink1 + '\" id=\"WikiHome:wikisPageBlock:formTree:wikiTable:' + idLink1 + '\" href=\"#\">';
	
 	public String html = ' ';
 	
 	/**
 	* Parse the HTML to Wiki's sintax
 	*/
 	public void parseHTML() {
 		 
    	String toc = '';
    	
    	String html;		
  		html = replace.content;
		html = html.replaceAll('\n','<br>');
 		
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
	 		}else {
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
						if (tableAttParts[0].length() != 0) 
							tableTag += tableAttParts[0].trim(); //support all attributes
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
							}else {
								List<String> captionParts = new List<String>();
								captionParts = captionText.split(tableDataExp,2);
								tableTag += '<caption ' + captionParts[0].trim() + '>' + captionParts[1] + '</caption>';	
							}
							bodyTable = captionTextParts[1];
						}else {
							if (bodyTable.trim().indexOf(tableRow) != 0) {
								bodyTable = '<br>' + bodyTable;
							}	
						}
						
						List<String> tableRows = new List<String>();
						if (bodyTable.indexOf(tableRow) != -1) {
							tableRows = bodyTable.split(tableRowExp);	
						}else {
							tableRows.add(bodyTable);
						}
						
						for (String itemRow : tableRows) {
							String iterRow = itemRow;
							List<String> rowAtt = new List<String>();
							rowAtt = iterRow.split('(?i)<br>',2);
							
							if (rowAtt.size() == 2) {
								tableTag += '<tr ';
								if (rowAtt[0] != '' && rowAtt[0] != null ) 
									tableTag += rowAtt[0].trim();

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
												if (tdAtts[0] != null) 
													tdAtt = tdAtts[0].trim();
												if (tdAtts[1] != null) 
													tdContent = tdAtts[1].trim();
													
												tableTag += tdAtt.trim();	 
											}else {
												tdContent = itemCell.trim();	
											}
										}
										tableTag += '>';
										tableTag += tdContent;
									}else {
										if (itemCell.trim().indexOf(tableData) == 0) {
											tableTag += '<td ';
											String tdContent = '';
											if (itemCell.length() > 1) {
												itemCell = itemCell.substring(1);
												if (itemCell.indexOf(tableData) != -1) {
													List<String> tdAtts = new List<String>();
													tdAtts = itemCell.split(tableDataExp, 2);
													String tdAtt = '';
													if (tdAtts[0] != null) 
														tdAtt = tdAtts[0].trim();
													if (tdAtts[1] != null) 
														tdContent = tdAtts[1].trim();
													
													tableTag += tdAtt;	 
												}else {
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
				}else {
					html = htmlParts[0] + '<table></table>' + tailHtml;	
				}
			}else {
				html = htmlParts[0] + '<table></table>' + htmlParts[1];
			}
		}	
 		
        /* ------------------------ */
        /*          HEADINGS        */

        String headingLevel = '={2,6}';
        
        while(found(headingLevel,html)) {
            String theHeadingTag = getMatch(headingLevel,html);
            String hLevel = String.valueOf(theHeadingTag.length());
            String fontSize;
            
            if(hLevel == '2') {
                fontSize = '20';    
            } else if(hLevel == '3') {
                fontSize = '18';
            } else if(hLevel == '4') {
                fontSize = '16';
            } else if(hLevel == '5') {
                fontSize = '14';
            } else if(hLevel == '6') {
                fontSize = '13';
            }
            
            String theContentHeader = getSubstringByRegExp(headingLevel,headingLevel,html).trim();
            String removeBack = '(?i)\\[[a-z]+:[a-z_0-9(), {}\\.\\-\\#]*\\]';
            String removeFront = '(?i)\\[![a-z]+\\]';
            theContentHeader = theContentHeader.replaceAll(removeBack,'');
            theContentHeader = theContentHeader.replaceAll(removeFront,'');
            html = html.replaceFirst(theHeadingTag,'%%%%<a name="' + theContentHeader + '"></a>%%%%<h' + hLevel + ' style="font-size: ' + fontSize + 'px">');
            html = html.replaceFirst(theHeadingTag,'</h' + hLevel + '><hr />'); 
        }
 		
        // Created By Miguel Angel Sosa - 13.01.09
        // Last Modified ----
        /////////////////////////////////////////////
        /*      Span tag parser     */
        
        // Expresiones de busqueda de propiedades
        String tagPropertie = '(?i)\\[[a-z]+:[a-z_0-9(), {}\\.\\-\\#]*\\]';
        String tagPropertieClose = '(?i)\\[![a-z]+\\]';

        String openerOpenTagPropertie = '[';
        String closerOpenTagPropertie = ']';

        String actualPropertie = '';
        String nameActualPropertie = '';
        String valueActualPropertie = '';

        List<String> partsActualPropertie;
        String actualPropertieTag = '';
        String closeActualPropertie = '';
        
        //Las propiedades
        String nameStylePropertie;
        String valueStylePropertie;

        Integer theCounter = 0;

        while(found(tagPropertie,html)) {
            // Obtengo la primer propiedad encontrada
            actualPropertie = html.substring(html.indexOf(openerOpenTagPropertie),(html.indexOf(closerOpenTagPropertie)+1));
            // Le quito los parentesis rectos y obtengo el nombre y el valor de la propiedad
            actualPropertieTag = actualPropertie.replaceAll('\\[','');
            actualPropertieTag = actualPropertieTag.replaceAll('\\]','');
            actualPropertieTag = actualPropertieTag.replaceAll('\\{','').replaceAll('\\}','');
            partsActualPropertie = actualPropertieTag.split(':',2);
            if(partsActualPropertie.size() > 1) {
                nameActualPropertie = partsActualPropertie[0];
                valueActualPropertie = partsActualPropertie[1];
                
                valueActualPropertie = valueActualPropertie.replaceAll('(?i)[0-9]{1,2}%','');
                valueActualPropertie = valueActualPropertie.replaceAll('(?i)none','');
                valueActualPropertie = valueActualPropertie.replaceAll('(?i)repeat','');
                valueActualPropertie = valueActualPropertie.replaceAll('(?i)scroll','');

                closeActualPropertie = '\\[!' + nameActualPropertie + '\\]';
                
                // Seteo la propiedad y el valor
                valueStylePropertie = valueActualPropertie + ';';
                if(nameActualPropertie == 'fontFamily') {
                    nameStylePropertie = 'font-family: ';
                } else if(nameActualPropertie == 'fontSize') {
                    nameStylePropertie = 'font-size: ';
                } else if(nameActualPropertie == 'fontVariant') {
                    nameStylePropertie = 'font-variant: ';
                } else if(nameActualPropertie == 'lineHeight') {
                    nameStylePropertie = 'line-height: ';
                } else if(nameActualPropertie == 'Bgcolor') {
                    nameStylePropertie = 'background-color: ';
                } else if(nameActualPropertie == 'Color') {
                    nameStylePropertie = 'color: ';
                } else {
                    nameStylePropertie = '';
                    valueStylePropertie = '';
                }
            }
            
            actualPropertie = actualPropertie.replaceFirst('\\[','\\\\[');
            actualPropertie = actualPropertie.replaceFirst('\\]','\\\\]');
            actualPropertie = actualPropertie.replaceFirst('\\(','\\\\(');
            actualPropertie = actualPropertie.replaceFirst('\\)','\\\\)');
            actualPropertie = actualPropertie.replaceFirst('\\{','\\\\{');
            actualPropertie = actualPropertie.replaceFirst('\\}','\\\\}');

                html = html.replaceFirst(actualPropertie,'<span style="' + nameStylePropertie + valueStylePropertie + ' newPropertieHere">');
                if(nameActualPropertie != '') {
                    html = html.replaceFirst(closeActualPropertie,'</span>');
                }

            theCounter++;
            //System.debug('EL contador esta en ' + theCounter);
        }
        //System.debug('Aca el HTML DEBERIA estar casi completo y es ----->' + html);

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
				}else {
					identClose = '->\\]\\]';
				}
			}else {
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
	 			}else {	 
	 				List<String> temp2;	
	 				temp2 = temp[1].split('(?i)<br>',2);	
	 				if ((temp2[1].indexOf(listSyntax) < 3) && (temp2[1].indexOf(listSyntax) != -1) ) {	
	 					temp[1] = '>' + temp[1].replaceFirst('(?i)<br>', '</li>');
	 				}else {
	 					temp[1] = '>' + temp[1].replaceFirst('(?i)<br>', '</li></ul>');
	 					last = true;
	 				}
	 			}
	 		}else {
	 			temp[1] = temp[1].replaceFirst(listS,'');
	 			if (temp[1].toLowerCase().indexOf('<br>') == -1) {
	 				temp[1] = ' style="padding-left:10px;">' + temp[1] + '</li></ul>';
	 				last = true;
	 			}else {	 		
	 				temp[1] = ' style="padding-left:10px;">' + temp[1].replaceFirst('(?i)<br>', '</li>');
	 			}
	 		}	
	 		if (first) {
	 			html = temp[0] + '<ul><li' + temp[1];
	 			first = false;
	 		}else {
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
	 			}else {	 
	 				List<String> temp2;	
	 				temp2 = temp[1].split('(?i)<br>',2);	
	 				if (temp2[1].indexOf(listSyntaxOL) == 0) {	
	 					temp[1] = '>' + temp[1].replaceFirst('(?i)<br>', '</li>');
	 				}else {
	 					temp[1] = '>' + temp[1].replaceFirst('(?i)<br>', '</li></ol>');
	 					lastOL = true;
	 				}
	 			}
	 		}else {
	 			temp[1] = temp[1].replaceFirst(listS,'');
	 			if (temp[1].toLowerCase().indexOf('<br>') == -1) {
	 				temp[1] = ' style="padding-left:10px;">' + temp[1] + '</li></ol>';
	 				lastOL = true;
	 			}else {	 		
	 				temp[1] = ' style="padding-left:10px;">' + temp[1].replaceFirst('(?i)<br>', '</li>');
	 			}
	 		}	
	 		if (firstOL) {
	 			html = temp[0] + '<ol><li' + temp[1];
	 			firstOL = false;
	 		}else {
	 			html = temp[0] + '<li' + temp[1];
	 		}
	 		if (lastOL) {
	 			firstOL = true;
	 			lastOL = false;
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
	 			}else {
	 				temp3 = temp2[1].split('\\]', 2);
	 			}
	 			html += '>' + temp3[0] + '</a>';
	 			html += temp3[1];
 			}else {
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
		 					if (attName == 'w') 
		 						imgTag += ' width="' + attval + '"';	
		 					if (attName == 'a') 
		 						imgTag += ' align="' + attval + '"';	
		 					if (attName == 'h') 
		 						imgTag += ' height="' + attval + '"';	
		 					
		 					if (attName == 'src') {
		 						String srcImg = '';
		 						if (attVal.toLowerCase().indexOf('http') != -1 || attVal.toLowerCase().indexOf('file:') != -1) {
		 							srcImg = attVal;
		 						}else {
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
	 			}else {
	 				if (contentImg.indexOf(':') != -1) {
		 				List<String> attVals = contentImg.split(':',2);
	 					String attName = attVals[0].trim();
	 					String attVal = attVals[1].trim();
	 					if (attName == 'src') {
	 						String srcImg = '';
	 						if (attVal.toLowerCase().indexOf('http') != -1 || attVal.toLowerCase().indexOf('file:') != -1) {
	 							srcImg = attVal;
	 						}else {
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
 			}else {
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
		           		}else {
		           			image2 = 'generic.gif';
		           		}
		            }else {
		           		// MIME TYPE WAY
		           		Map<String, String> typesMime2 = new Map<String, String>{'image/jpeg' => 'images.gif', 'image/png' => 'images.gif', 'image/gif' => 'images.gif', 'image/bmp' => 'images.gif', 'application/pdf' => 'pdf.gif', 'text/plain' => 'txt.gif','application/msword' => 'doc.gif', 'application/x-zip-compressed' => 'zip.gif'};	
		           		if(typesMime2.containsKey(ContentType2)) {
		           			image2 = typesMime2.get(ContentType2);
		           		}else {
		           			image2 = 'generic.gif';
		           		}
		            }
		 			fileType = '<img style="vertical-align:bottom;" src="https://na1.salesforce.com/resource/1204814978000/FileTypeIcons/' + image2 + '"/>';
	 			}else {
	 				href = '';
	 				fileType = '';
	 				fileName = '';
	 			}
	 			html = temp[0] + '<a href="';
	 			html += href + '">' + fileName + '</a>';
		 		html += temp2[1];
 			}else {
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
		 		}else {
		 			nameWiki = linkContent.trim();
		 		}
		 		
		 		if (nameWiki != '') {
			 		if (nameTeam != '') {
			 			teamNamesList.add(nameTeam);
			 		}else {
			 			teamNamesList.add(editWP.Wiki__r.Name);	
			 		}
			 		wikiNamesList.add(nameWiki);
			 		htmlLinks = temp[0] + temp2[1];
		 		}else {
		 			htmlLinks = temp[0] + temp2[1];	
		 		}
 			}else {
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
		 		}else {
		 			nameWiki = linkContent.trim();
		 			nameTeam = editWP.Wiki__r.Name;
		 		}
		 		
		 		if (nameWiki != '' && nameTeam != '') {
			 		WikiPage__c wiki;
			 		if (wikiMap.get(nameTeam + ':' + nameWiki) != null) 
			 			wiki = wikiMap.get(nameTeam + ':' + nameWiki); 	
			 		
			 		if (wiki != null) {
				 		String id;
				 		id = wiki.Id;
							 		
						html = temp[0] + '<a href=\"/apex/WikiPage?idWP=' + id + '\">' + nameWiki + '</a>' + temp2[1];	 		
				 	}else {
				 		html = temp[0] + '<a href="javascript:;" onclick="viewOverlayForm(\'' + idWikiPage + '\',\'AddChildForm\');newChildPreField(\'' + nameWiki + '\')">Create Page ' + nameWiki + '</a>' + temp2[1];
				 	}
		 		}else {
		 			html = temp[0] + temp2[1];	
		 		}
 			}else {
 				html = temp[0] + temp[1];
 			}
 		}
 		html = html.replaceAll('  ','');
  		
  		/* ------------------------ */
 		/* 	   Table of Content 	*/ 	
 		String tocSintax = '%TOC%';
 		String tocCentinel = '%%%%';
 		String tocCentinelStart = '%%%%<a name="';
 		String tocCentinelEnd = '"></a>%%%%';  
 		while (html.indexOf(tocCentinel) != -1) {
	 		List<String> tempToc1;
	 		List<String> tempToc2;
	 		
            /* if(html.split('(?i)' + tocCentinelStart, 2).size() > 1) {
                System.debug('El html es ' + html);
                System.debug('Por que cadena estoy cortando? ' + tocCentinelStart);
                System.debug('Parte 1 de la division ' + html.split('(?i)' + tocCentinelStart, 2)[0]);
                System.debug('Parte 2 de la division ' + html.split('(?i)' + tocCentinelStart, 2)[1]);
                //break;
            } */
	 		
	 		tempToc1 = html.split('(?i)' + tocCentinelStart, 2);
	 		html = html.replaceFirst('(?i)' + tocCentinel,'');
	 		
	 		tempToc2 = tempToc1[1].split('(?i)' + tocCentinelEnd, 2);
	 		html = html.replaceFirst('(?i)' + tocCentinel,'');
			
            Integer a;
            String part1 = '';
            String numH = '0';
            if(tempToc1[0] != '') {
                if(tempToc1[0].length() > 0) {
                    a = tempToc1[0].length() - 1;
                } else {
                    a = 0;
                }
                part1 = tempToc1[0].substring(0,a);
                numH = tempToc1[0].substring(a,a + 1);
            }
            html = part1 + '<a name="'+ tempToc2[0] + '"></a>' + tempToc2[1]; 
            
            toc += '<a  href="#' + tempToc2[0] + '" style="padding-left:' + numH + '0px;padding-bottom:5px;">' + tempToc2[0] + '</a>\n';
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
 		
 	}   
 	
 	/**
 	* Return parsed HTML
 	*@return String
 	*/
 	public String getHtml () {
 		return html;	
 	}
	
	/**
	* Parse Wiki code to HTML
	*/
	

 	public void parseWiki() {

  		html = replace.content;
		html = html.replaceAll('(?i)&nbsp;',' ');
		html = html.replaceAll('(?i)&amp;','&');
		html = html.replaceAll('(?i)&quot;','"');
		html = html.replaceAll('(?i)&gt;','>');
		html = html.replaceAll('(?i)&lt;','<');
		
		html = html.replaceAll('(?i)</li>[^<]*<li','</li><li');
		html = html.replaceAll('(?i)<ul[^>]*>[^<]*<li','<ul><li');
		html = html.replaceAll('(?i)</li>[^<]*</ul>','</li></ul>');
		html = html.replaceAll('(?i)</li>[^<]*<li','</li><li'); 
		
		html = html.replaceAll('(?i)<br>[\r\n]*</li>','</li>');
		
		html = html.replaceAll('(?i)<ol[^>]*>[^<]*<li','<ol><li');
		html = html.replaceAll('(?i)</li>[^<]*</ol>','</li></ol>');
		// REMOVE ALL THE METADATA AND CSS STYLES INCLUDE FROM WORD
		
        html = html.replaceAll('(?i)(<(meta[^>]*>|link[^>]*>|w[^>]*>[^><]*</w[^>]*>|w[^>]*>|/w[^>]*>|xml>|/xml>|!(--)?\\[[^>]*>)|/\\*[^*]*\\*/)','');
        html = html.replaceAll('(?i)<\\!--','');
        html = html.replaceAll('(?i)-->','');
        
        while(found('(?i)<style[^>]*>[^<]*</style>',html)) {
            html = html.replaceFirst('(?i)<style[^>]*>[^<]*</style>','');
        }

        html = html.replaceAll('(?i)<b{1} [^>]*="[^\"]*" *>','<b>');
        html = html.replaceAll('(?i)<i{1} [^>]*="[^\"]*" *>','<i>');

  		/* ------------------------ */
 		/* 		Code (no parsed) 	*/ 		
		html = html.replaceAll('(?i)' + '<table style=\\\"border: 1px solid rgb\\(175, 175, 175\\); padding: 20px; background-color: rgb\\(250, 250, 250\\);\\\"><tbody><tr><td>','{{{');
		html = html.replaceAll('(?i)' + '<span></span></td></tr></tbody></table>','}}}');
		
        // Created By Miguel Angel Sosa - 09.01.09
        // Last Modified 16.01.09 by Miguel Angel Sosa
        //////////////////////////////////////////////
        /*      Span tag parser     */
        // Expresiones de busqueda en la variable [html] para localizar las propiedades
        String spanTagOpen = '(?i)<span ?';
        String styleSpanAttribute = '(?i)style=';
        String fontFamilyProperty = '(?i)font-family:[^>][a-z]*;?';
        
        // Expresiones de busqueda en la variable [html] para localizar spans
        String spanCompleteOpen = '(?i)<span (.[^>]*)>';
        String spanCompleteClose = '(?i)</span>';
        String spanCompleteComplete = '(?i)<span ?(.*[^>]*)></span>';
        
        String forSpanStyles = '(?i)<span [^>]*style="[^"]*"[^>]*>';
        String forStylesInside = '(?i)"[^"]*"';
        String tempSpanStyles;
        String tempStylesInside;

        while(found(forSpanStyles,html)) {
            // Debo eliminar cualquier propiedad dentro de span que no sea style
            String propertyNoLong = '(?i)lang="[^"]*"';
            html = html.replaceAll(propertyNoLong,'');
            
            // Las nuevas propiedades
            String fontFamilyPropertie = '';
            String fontFamilyClose = '';
            
            String fontSizePropertie = '';
            String fontSizeClose = '';
            
            String fontVariantPropertie = '';
            String fontVariantClose = '';
            
            String lineHeightPropertie = '';
            String lineHeightClose = '';
            
            String fontStylePropertie = '';
            String fontStyleClose = '';
            
            String fontWeightPropertie = '';
            String fontWeightClose = '';
            
            String fontColorPropertie = '';
            String fontColorClose = '';
            
            String fontBgColorPropertie = '';
            String fontBgColorClose = '';
            
            String newFontStyles = '';
            String closeFontStyles = '';
            String spanContent = '';
            
            // Obtengo primer span que encuentro y lo guardo temporalmente
            tempSpanStyles = getMatch(forSpanStyles,html);
            
            // Lo sustituyo por una linea clave para despues reemplazarla denuevo\
            String theSpanTag;
            theSpanTag = getMatch('<span{1} +[^>]*>.*</span>',html);
            html = html.replaceFirst(forSpanStyles,'##hereStyles##');
            
            tempStylesInside = getMatch(forStylesInside,tempSpanStyles).replaceAll('"','');
            System.debug('Y los estilos son -----> ' + tempStylesInside);
            List<String> stylePropertys = tempStylesInside.split(';');
            
            for(Integer i = 0; i < stylePropertys.size(); i++ ) {
                List<String> partsPropertie = stylePropertys[i].split(':',2);
                
                if(partsPropertie.size() > 1) {
                    String namePropertie = partsPropertie[0];
                    String valuePropertie = partsPropertie[1];
                    
                    
                    String theSpanContent;
                    String theStyleAttribute;
                    String theStyleContent;
                    List<String> thePropertiesStyle;
                    List<String> sizeAndLineHeight;
                    System.debug('PROBANDO CON EL HTML ' + html);
                    // Forma la propiedad encontrada al nuevo modo
                    if(namePropertie.trim() == 'font' || namePropertie.trim() == 'FONT') {
                        //theSpanTag = getMatch('<span{1} +[^>]*>.*</span>',html);
                        theStyleAttribute = getMatch('(?i)style="[^"]*"',theSpanTag);
                        theStyleContent = getMatch('(?i)"[^"]*"',theStyleAttribute);
                            System.debug('Todos los estilos ----> ' + theStyleContent);
                        thePropertiesStyle = theStyleContent.split(' ');
                            System.debug('Cantidad de propiedades ----> ' + thePropertiesStyle.size());
                        for(integer k = 0; k < thePropertiesStyle.size(); k++) {
                            thePropertiesStyle[k] = thePropertiesStyle[k].trim().replaceAll('\'','').replaceAll('\"','');
                            System.debug('La propiedad ----> ' + thePropertiesStyle[k]);
                            if(thePropertiesStyle[k].toLowerCase().trim() == 'bold' || thePropertiesStyle[k].toLowerCase().trim() == 'bolder' || thePropertiesStyle[k].toLowerCase().trim() == 'lighter') {
                                fontWeightPropertie = '\'\'\'';
                                fontWeightClose = '\'\'\'';
                            } else if(thePropertiesStyle[k].toLowerCase().trim() == 'italic' || thePropertiesStyle[k].toLowerCase().trim() == 'oblique') {
                                fontStylePropertie = '\'\'';
                                fontStyleClose = '\'\'';
                            } else if(thePropertiesStyle[k].toLowerCase().trim() == 'times' || thePropertiesStyle[k].toLowerCase().trim() == 'verdana' || thePropertiesStyle[k].toLowerCase().trim() == 'arial' || thePropertiesStyle[k].toLowerCase().trim() == 'courier new' || thePropertiesStyle[k].toLowerCase().trim() == 'comic sans ms' || thePropertiesStyle[k].toLowerCase().trim() == 'tahoma') {
                                if(thePropertiesStyle[k].toLowerCase().trim() == 'times') {
                                    thePropertiesStyle[k] = thePropertiesStyle[k] + ' new roman';
                                }
                                fontFamilyPropertie = '[fontFamily:{' + thePropertiesStyle[k].replaceAll('\'','').replaceAll('\"','').trim() + '}]';
                                fontFamilyClose = '[!fontFamily]';
                            } else if(thePropertiesStyle[k].toLowerCase().trim() == 'small-caps') {
                                fontVariantPropertie = '[fontVariant:' + thePropertiesStyle[k].replaceAll('\'','').replaceAll('"','').trim() + ']';
                                fontVariantClose = '[!fontVariant]'; 
                            } else if(thePropertiesStyle[k].split('/',2).size() > 1) {
                                sizeAndLineHeight = thePropertiesStyle[k].split('/');
                                fontSizePropertie = '[fontSize:' + sizeAndLineHeight[0].replaceAll('\'','').replaceAll('"','').trim() + ']';
                                fontSizeClose = '[!fontSize]';
                                
                                lineHeightPropertie = '[lineHeight:' + sizeAndLineHeight[1].replaceAll('\'','').replaceAll('"','').trim() + ']';
                                lineHeightClose = '[!lineHeight]';
                            }
                        }
                    } else if(namePropertie.trim() == 'color' || namePropertie.trim() == 'COLOR') {
                        if(valuePropertie.trim() != '') {
                            fontColorPropertie = '[Color:' + valuePropertie.replaceAll('\'','').replaceAll('\"','').trim() + ']';
                            fontColorClose= '[!Color]';
                        }
                    } else if(namePropertie.trim() == 'font-family') {
                        if(valuePropertie.trim() != '') {
                            fontFamilyPropertie = '[fontFamily:{' + valuePropertie.replaceAll('\'','').replaceAll('\"','').trim() + '}]';
                            fontFamilyClose = '[!fontFamily]';
                        }
                    } else if(namePropertie.trim() == 'font-size') {
                        if(valuePropertie != '') {
                            fontSizePropertie = '[fontSize:' + valuePropertie.replaceAll('\'','').replaceAll('"','').trim() + ']';
                            fontSizeClose = '[!fontSize]';
                        }
                    } else if(namePropertie.trim() == 'font-variant') {
                        if(valuePropertie != '') {
                            fontVariantPropertie = '[fontVariant:' + valuePropertie.replaceAll('\'','').replaceAll('"','').trim() + ']';
                            fontVariantClose = '[!fontVariant]';
                        }
                    } else if(namePropertie.trim() == 'line-height') {
                        if(valuePropertie != '') {
                            lineHeightPropertie = '[lineHeight:' + valuePropertie.replaceAll('\'','').replaceAll('"','').trim() + ']';
                            lineHeightClose = '[!lineHeight]';
                        }
                    } else if(namePropertie.trim() == 'font-style') {
                        if(valuePropertie.trim() == '' || valuePropertie.trim() == 'normal') {
                            fontStylePropertie = '';
                            fontStyleClose = '';
                        } else if(valuePropertie.trim() == 'italic' || valuePropertie.trim() == 'oblique') {
                            fontStylePropertie = ' \'\' ';
                            fontStyleClose = ' \'\' ';
                        }
                    } else if(namePropertie.trim() == 'font-weight') {
                        if(valuePropertie.trim() == '' || valuePropertie.trim() == 'normal') {
                            fontWeightPropertie = '';
                            fontWeightClose = '';
                        } else if(valuePropertie.trim() == 'bold' || valuePropertie.trim() == 'bolder' || valuePropertie.trim() == 'lighter') {
                            //System.debug('Estoy en font-weight: Bold');
                            fontWeightPropertie = ' \'\'\' ';
                            fontWeightClose = ' \'\'\' ';
                        }
                    } else if(namePropertie.trim() == 'background-color' || namePropertie.trim() == 'BACKGROUND-COLOR' || namePropertie.trim() == 'background') {
                        //System.debug('Estoy en background-color');
                        if(valuePropertie.trim() != '') {
                            valuePropertie = valuePropertie.replaceAll('(?i)[0-9]{1,2}%','');
                            valuePropertie = valuePropertie.replaceAll('(?i)none','');
                            valuePropertie = valuePropertie.replaceAll('(?i)repeat','');
                            valuePropertie = valuePropertie.replaceAll('(?i)scroll','');
                            fontBgColorPropertie = '[Bgcolor:' +  + valuePropertie.replaceAll('\'','').replaceAll('"','').trim() + ']';
                            fontBgColorClose = '[!Bgcolor]';
                        }
                    }
                }   
            }
            
            newFontStyles = fontBgColorPropertie + fontColorPropertie + fontFamilyPropertie + fontSizePropertie + fontVariantPropertie + lineHeightPropertie + fontWeightPropertie + fontStylePropertie;
            closeFontStyles = fontStyleClose + fontWeightClose + lineHeightClose + fontVariantClose + fontSizeClose + fontFamilyClose + fontColorClose + fontBgColorClose;
            
            //html = html.replaceFirst('</span>','##hereFinish##');
            html = html.replaceFirst('##hereStyles##',newFontStyles);
            html = html.replaceFirst('(?i)</span>',closeFontStyles);
            //System.debug('Ahora html es ' + html);
        }

 		/* ------------------------ */
 		/* 			Ident Text 		*/ 		
		String identOpen = '<p style="margin-left: ';
		
		String identClose = '</p>';
		List<String> tempIdent;
		
		while (html.toLowerCase().indexOf(identOpen) != -1) {
			tempIdent = html.split('(?i)' + identOpen, 2);
			List<String> marginPx;
			Integer numMinus;
			
			if(tempIdent[1].split('(?i)' + 'pt[^>]*"', 2).size() > 1) {
				//List<String> marginPtToPx = tempIdent[1].split('(?i)' + 'pt[^>]*">',2);
				marginPx = tempIdent[1].split('(?i)' + 'pt[^>]*">', 2);
				numMinus = (double.valueOf(marginPx[0]).intValue()) / 20;
			} else {
				marginPx = tempIdent[1].split('(?i)' + 'px[^>]*">', 2);
				numMinus = (integer.valueOf(marginPx[0])) / 20;
			}
			
			if(tempIdent[1].split('(?i)' + 'pt[^>]*">',2).size() > 1) {
				Decimal numMargin = (double.valueOf(marginPx[0])) * 1.33;
				Integer intNumMargin = numMargin.intValue();
			}

			//Integer numMinus = (double.valueOf(marginPx[0]).intValue()) / 20;
			
			String minus = '';
			for (Integer i= 1; i<= numMinus; i++) {
				minus += '-';
			}
			html = tempIdent[0] + '[[' + minus + '>' + marginPx[1].replaceFirst('(?i)' + identClose , minus + '>]]');
		}
		
  		/* ------------------------ */
 		/* 		UnOrdered List	 	*/
 		String ulOpen = '<ul[^>]*>';
 		String ulClose = '</ul>';
 		while (html.toLowerCase().split(ulOpen,2).size() > 1) {
	 		List<String> ulPart;
	 		List<String> ulPart2;
	 		ulPart = html.split('(?i)' + ulOpen,2);
	 		ulPart2 = ulPart[1].split('(?i)' + ulClose,2);
	 		String ulString;
	 		ulString = ulPart2[0];
	 		String listTagOpen = '<li[^>]*>';
	 		String listTagClose = '</li>';
	 		String listTagClose2 = '<br></li>';
	 		
	 		String listTagPadOpen = '<li style="[^"]*padding-left: 10px;[^"]*">';
	 		while (ulString.toLowerCase().split(listTagPadOpen,2).size() > 1) {
		 		List<String> temp;
		 		temp = ulString.split('(?i)' + listTagPadOpen ,2);
		 		ulString = ulString.replaceFirst('(?i)' + listTagPadOpen , '**');
		 		temp[1] = temp[1].replaceFirst('(?i)' + listTagClose,'<br>');
		 		ulString = temp[0] + '** ' + temp[1];
	 		} 
	 		
	 		while (ulString.toLowerCase().split(listTagOpen,2).size() > 1) {
		 		List<String> temp;
		 		temp = ulString.split('(?i)' + listTagOpen ,2);
		 		ulString = ulString.replaceFirst('(?i)' + listTagOpen , '*');
		 		if ((ulString.toLowerCase().indexOf(listTagClose2) < ulString.toLowerCase().indexOf(listTagClose)) && ulString.toLowerCase().lastIndexOf(listTagClose2) != -1) {
		 			temp[1] = temp[1].replaceFirst('(?i)' + listTagClose,'');
		 		}else {
		 			if ((temp[1].split('(?i)' + listTagClose,2).size() > 1) && ((temp[1].toLowerCase().indexOf('<li') > temp[1].toLowerCase().indexOf('</li>')) ||(temp[1].toLowerCase().indexOf('<li')== -1)) ) {
		 				temp[1] = temp[1].replaceFirst('(?i)' + listTagClose,'<br>');
		 			}else {
		 				temp[1] = temp[1].replaceFirst('[\n\r][^<li]*','<br>');	
		 				temp[0] = temp[0].replaceAll('[\n\r]','');
		 			}
		 		}
		 		ulString = temp[0] + '* ' + temp[1];
		 	}
	 		html = ulPart[0] + ulString + ulPart2[1];
 		}
		
  		/* ------------------------ */
 		/* 		Ordered List	 	*/
 		String olOpen = '<ol[^>]*>';
 		String olClose = '</ol>';
 		while (html.toLowerCase().split(olOpen,2).size() > 1) {
	 		List<String> olPart;
	 		List<String> olPart2;
	 		olPart = html.split('(?i)' + olOpen,2);
	 		olPart2 = olPart[1].split('(?i)' + olClose,2);
	 		String olString;
	 		olString = olPart2[0];
	 		String listTagOpen = '<li[^>]*>';
	 		String listTagClose = '</li>';
	 		String listTagClose2 = '<br></li>';
	 		String listTagPadOpen = '<li style="[^"]*padding-left: 10px;[^"]*">';
	 		
	 		while (olString.toLowerCase().split(listTagPadOpen,2).size() > 1) {
		 		List<String> temp;
		 		temp = olString.split('(?i)' + listTagPadOpen ,2);
		 		olString = olString.replaceFirst('(?i)' + listTagPadOpen , '~~');
		 		temp[1] = temp[1].replaceFirst('(?i)' + listTagClose,'<br>');
		 		olString = temp[0] + '~~* ' + temp[1];
	 		} 
	 		while (olString.toLowerCase().split(listTagOpen,2).size() > 1) {
		 		List<String> temp;
		 		temp = olString.split(listTagOpen ,2);
		 		olString = olString.replaceFirst('(?i)' + listTagOpen , '*');
		 		if (olString.toLowerCase().indexOf(listTagClose2) < olString.toLowerCase().indexOf(listTagClose) && olString.toLowerCase().lastIndexOf(listTagClose2) != -1) {
		 			temp[1] = temp[1].replaceFirst('(?i)' + listTagClose,'');
		 		}else {
		 			if (temp[1].split('(?i)' + listTagClose,2).size() > 1) {
		 				temp[1] = temp[1].replaceFirst('(?i)' + listTagClose,'<br>');
		 			}else {
		 				temp[1] = temp[1].replaceFirst('[\n\r][^<li]*','<br>');	
		 				temp[0] = temp[0].replaceAll('[\n\r]','');
		 			}
		 		}
		 		olString = temp[0] + '~ ' + temp[1];
	 		} 		
	 		html = olPart[0] + olString + olPart2[1];
 		}
 		
 		// REMOVE THE RETURN CHAR 
 		html = html.replaceAll('[\n\r]','');
 		
		/* ------------------------ */
 		/* 			Text Align	 	*/
		String alignRightOpen = '<p style="text-align: right;">';
		String alignLeftOpen = '<p style="text-align: left;">';
		String alignCenterOpen = '<p style="text-align: center;">';
		String alignJustifyOpen = '<p style="text-align: justify;">';
		
		String alignRightOpenWord = '<div align="right">';
		String alignCenterOpenWord = '<div align="center">';
		
		String alignClose = '</p>';
		String alignCloseWord = '</div>';
		List<String> tempRight;
		
		// Center Align from Word
		while (html.toLowerCase().indexOf(alignCenterOpenWord) != -1) {
			tempRight = html.split('(?i)' + alignCenterOpenWord, 2);
			html = tempRight[0] + '[[=' + tempRight[1].replaceFirst('(?i)' + alignCloseWord ,'=]]');
		}
		
		// Right Align from Word
		while (html.toLowerCase().indexOf(alignRightOpenWord) != -1) {
			tempRight = html.split('(?i)' + alignRightOpenWord, 2);
			html = tempRight[0] + '[[> ' + tempRight[1].replaceFirst('(?i)' + alignCloseWord ,' >]]');
		}
		
		// Align from FCKeditor
		while (html.toLowerCase().indexOf(alignRightOpen) != -1) {
			tempRight = html.split('(?i)' + alignRightOpen, 2);
			html = tempRight[0] + '[[> ' + tempRight[1].replaceFirst('(?i)' + alignClose ,' >]]');
		}
		
		while (html.toLowerCase().indexOf(alignLeftOpen) != -1) {
			tempRight = html.split('(?i)' + alignLeftOpen, 2);
			html = tempRight[0] + '[[< ' + tempRight[1].replaceFirst('(?i)' + alignClose ,' <]]');
		}
		
		while (html.toLowerCase().indexOf(alignCenterOpen) != -1) {
			tempRight = html.split('(?i)' + alignCenterOpen, 2);
			html = tempRight[0] + '[[=' + tempRight[1].replaceFirst('(?i)' + alignClose ,'=]]');
		}
		
		while (html.toLowerCase().indexOf(alignJustifyOpen) != -1) {	
			tempRight = html.split('(?i)' + alignJustifyOpen, 2);
			html = tempRight[0] + '[[<>' + tempRight[1].replaceFirst('(?i)' + alignClose ,'<>]]');
		}
		

  		/* ------------------------ */
 		/* 			HEADINGS 		*/
 		for (Integer i = 6; i > 1; i--) {
	  		String headerOpen = '<h' + i + '[^>]*>'; 		
	  		String header = '';
	  		for (Integer j = 1; j <= i; j++) {
	  			header += '=';	
	  		} 
	  		
 			Integer fontSize;
			if (i == 2) 
				fontSize = 20;
			if (i == 3) 
				fontSize = 18;
			if (i == 4) 
				fontSize = 16;
			if (i == 5) 
				fontSize = 14;
			if (i == 6) 
				fontSize = 13;			
 			 
 			html = html.replaceAll('(?i)' + headerOpen ,' ' + header + ' ');
	 		
	 		//remove <br> and whitespace if any.
	 		String headerClose1 = '<br[^>]*>[ \r\n]*</h' + i + '><hr[^>]*>';
	 		
	 		String headerClose3 = '<br></h' + i + '>';
	 		String headerClose4 = '</h' + i + '><hr[^>]*>';
	 		String headerClose5 = '</h' + i + '>[\r\n]*<hr[^>]*>';
	 		String headerClose6 = '</h' + i + '>';
	 		html = html.replaceAll('(?i)' + headerClose1 ,' ' + header + ' ');
	 			
	 		html = html.replaceAll('(?i)' + headerClose3 ,' ' + header + ' ');
	 		html = html.replaceAll('(?i)' + headerClose4 ,' ' + header + ' ');	
	 		html = html.replaceAll('(?i)' + headerClose5 ,' ' + header + ' ');	
	 		html = html.replaceAll('(?i)' + headerClose6 ,' ' + header + ' ');
	 	}	
	 	
	 	/* ------------------------ */
 		/* 		Horizontal Line 	*/
 		String line = '<hr>';
 		html = html.replaceAll('(?i)' + line ,'----');
	 		
 		/* ------------------------ */
 		/* 			Bold Text 		*/ 			
  		String boldOpen = '<b>';
 		html = html.replaceAll('(?i)' + boldOpen ,' \'\'\' ');	
 		String boldClose = '</b>';
 		html = html.replaceAll('(?i)' + boldClose ,' \'\'\' '); 	
 		
 		String boldOpen2 = '<strong>';
 		html = html.replaceAll('(?i)' + boldOpen2 ,' \'\'\' ');	
 		String boldClose2 = '</strong>';
 		html = html.replaceAll('(?i)' + boldClose2 ,' \'\'\' '); 	
 		
 		/* ------------------------ */
 		/* 			Sub Text 		*/ 			
  		String subOpen = '<sub>';
 		html = html.replaceAll('(?i)' + subOpen ,',,');	
 		String subClose = '</sub>';
 		html = html.replaceAll('(?i)' + subClose ,',,'); 
 		
 		/* ------------------------ */
 		/* 			Sup Text 		*/ 			
  		String supOpen = '<sup>';
 		html = html.replaceAll('(?i)' + supOpen ,'^');	
 		String supClose = '</sup>';
 		html = html.replaceAll('(?i)' + supClose ,'^'); 		
 		
 		/* ------------------------ */
 		/* 			Italic Text 	*/ 		
  		String italicOpen = '<i>';
 		html = html.replaceAll('(?i)' + italicOpen ,' \'\' ');	
 		String italicClose = '</i>';
 		html = html.replaceAll('(?i)' + italicClose ,' \'\' '); 
 		
 		String italicOpen2 = '<em>';
 		html = html.replaceAll('(?i)' + italicOpen2 ,' \'\' ');	
 		String italicClose2 = '</em>';
 		html = html.replaceAll('(?i)' + italicClose2 ,' \'\' '); 

 		/* ------------------------ */
 		/* 		  UnderLine Text 	*/ 		
  		String underOpen = '<u>';
 		html = html.replaceAll('(?i)' + underOpen ,' __');	
 		String underClose = '</u>';
 		html = html.replaceAll('(?i)' + underClose ,'__ ');
 		
 		/* ------------------------ */
 		/* 		 Strike Text 	*/ 
 		String strikeOpen = '<strike>';
 		String strikeClose = '</strike>';
	 	html = html.replaceAll('(?i)' + strikeOpen , '--(');
	 	html = html.replaceAll('(?i)' + strikeClose , ')--');

  		/* ------------------------ */
 		/* 		 Embedded Image 	*/  
  		
  		
  		// GENERATE THE ATTACHMENT MAP FOR THIS WIKI.
		Map<String, Attachment> attachmentsMap = new Map<String, Attachment>();
 		for (Attachment iterAttach : [select Name, Id, parentId, ContentType from Attachment where parentid=:idWikiPage]) {
 			if (attachmentsMap.get(iterAttach.Name) == null) {
 				attachmentsMap.put(iterAttach.Id, iterAttach);
 			}	
 		}
  		
  		String imgTag = '<img ';
        String notValidImage = 'spacer.gif';

            String spacerRegExp = '(?i)<img[^>]*spacer[^>]*>{1}';
            if(html.split(spacerRegExp,2).size() > 1) {
                html = html.replaceFirst(spacerRegExp,'');
            }
            // Si todo sale bien tanto puede seguir como volver a empezar
            
 		while (html.toLowerCase().indexOf(imgTag) != -1) {	
 			Boolean smileImg = false;
 			String imgTagGen = '';
 			List<String> imgTagContent = html.split('(?i)<img ', 2);
 			List<String> imgAtt = new List<String>();
 			if (imgtagContent[1].indexOf('/>') != -1) {
 				imgAtt = imgtagContent[1].split('/>',2);
 			}else {
 				imgAtt = imgtagContent[1].split('>',2);
 			}
 			List<String> imgAttList = new List<String>();
 			String attributes = imgAtt[0]; 
 			if (attributes.toLowerCase().indexOf('src') != -1) {
 				List<String> tempAtt = new List<String>();
 				tempAtt = attributes.split('(?i)src',2);
 				if (tempAtt[1].toLowerCase().indexOf(' ') != -1) {
 					List<String> tempAtt2 = new List<String>();
 					tempAtt2 = tempAtt[1].split(' ', 2);
 					imgAttList.add('src' + tempAtt2[0]);
 					attributes = tempAtt[0] + tempAtt2 [1];
 				}else {
 					imgAttList.add('src' + tempAtt[1]);
 					attributes = tempAtt[0];
 				}
 			}
 			if (attributes.toLowerCase().indexOf('style') != -1) {
 				List<String> tempAtt = new List<String>();
 				tempAtt = attributes.split('(?i)style',2);
 				String styleValue = tempAtt[1];
 				
 				styleValue = styleValue.substring(2);
 				List<String> tempAtt2 = new List<String>();
 				tempAtt2 = styleValue.split('"', 2);
 				imgAttList.add('style="' + tempAtt2[0] + '"');
 				attributes = tempAtt[0] + tempAtt2 [1];
 			}
 			if (attributes.toLowerCase().indexOf('width') != -1) {
 				List<String> tempAtt = new List<String>();
 				tempAtt = attributes.split('(?i)width',2);
 				if (tempAtt[1].toLowerCase().indexOf(' ') != -1) {
 					List<String> tempAtt2 = new List<String>();
 					tempAtt2 = tempAtt[1].split(' ', 2);
 					imgAttList.add('width' + tempAtt2[0]);
 					attributes = tempAtt[0] + tempAtt2 [1];
 				}else {
 					imgAttList.add('width' + tempAtt[1]);
 					attributes = tempAtt[0];
 				}
 			}
 			if (attributes.toLowerCase().indexOf('height') != -1) {
 				List<String> tempAtt = new List<String>();
 				tempAtt = attributes.split('(?i)height',2);
 				if (tempAtt[1].toLowerCase().indexOf(' ') != -1) {
 					List<String> tempAtt2 = new List<String>();
 					tempAtt2 = tempAtt[1].split(' ', 2);
 					imgAttList.add('height' + tempAtt2[0]);
 					attributes = tempAtt[0] + tempAtt2 [1];
 				}else {
 					imgAttList.add('height' + tempAtt[1]);
 					attributes = tempAtt[0];
 				}
 			}
 			if (attributes.toLowerCase().indexOf('align') != -1) {
 				List<String> tempAtt = new List<String>();
 				tempAtt = attributes.split('(?i)align',2);
 				if (tempAtt[1].toLowerCase().indexOf(' ') != -1) {
 					List<String> tempAtt2 = new List<String>();
 					tempAtt2 = tempAtt[1].split(' ', 2);
 					imgAttList.add('align' + tempAtt2[0]);
 					attributes = tempAtt[0] + tempAtt2 [1];
 				}else {
 					imgAttList.add('align' + tempAtt[1]);
 					attributes = tempAtt[0];
 				}
 			}
 			Integer widthSet = 0;
 			Integer heightSet = 0;
 			for (String dim : imgAttList) {
 				if (dim.toLowerCase().indexOf('width') != -1) {
 					widthSet++;	
 				}
 				if (dim.toLowerCase().indexOf('height') != -1) {
 					heightSet++;	
 				}
 			}
 			for (String item: imgAttList) {
 				if(item.indexOf('=') != -1) {
 					List<String> attParts = item.split('=', 2);
 					String attName = attParts[0].toLowerCase().trim();
 					String attVal = attParts[1].trim();
 					if (attName == 'style')	{
 						if (attVal.toLowerCase().indexOf('width') != -1 && widthSet < 2) {
 							List<String> styleW = new List<String>();
 							styleW = attVal.split('(?i)width[ ]*:',2);
 							String styleWVal = '';
 							if (styleW[1].indexOf(';') != -1) {
 								List<String> widthValS = new List<String>();
 								widthValS = styleW[1].split(';',2);
 								styleWVal = widthVals[0].trim();
 							}else {
 								styleWVal = styleW[1].trim();	
 							}
 							imgTagGen += ' w:' + styleWVal.replaceAll('"', '') + ';';	
 						}
 						if (attVal.toLowerCase().indexOf('height') != -1 && heightSet < 2) {
 							List<String> styleH = new List<String>();
 							styleH = attVal.split('(?i)height[ ]*:',2);
 							String styleHVal = '';
 							if (styleH[1].indexOf(';') != -1) {
 								List<String> heightValS = new List<String>();
 								heightValS = styleH[1].split(';',2);
 								styleHVal = heightValS[0].trim();
 							}else {
 								styleHVal = styleH[1].trim();	
 							}
 							imgTagGen += ' h:' + styleHVal.replaceAll('"', '') + ';';
 						}
 					}
 					if (attName == 'width') 
						imgTagGen += ' w:' + attVal.replaceAll('"', '') + ';';	
 					if (attName == 'height') 
 						imgTagGen += ' h:' + attVal.replaceAll('"', '') + ';';	
 					if (attName == 'align') 
 						imgTagGen += ' a:' + attVal.replaceAll('"', '') + ';';	

 					if (attName == 'src') {
 						String srcImage = '';
 						attVal = attVal.replaceAll('"', '');
 						if (attVal.toLowerCase().indexOf('https://na1.salesforce.com/servlet/servlet') != -1) {
	 						String[] srcParts = attVal.split('(?i)file=',2);
				  			String imageId = srcParts[1];				
				 			List<Attachment> AttachmentsImage = [select Name, Id from Attachment where id =:imageId  limit 1];
				 			String imageName = '';
				 			if (attachmentsMap.get(imageId) != null) {	
					 			imageName = attachmentsMap.get(imageId).Name;
							}	
							imgTagGen += ' src:' + imageName + ';'; 
 						}else {
 							if (attVal.toLowerCase().indexOf('fckeditor/editor/images/smiley/msn') != -1) {
				 				if (attVal.toLowerCase().indexOf('regular_smile.gif') != -1) 
				 					html = imgTagContent[0] + ':)';	
				 				if (attVal.toLowerCase().indexOf('whatchutalkingabout_smile.gif') != -1) 
				 					html = imgTagContent[0] + ':|';	
				 				if (attVal.toLowerCase().indexOf('teeth_smile.gif') != -1) 
				 					html = imgTagContent[0] + ':D';	
				 				if (attVal.toLowerCase().indexOf('sad_smile.gif') != -1) 
				 					html = imgTagContent[0] + ':(';	
				 				if (attVal.toLowerCase().indexOf('cry_smile.gif') != -1) 
				 					html = imgTagContent[0] + ':\'(';	
				 				if (attVal.toLowerCase().indexOf('wink_smile.gif') != -1) 
				 					html = imgTagContent[0] + ';)';	
				 				if (attVal.toLowerCase().indexOf('devil_smile.gif') != -1) 
				 					html = imgTagContent[0] + '(6)';	
				 				if (attVal.toLowerCase().indexOf('lightbulb.gif') != -1) 
				 					html = imgTagContent[0] + '(I)';	
				 				if (attVal.toLowerCase().indexOf('thumbs_up.gif') != -1) 
				 					html = imgTagContent[0] + '(Y)';	
				 				if (attVal.toLowerCase().indexOf('thumbs_down.gif') != -1) 
				 					html = imgTagContent[0] + '(N)';	
				 				if (attVal.toLowerCase().indexOf('heart.gif') != -1) 
				 					html = imgTagContent[0] + '(L)';	
				 				if (attVal.toLowerCase().indexOf('broken_heart.gif') != -1) 
				 					html = imgTagContent[0] + '(U)';	
				 				if (attVal.toLowerCase().indexOf('kiss.gif') != -1) 
				 					html = imgTagContent[0] + '(K)';	
				 				if (attVal.toLowerCase().indexOf('envelope.gif') != -1) 
				 					html = imgTagContent[0] + '(E)';	
				 				if (attVal.toLowerCase().indexOf('shades_smile.gif') != -1) 
				 					html = imgTagContent[0] + '(H)';	
				 				if (attVal.toLowerCase().indexOf('angry_smile.gif') != -1) 
				 					html = imgTagContent[0] + ':@';	
				 				if (attVal.toLowerCase().indexOf('tounge_smile.gif') != -1) 
				 					html = imgTagContent[0] + ':P';	
				 				if (attVal.toLowerCase().indexOf('embaressed_smile.gif') != -1) 
				 					html = imgTagContent[0] + ':$';	
				 				if (attVal.toLowerCase().indexOf('omg_smile.gif') != -1) 
				 					html = imgTagContent[0] + ':O';	
				 				if (attVal.toLowerCase().indexOf('confused_smile.gif') != -1) 
				 					html = imgTagContent[0] + ':S';	
				 				if (attVal.toLowerCase().indexOf('angel_smile.gif') != -1) 
				 					html = imgTagContent[0] + '(A)';	
				 				smileImg = true;		
 							}else {
	 							imgTagGen += ' src:' + attVal + ';';
	 						}
						}
 					}
 				}
 			}
			if (!smileImg) {
				html = imgTagContent[0] + '[Image: ' + imgTagGen + ']';
			}
			if (imgAtt.size() > 1) {
	 			html += imgAtt[1];
			}
 		} 
 		
  		/* ------------------------ */
 		/* 		 Table of Content 	*/ 
 		String tocLinks = 'href="#[^>]*">[^>]*</a>';
 		html = html.replaceFirst('(?i)' + tocLinks,'>%TOC%');
 		html = html.replaceAll('(?i)' + tocLinks,'>');
 		
 		/* ------------------------ */
 		/* 		  Linking Methods 	*/ 	 
		
		List<String> wikiPageIds = new List<String>();
		String linkString = '<a';
		String htmlIds = html;
		
		while (htmlIds.toLowerCase().indexOf(linkString) != -1) {
			String linkAttributes = '';
			String linkTail = '';
			String linkContent = '';
			String htmlTail = '';
			String idWikiLink = '';
			String idAttach = '';
			
			List<String> htmlLinkParts = new List<String>();
			htmlLinkParts = htmlIds.split('(?i)' + linkString,2);
			if (htmlLinkParts[1].indexOf('>') != -1) {
				List<String> linkParts = new List<String>();
				linkParts = htmlLinkParts[1].split('>', 2);
				linkAttributes = linkParts[0].trim();
				linkTail = linkParts[1];
				
				List<String> linkTailParts = new List<String>();
				if (linkTail.toLowerCase().indexOf('</a>') != -1) {
					linkTailParts = linkTail.split('(?i)</a>', 2);
					linkContent = linkTailParts[0];
					htmlTail = linkTailParts[1];
				}				
				if (linkAttributes.toLowerCase().indexOf('apex/wikipage?idwp') != -1) {
					List<String> hrefParts = new List<String>();
					hrefParts = linkAttributes.split('(?i)href=[^>]*apex/wikipage\\?idwp=',2);
					List<String> idParts = new List<String>();
					idParts = hrefParts[1].split('"',2);
					idWikiLink = idParts[0].trim().replaceAll('&quot[^>]', '');
					
					wikiPageIds.add(idWikiLink);
				}
				htmlIds =  htmlLinkParts[0] + htmlTail;	
			}else  {
				htmlIds = htmlLinkParts[0] + htmlLinkParts[1];
			}
		}
		
		Map<String, WikiPage__c> wikiPageLinksMap = new Map<String, WikiPage__c>();
		for (WikiPage__c iterWiki : [select id, Name, Wiki__c, Wiki__r.Name, Wiki__r.Id from WikiPage__c where id in:wikiPageIds]) {
			wikiPageLinksMap.put(iterWiki.Id, iterWiki);
		}
		while (html.toLowerCase().indexOf(linkString) != -1) {
			String linkAttributes = '';
			String linkTail = '';
			String linkContent = '';
			String htmlTail = '';
			String idWikiLink = '';
			String idAttach = '';
			
			List<String> htmlLinkParts = new List<String>();
			htmlLinkParts = html.split('(?i)' + linkString,2);
			if (htmlLinkParts[1].indexOf('>') != -1) {
				List<String> linkParts = new List<String>();
				linkParts = htmlLinkParts[1].split('>', 2);
				linkAttributes = linkParts[0].trim();
				linkTail = linkParts[1];
				
				List<String> linkTailParts = new List<String>();
				if (linkTail.toLowerCase().indexOf('</a>') != -1) {
					linkTailParts = linkTail.split('(?i)</a>', 2);
					linkContent = linkTailParts[0];
					htmlTail = linkTailParts[1];
				}
				
				if (linkAttributes.toLowerCase().indexOf('apex/wikipage?idwp') != -1) {
					List<String> hrefParts = new List<String>();
					hrefParts = linkAttributes.split('(?i)href=[^>]*apex/wikipage\\?idwp=',2);
					List<String> idParts = new List<String>();
					idParts = hrefParts[1].split('"',2);
					idWikiLink = idParts[0].trim().replaceAll('&quot[^>]', '');
					
					WikiPage__c wiki = wikiPageLinksMap.get(idWikilink);
					if (linkContent.trim().replaceAll('(?i)<br>', '') != '') {
						html =  htmlLinkParts[0] + '[['+ wiki.Wiki__r.name + ':' + wiki.name + ']]' + htmlTail;
					}
					else {
						html =  htmlLinkParts[0] + htmlTail;
					}	
				}else {
					if (linkAttributes.toLowerCase().indexOf('servlet/servlet.filedownload?file=') != -1) {
						List<String> hrefParts = new List<String>();
						hrefParts = linkAttributes.split('(?i)href=[^>]*servlet/servlet.filedownload\\?file=',2);
						List<String> idParts = new List<String>();
						idParts = hrefParts[1].split('"',2);
						idAttach = idParts[0].trim().replaceAll('(?i)&quot[^>]', '');
						
						if (linkContent.trim().replaceAll('(?i)<br>', '') != '' && attachmentsMap.get(idAttach) != null) {
							Attachment attch = attachmentsMap.get(idAttach);
							html =  htmlLinkParts[0] + '[File:'+ attch.name + ']' + htmlTail;
						}else {
							html =  htmlLinkParts[0] + htmlTail;
						}
					}else {
						if (linkAttributes.toLowerCase().indexOf('newchildprefield(') != -1) {
							List<String> newChildParts = new List<String>();
							newChildParts = linkContent.split('(?i) Page ', 2);
							html =  htmlLinkParts[0] + '[[' + newChildParts[1].trim() + ']]' + htmlTail;
						}else {
							
							if (linkAttributes.toLowerCase().indexOf('href="http') != -1 || linkAttributes.toLowerCase().indexOf('href="../') != -1) {
								List<String> hrefParts = new List<String>();
								hrefParts = linkAttributes.split('(?i)href="',2);
								List<String> idParts = new List<String>();
								idParts = hrefParts[1].split('"',2);
								idAttach = idParts[0].trim().replaceAll('(?i)&quot[^>]', '');
								if (linkContent.trim().replaceAll('(?i)<br>', '') != '') {
									if (linkAttributes.toLowerCase().indexOf('href="../') != -1) {
										html =  htmlLinkParts[0] + '[' + linkContent.trim().replaceAll('<br>', '') + ' ' + linkContent.trim().replaceAll('<br>', '') + ']'+ htmlTail;
									}else {
										html =  htmlLinkParts[0] + '[' + idParts[0].trim() + ' ' + linkContent.trim().replaceAll('<br>', '') + ']'+ htmlTail;
									}
									
								}else {
									html =  htmlLinkParts[0] + htmlTail;
								}
							}else {
								if (linkAttributes.toLowerCase().indexOf('href=') == -1) {
									html =  htmlLinkParts[0] + htmlTail;	
								}else {
									List<String> hrefParts = new List<String>();
									hrefParts = linkAttributes.split('(?i)href="',2);
									List<String> idParts = new List<String>();
									idParts = hrefParts[1].split('"',2);
									String wikiPageName = idParts[0].trim().replaceAll('(?i)&quot[^>]', '');
									html =  htmlLinkParts[0] + '[[' + wikiPageName.replaceAll('<br>', '').replaceAll('%20', ' ') + ']]'+ htmlTail;
								}
							}
						}
					}	
				}
			}else  {
				html= htmlLinkParts[0] + htmlLinkParts[1];
			}
		}
   		
   		/* ------------------------ */
 		/* 			Tables	 		*/
 		String tableStart = '{|';
 		String tableEnd = '|}';
 		String tableCaption = '|+';
 		String tableRow = '|-';
 		String tableHeader = '!';
 		String tableData = '|';
 		
 		while (html.toLowerCase().indexOf('<table') != -1) {
 			List<String> htmlParts = new List<String>();
 			htmlParts = html.split('(?i)<table',2);
 			
 			String tableContent = '';
 			String htmlHead = '';
 			String htmlTail = '';
 			
 			if (htmlParts[0] != null) {
 				htmlHead = htmlParts[0];
 			}
 			if (htmlParts[1].toLowerCase().indexOf('</table>') != -1) {
 				List<String> htmlTailParts = new List<String>();
 				htmlTailParts = htmlParts[1].split('(?i)</table>', 2);
 				htmlTail = htmlTailParts[1];
 				
 				tableContent = htmlTailParts[0];
 				tableContent = tableContent.replaceAll('(?i)<br>','');
 				tableContent = tableContent.replaceAll('(?i)<br/>','');
 				tableContent = tableContent.replaceAll('(?i)\r\n','');
 				
 				//Fix Copy and paste problems 
 				tableContent = tableContent.replaceAll('(?i)\n','');
 				tableContent = tableContent.replaceAll('(?i)\t','');
 				tableContent = tableContent.replaceAll('(?i)>[ ]*<','><');
 				//Fix Copy and paste problems
 				
 				tableContent = tableContent.replaceAll('(?i)class=" FCK__ShowTableBorders"','');
 				tableContent = tableContent.replaceAll('(?i)class=[^ ^>]*','');
 				tableContent = tableContent.replaceFirst('(?i)>[ ]*','\n');
 				tableContent = tableContent.replaceAll('(?i)[ ]*<tbody>','');
 				tableContent = tableContent.replaceAll('(?i)</tbody>[ ]*','');
 				tableContent = tableContent.replaceAll('(?i)</td>[ ]*','\n');
 				tableContent = tableContent.replaceAll('(?i)</th>[ ]*','\n');
 				tableContent = tableContent.replaceAll('(?i)</tr>[ ]*','');
 				tableContent = tableContent.replaceAll('(?i)[ ]*<tr>','|-\n');
 				tableContent = tableContent.replaceAll('(?i)[ ]*<td>','|');
 				tableContent = tableContent.replaceAll('(?i)[ ]*<th>','!');
 				
 				if (tableContent.toLowerCase().indexOf('<caption') != -1) {
 					if (tableContent.toLowerCase().indexOf('<caption>') != -1) {
 						tableContent = tableContent.replaceAll('(?i)<caption>','|+');
 					}else {
 						tableContent = tableContent.replaceAll('(?i)[ ]*<caption','|+');
 						tableContent = tableContent.replaceFirst('(?i)>[ ]*','|');	
 					}
 					tableContent = tableContent.replaceAll('(?i)</caption>[ ]*','\n');	
 				}
 				while (tableContent.toLowerCase().indexOf('<tr') != -1) {
 					List<String> trParts = new List<String>();
 					trParts = tableContent.split('(?i)[ ]*<tr',2);
 					trParts[1] = trParts[1].replaceFirst('>[ ]*','');	
 					tableContent = trParts[0] + '<tr' + trParts[1];
 					tableContent = tableContent.replaceFirst('(?i)[ ]*<tr','|-');
 				
 					while (tableContent.toLowerCase().indexOf('<td') != -1) {
	 					List<String> tdParts = new List<String>();
	 					tdParts = tableContent.split('(?i)[ ]*<td',2);
	 					tdParts[1] = tdParts[1].replaceFirst('>[ ]*','|');	
	 					tableContent = tdParts[0] + '<td' + tdParts[1];
	 					tableContent = tableContent.replaceFirst('(?i)[ ]*<td','|');	
	 				}
 					while (tableContent.toLowerCase().indexOf('<th') != -1) {
	 					List<String> thParts = new List<String>();
	 					thParts = tableContent.split('(?i)[ ]*<th',2);
	 					thParts[1] = thParts[1].replaceFirst('>[ ]*','|');	
	 					tableContent = thParts[0] + '<th' + thParts[1];
	 					tableContent = tableContent.replaceFirst('(?i)[ ]*<th','!');
	 				}
 				}
 				while (tableContent.toLowerCase().indexOf('<td') != -1) {
	 				List<String> tdParts = new List<String>();
	 				tdParts = tableContent.split('(?i)[ ]*<td',2);
	 				tdParts[1] = tdParts[1].replaceFirst('>[ ]*','|');	
	 				tableContent = tdParts[0] + '<td' + tdParts[1];
	 					
	 				tableContent = tableContent.replaceFirst('(?i)[ ]*<td','|');	
	 			}	
 				while (tableContent.toLowerCase().indexOf('<th') != -1) {
	 				List<String> thParts = new List<String>();
	 				thParts = tableContent.split('(?i)[ ]*<th',2);
	 				thParts[1] = thParts[1].replaceFirst('>[ ]*','|');	
	 				tableContent = thParts[0] + '<th' + thParts[1];
	 				tableContent = tableContent.replaceFirst('(?i)[ ]*<th','!');
	 			}
 				tableContent = tableContent.replaceAll('\n','');
 			}else {
 				htmlTail = htmlParts[1];
 			}
 			html = htmlHead + '{|' + tableContent + '|}' + htmlTail;
 		}
 		
 		html = html.replaceAll('(?i)' + '</p>([ ]*[\r\n]*)*<p>','<br><br>');
 		html = html.replaceAll('(?i)' + '<p>','');
 		html = html.replaceAll('(?i)' + '</p>','<br>');
 		
 	}

	WikiVersions__c editWV;
	
	/**
	* Save changes and redirect
	*@return PageReference
	*/
	public PageReference SaveEdit () {
		parseWiki();
		html = html.replaceAll('&nbsp;',' ');
		
		html = html.replaceAll('(?i)<br>','\n');
		html = html.replaceAll('<[^>]*>', '');
		
		editWV = new WikiVersions__c();
		editWV.Name = editWP.Name;
		editWV.Body__c = html;
		editWV.WikiPageId__c = editWP.Id;
		
		List<WikiVersions__c> oldCountLst = [select revisionCount__c from WikiVersions__c where WikiPageId__c =: editWP.id order by LastModifiedDate desc limit 1];
		
		if (oldCountLst.size() > 0) {
			Double oldCount = oldCountLst[0].revisionCount__c;
			if (oldCount == null) {
				editWV.revisionCount__c = 1;
			}else {
				editWV.revisionCount__c = oldCount + 1;
			}
		}else {
			editWV.revisionCount__c = 1;
		}
	 	//System.debug('\n\n////////////////////////////////////////\n CURRENT SOQL1: ' + Limits.getQueries() + '\n/////////////////////////////\n\n');
 		// out/in Links	
 		List<WikiLink__c> wikiLinksDel = [select Id, Name, FromLink__c, ToLink__c from WikiLink__c where FromLink__c =: editWP.Id];
 		//System.debug('### wikiLinksDel.size[' + wikiLinksDel.size() + ']');
 		List<Id> wikiPagesLinks = new List<Id>();
 		
 		for(WikiLink__c delLinks : wikiLinksDel){
 			wikiPagesLinks.add(delLinks.ToLink__c);
 		}
 		
 		List<WikiPage__c> wikisToUpdate = [select Id, Name, linkCount__c from WikiPage__c where Id in:wikiPagesLinks];
 		Map<Id, WikiPage__c> wikiMap = new Map<Id, WikiPage__c>{};
 		for(WikiPage__c wiki : wikisToUpdate){
 			wikiMap.put(wiki.Id, wiki);
 		}
 		
 		List<WikiPage__c> wikiUpdated = new List<WikiPage__c>();
 		for (WikiLink__c delLink: wikiLinksDel){
 			// UPDATE WIKI LINK COUNT
 			WikiPage__c wikiUpdate1 = wikiMap.get(delLink.ToLink__c);
			wikiUpdate1.linkCount__c = wikiUpdate1.linkCount__c - 1;
			wikiMap.put(delLink.ToLink__c, wikiUpdate1);
 		}
 		
 		delete wikiLinksDel;
 		
 		//System.debug('\n\n////////////////////////////////////////\n CURRENT SOQL2: ' + Limits.getQueries() + '\n/////////////////////////////\n\n');
 		
 		String wikiBodyCode;
 		wikiBodyCode = html;
 		List<WikiLink__c> listWikiLinkOut = new List<WikiLink__c>();
 		String intLink = '[[';
 		/**
 		List<String> temp;
 		String intL = '\\[\\[';
 		temp = wikiBodyCode.split(intL , 2);
 		Map<Integer, List<String>> allLinks;
 		List<String> listNameLink;
 		Integer mapIndex = 0;
 		while(wikiBodyCode.lastIndexOf(intLink) != -1){
 			if (temp[1].indexOf(']]') != -1) {
	 			if (linkContent.indexOf(':') != -1) {
		 			List<String> linkParts = new List<String>();
		 			linkParts = linkContent.split(':',2);
		 			listNameLink.add(linkParts[1].trim());
		 			listNameLink.add(linkParts[0].trim());
		 			allLinks.put(mapIndex, listNameLink);
		 		}else {
		 			listNameWiki.add(linkContent.trim());
		 		}
		 	}else {
 				wikiBodyCode = temp[0] + temp[1];
 			}
 		}
 		
 		if(listNameWiki.size() > 0){
 			
 		}*/
 		
 		String tempWikiBodyCode = wikiBodyCode;
 		
 		while (tempWikiBodyCode.lastIndexOf(intLink) != -1) {
 			List<String> temp;
 			String intL = '\\[\\[';
 			temp = tempWikiBodyCode.split(intL , 2);
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
		 		}else {
		 			nameWiki = linkContent.trim();
		 		}
		 		if (nameWiki != '') {
			 		WikiPage__c wiki = new WikiPage__c();
			 		String idTeamLink = '';
			 		Integer countWs;
			 		if (nameTeam == '') {
			 			idTeamLink = idWikiSite;	
			 			nameTeamList.add(nameCurrentTeam);
			 		}else {
			 			nameTeamList.add(nameTeam);
			 		}
			 		
			 		nameWikiList.add(nameWiki);
			 		
		 		}
		 		tempWikiBodyCode = temp[0] + temp2[1];	
 			}else {
 				tempWikiBodyCode = temp[0] + temp[1];
 			}
 		} 
 		
 		List<WikiPage__c> linkWikis = [select id , Wiki__r.Name, Wiki__r.Id, Name, linkCount__c from WikiPage__c where name in: nameWikiList and Wiki__r.Name in: nameTeamList];
 		nameWikiList.clear();
 		nameTeamList.clear();
 		while (wikiBodyCode.lastIndexOf(intLink) != -1) {
 			List<String> temp;
 			String intL = '\\[\\[';
 			temp = wikiBodyCode.split(intL , 2);
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
		 		}else {
		 			nameWiki = linkContent.trim();
		 		}
		 		if (nameWiki != '') {
			 		WikiPage__c wiki = new WikiPage__c();
			 		String idTeamLink = '';
			 		Integer countWs;
			 		if (nameTeam == '') {	
			 			nameTeam = nameCurrentTeam;
			 		}else {
			 			nameTeamList.add(nameTeam);
			 		}
			 		
			 		List<WikiPage__c> wikiLst = new List<WikiPage__c>();
			 		Integer iterLnkWikis = 0;
			 		List<Integer> indexToDelete = new List<Integer>();
			 		for (WikiPage__c iter : linkWikis) {
			 			if (iter.Name == nameWiki && iter.Wiki__r.Name == nameTeam) {
			 				wikiLst.add(iter);
			 				indexToDelete.add(iterLnkWikis);
			 			}
			 			iterLnkWikis++;
			 		}
			 		
			 		for (Integer toDel: indexToDelete){
			 			linkWikis.remove(toDel);
			 		}
			 		
			 		for (WikiPage__c iter2 : wikiLst) {
			 			wiki = wikiLst[0];
				 		String id;
				 		id = wiki.Id; 
				 		
					 	WikiLink__c wikiLinkOut = new WikiLink__c();
						wikiLinkOut.FromLink__c = editWP.Id;
						wikiLinkOut.ToLink__c = id;
						wikiLinkOut.Name = editWP.Name;
						listWikiLinkOut.add(wikiLinkOut);
						// UPDATE WIKI LINK COUNT
						WikiPage__c tmpLnkCntWP = new WikiPage__c();
						if(wikiMap.containsKey(id)){
							tmpLnkCntWP = wikiMap.get(id);
						}else {
							tmpLnkCntWP = wiki;
						}
						tmpLnkCntWP.linkCount__c = tmpLnkCntWP.linkCount__c + 1;
						wikiMap.put(tmpLnkCntWP.id, tmpLnkCntWP);
						//System.debug('\n\n////////////////////////////////////////\n CURRENT SOQL: ' + Limits.getQueries() + '\n/////////////////////////////\n\n');
			 		}
		 		}
		 		wikiBodyCode = temp[0] + temp2[1];	
 			}else {
 				wikiBodyCode = temp[0] + temp[1];
 			}
 		} 
 		
 		update wikiMap.values();
 		// UPDATE WIKI LINK COUNT
		upsert listWikiLinkOut;
		insert editWV;		
		editWP.Body__c = html;
		update editWP;
		
		PageReference pageRef = Page.WikiPage;
		pageRef.getParameters().put('idWP', editWP.Id);
		pageRef.setRedirect(true);
		return pageRef;
	} 
	
	public PageReference CancelEdit () {
		PageReference pageRef = Page.WikiPage;
		pageRef.getParameters().put('idWP', editWP.Id);
		pageRef.setRedirect(true);
		return pageRef;	
	}
	
   	/**
   	* Return the Wiki Site's name for breadcrumbin
   	*@return String
   	*/
	public String getWikiSiteName () {
		String teamName = '';
		if (idWikiSite != null) {
			Wiki__c teamNameResult = [select id, Name from Wiki__c where id=:idWikiSite];
			Schema.DescribeSObjectResult dsor = Wiki__c.sObjectType.getDescribe();
			if (teamNameResult != null) {
				teamName = '<a href="/apex/WikiOverview?save_new=1">' + dsor.labelPlural + '</a> > <a href="/apex/WikiTeamOverview?tid=' + teamNameResult.Id + '">' + teamNameResult.name + '</a> > ';	
			}
		}
		return teamName;
	}
	
   	/**
   	* Return the breadcrumbin
   	*@return String
   	*/
	public String getBreadCrumbing () {
	   	WikiPage__c wikiBC;
	   	String breadCrumbing = '';
	   	String parentBC = null;
		Integer crumbingLength = 1;
		Integer crumbingMaxLength = 2;
		
   		wikiBC = [SELECT Id, Name, ShortDescription__c, Body__c, Parent__c, LastModifiedDate FROM WikiPage__c WHERE id = : idWikiPage ];
   		parentBC = wikiBC.Parent__c;
	   	while (parentBC != null) {
	   		wikiBC = [select Name, Id, Parent__c from WikiPage__c where id =:parentBC];
	   		parentBC = wikiBC.Parent__c;
	   		String trunkName;
	   		if (wikiBC.Name.length() > 25) {
	   			trunkName = wikiBC.Name.substring(0,23) + '..';
	   		}else {
	   			trunkName = wikiBC.Name; 	
	   		}
	   		if (crumbingLength < crumbingMaxLength) {
	   			breadCrumbing = '<a href="/apex/WikiPage?idWP=' + wikiBC.Id + '" style="text-decoration:underline; cursor:pointer;" >' + trunkName + '</a> > ' + breadCrumbing;
	   		}else {
	   			if (parentBC == null) {
	   				breadCrumbing = '<a href="/apex/WikiPage?idWP=' + wikiBC.Id + '" style="text-decoration:underline; cursor:pointer;" >' + trunkName + '</a> > ' + breadCrumbing;
	   			}else {
	   				if (crumbingLength == crumbingMaxLength) {
	   					breadCrumbing = ' .. > ' + breadCrumbing;
	   				}
	   			}
	   		}
	   		crumbingLength++;
	   	}
	   	return breadCrumbing;
	}
	
   	/**
   	* Inner class for Info wiki type
   	*@class
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
            if (name.length() > 25) {
            	this.name = name.substring(0,23) + '..';
            }else {
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
        *@param Id
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
                                        
	} 
   	
   	/**
   	*@return Boolean
   	*/
	public Boolean getInfo () {
		return this.Info;
	}   	
   	
   	/**
   	* Set false to 'info'
   	*/
	public void okInfo () {
		info = false;
	}
	
	/**
	* Generate wiki's info and set 'info' to true
	*/
   	public void infoGen () {
   		
   		WikiPage__c wiki;
		String idInfo = idWikiPage;
			
    	if (idInfo == '0' || idInfo == null) {
    		wiki = [SELECT Name, ShortDescription__c, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate  From WikiPage__c WHERE Name = 'Home' AND Wiki__c =: idWikiSite  ];	
    	}else {
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
			
		info = true;
	}    		
   	
   	/**
   	*@return Info infoWiki
   	*/
 	public Info getInfoWiki () {
 		return infoWP;
 	}		 	
}
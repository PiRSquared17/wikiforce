/**
*@author Alvaro Scuccimarra @ 03/10/2009
* Last modified  Ignacio Toledo @ 03/24/2009
*/
public class ParseHtml {
	public String html=null;
	private String idWikiPage=null;
	WikiPage__c	wikiPageBody;
	
	static String noparsedOpen = '{{{';	
 	static String noparsedClose = '}}}';
 	static String splitOpen = '\\{\\{\\{';
 	static String splitClose = '\\}\\}\\}';
 	static String replacementCode = '%-%-%-%';
 	static List<String> noparsedText = new List<String>();
 	
 	static Integer countCode = 0;
 	
	
	
	public void setHtml(String html){
		this.html=html;
	}
	
	public String getHtml(){
		return this.html;	
	}
	
	public void setIdWikiPage(String id){
		this.idWikiPage=id;
	}

	
	/**	
	* parses Code (No parsed) 	
	*/
	private void parseCode(){
	 		
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
	}
	
	private void parseNoWiki(){

		/* ------------------------ */
 		/* 		Code (No parsed) 	*/
 		
 		String codeText = this.getHtml();
 		
 		while (codeText.lastIndexOf(replacementCode) != -1) {
	 		codeText = codeText.replaceFirst(replacementCode,'<table style="border: 1px solid rgb(175, 175, 175); padding: 20px; background-color: rgb(250, 250, 250);"><tbody><tr><td>' + noparsedText.get(countCode) + '<span></span></td></tr></tbody></table>');
 			countCode++;
 		} 		
 		html = codeText;
	}
	
	/**
	* parse Tables
	*/
	private void parseTables(){
	
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
				
				System.debug('tableContent' + tailParts[0]);
								
				tailHtml = tailParts[1];
				
				System.debug('tailHtml' + tailHtml);
				
				if (tableContent != '') {
					if (tableContent.toLowerCase().indexOf('<br />') != -1) {
						List<String> tableAttParts = new List<String>();
						tableAttParts = tableContent.split('<br />',2);
						List<String> tableAtts = new List<String>();
						bodyTable = tableAttParts[1].trim();
						
						// If the table has attributes
						if (tableAttParts[0].length() != 0) 
							tableTag += tableAttParts[0].trim(); //support all attributes
					}
					tableTag += '>';
					
					// If have caption Syntax
					List<String> captionTextParts = new List<String>();
					
					if (bodyTable.toLowerCase().indexOf('<br />') != -1) {
						captionTextParts = bodyTable.substring(2).split('<br />',2);
						
						if (bodyTable.trim().indexOf(tableCaption) == 0 && bodyTable.toLowerCase().indexOf('<br />') != -1) {
							String captionText = captionTextParts[0].trim();
							
							System.debug('captionText: ' + captionText);
							
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
								bodyTable = '<br />' + bodyTable;
							}	
						}
						
						List<String> tableRows = new List<String>();
						if (bodyTable.indexOf(tableRow) != -1) {
							tableRows = bodyTable.split(tableRowExp);	
						}else {
							tableRows.add(bodyTable);
						}
						
						System.debug('tableRows ' + tableRows);
						
						Integer cIndex = 0;
						for (String itemRow : tableRows) {
							
							//String iterRow = itemRow; 
							//Fix for split function
							String iterRow;
							if(cIndex != 0)
								 iterRow = itemRow;
							else
								 iterRow = '<br />' + itemRow;
							
							cIndex++;
							
							List<String> rowAtt = new List<String>();
							rowAtt = iterRow.split('<br />',2);
							
							System.debug('rowAtt[0]: '  +  rowAtt[0]);
							System.debug('rowAtt[1]: '  +  rowAtt[1]);
							
							
							
							if (rowAtt.size() == 2) {
								tableTag += '<tr ';
								if (rowAtt[0] != '' && rowAtt[0] != null ) 
									//tableTag += rowAtt[0].trim();

								tableTag += '>';
								System.debug('iterRow PRE: ' + iterRow);
								iterRow = rowAtt[1].trim();
								
								System.debug('iterRow POST: ' + iterRow);
								for (String itemCell : iterRow.split('<br />')) {
									System.debug('itemCell: ' + itemCell);
									
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
		System.debug('HTML FINAL: ' + html);	
	}
	
	/*
	* parse Headings
	*/
	private void parseHeadings(){

        String headingLevel = '={2,6}';
        
        while(found(headingLevel,html)) {
        	
            String theHeadingTag = getMatch(headingLevel, html);
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
            html = html.replaceFirst(theHeadingTag,'%%%%<a name="' + theContentHeader + '"></a>%%%%<h' + hLevel + '>');
            html = html.replaceFirst(theHeadingTag,'</h' + hLevel + '><hr />'); 
        }
	}
	
	// Created By Miguel Angel Sosa - 13.01.09
	// Last Modified ----
	/////////////////////////////////////////////
	/*      Span tag parser     */
	private void parseSpanTags(){
	

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
        String closeActualPropertie;
        
        //Las propiedades
        String nameStylePropertie;
        String valueStylePropertie;

        Integer theCounter = 0;

		System.debug('\n\n ENCUENTRA TAGPROPERTIE ' + found(tagPropertie,html) + '\n\n');

        while(found(tagPropertie,html)) {
	        if(found(tagPropertie,html)) {
	        	System.debug('\n\n SI ES TRUE DEBERIA ESTAR ACA \n\n');
	            // Obtengo la primer propiedad encontrada
	            //actualPropertie = html.substring(html.indexOf(openerOpenTagPropertie),(html.indexOf(closerOpenTagPropertie)+1));
	            actualPropertie = getMatch(tagPropertie,html);
	            
	            System.debug('\n\n ACTUALPROPERTIE ' + actualPropertie + '\n\n');
	            
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
	
	                closeActualPropertie = '(?i)\\[!' + nameActualPropertie + '\\]';
	                                
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
	
				System.debug('\n\n ACTUAL PROPERTIE' + actualPropertie + '\n\n');
				System.debug('\n\n HTML CODE ' + html + '\n\n');
	            html = html.replaceFirst('(?i)' + actualPropertie,'<span style="' + nameStylePropertie + valueStylePropertie + '; newPropertieHere">');
	            if(nameActualPropertie != '') {
	                html = html.replaceFirst(closeActualPropertie,'</span>');
	            }
	
	            theCounter++;
	        }
        }
	}
	
	/**
	* parse text indent
	*/
	private void parseTextIndent(){
 		
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
	}
	
	
	/**
	* text align
	*/
	private void parseTextAlign(){
	
		
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
	
	}
	
	/* ------------------------ */
	/* 		UnOrdered List	 	*/
	private void parseUnorderedLists(){
	

 		String listSyntax = '*';
 		Boolean first = true;
 		Boolean last = false;
 		while (html.lastIndexOf(listSyntax) != -1) {	
	 		String listS = '\\*';
	 		List<String> temp;
	 		temp = html.split(listS,2);
	 		System.debug('tempX' + temp);
	 		html = html.replaceFirst(listS , '<li>');
	 		if ((temp[1].indexOf(listSyntax) >= temp[1].toLowerCase().indexOf('<br />') && temp[1].toLowerCase().indexOf('<br />') != -1) || temp[1].indexOf(listSyntax)== -1 ) {
	 			if (temp[1].toLowerCase().indexOf('<br />') == -1) {
	 				temp[1] = '>' 
	 						+ temp[1] 
	 						+ '</li></ul>';
	 				last = true;
	 			}else {	 
	 				List<String> temp2;	
	 				temp2 = temp[1].split('(?i)<br />',2);	
	 				if ((temp2[1].indexOf(listSyntax) < 3) && (temp2[1].indexOf(listSyntax) != -1) ) {	
	 					temp[1] = '>' + temp[1].replaceFirst('(?i)<br />', '</li>');
	 				}else {
	 					temp[1] = '>' + temp[1].replaceFirst('(?i)<br />', '</li></ul>');
	 					last = true;
	 				}
	 			}
	 		}else {
	 			temp[1] = temp[1].replaceFirst(listS,'');
	 			if (temp[1].toLowerCase().indexOf('<br />') == -1) {
	 				temp[1] = ' style="padding-left:10px;">' 
	 						+ temp[1] 
	 						+ '</li></ul>';
	 				last = true;
	 				
	 			}else {	 		
	 				temp[1] = ' style="padding-left:10px;">' 
	 						+ temp[1].replaceFirst('(?i)<br />', '</li>');
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
	}
	
	private void parseOrderedLists(){
	
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
	 		if ((temp[1].indexOf(listSyntaxOL) >= temp[1].toLowerCase().indexOf('<br />') && temp[1].toLowerCase().indexOf('<br />') != -1) || temp[1].indexOf(listSyntaxOL)== -1 ) {
	 			if (temp[1].toLowerCase().indexOf('<br />') == -1) {
	 				temp[1] = '>' + temp[1] + '</li></ol>';
	 				lastOL = true;
	 			}else {	 
	 				List<String> temp2;	
	 				temp2 = temp[1].split('(?i)<br />',2);	
	 				if (temp2[1].indexOf(listSyntaxOL) == 0) {	
	 					temp[1] = '>' + temp[1].replaceFirst('(?i)<br />', '</li>');
	 				}else {
	 					temp[1] = '>' + temp[1].replaceFirst('(?i)<br />', '</li></ol>');
	 					lastOL = true;
	 				}
	 			}
	 		}else {
	 			temp[1] = temp[1].replaceFirst(listS,'');
	 			if (temp[1].toLowerCase().indexOf('<br />') == -1) {
	 				temp[1] = ' style="padding-left:10px;">' + temp[1] + '</li></ol>';
	 				lastOL = true;
	 			}else {	 		
	 				temp[1] = ' style="padding-left:10px;">' + temp[1].replaceFirst('(?i)<br />', '</li>');
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
	
	}
	
	private void parseExternalLinks(){
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
	}
	
	private void parseEmbeddedImages(){
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
	}
	
	private void parseEmbeddedFiles(){
	
		/* ------------------------ */
 		/* 		Embedded File		*/ 
 		
 		Map<String, Attachment> attachmentsMap = new Map<String, Attachment>();
 		
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
	}
	
	private void parseInternalLinks(){
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
			 			//teamNamesList.add(editWP.Wiki__r.Name);	
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
		 			//nameTeam = editWP.Wiki__r.Name;
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
	}
	
	private void parseTOC(){
		/* ------------------------ */
 		/* 	   Table of Content 	*/ 	
 		
 		String toc = '';
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
	}
	
	
	
	private void parseEmoticons(){
	
		/* ------------------------ */
 		/* 		  Emoticons 		*/		
 		
 		/* ------------------------ */
 		/* 			Emoticons	 	*/
 		String resourceId = '1211555009000';
		String surprised = ':\\|';
		html = html.replaceAll(surprised , '<img src=\'/resource/' + resourceId + '/FCKeditor/fckeditor/editor/images/smiley/msn/whatchutalkingabout_smile.gif\'>');
		
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
	
	public void parseHtml(){
    	
		html = html.replaceAll('\n','<br />');
 		
 		parseTables();
 		parseCode();
	
		parseHeadings();
        parseSpanTags();
 		parseTextIndent();
 			
  		/* ------------------------ */
 		/* 		Horizontal Line 	*/
 		String line = '----';
 		html = html.replace(line ,'<hr />');

		parseTextAlign();
 		
   		parseUnorderedLists();
 		
   		parseOrderedLists();
 		
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

 		parseExternalLinks();
 				
 		parseEmbeddedImages();
 		
 		parseEmbeddedFiles();
 		 		
 		parseInternalLinks();
  		
  		parseTOC();	
 		
 		parseNoWiki();
 		
 		parseEmoticons();
 		
 	}

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
        List<String> tempBeforeAndAfterString = new List<string>();
        
        if(theString.trim().split(regExp,2).size() > 1) {

			System.debug('\n\n La expresion regExp' + regExp + '\n\n');

            //List<string> tempBeforeAndAfterString = theString.trim().split(regExp,2);
			tempBeforeAndAfterString = theString.trim().split(regExp,2);
			
            beforeString = tempBeforeAndAfterString[0].trim();
            beforeString = beforeString.replaceAll('\\(','\\\\(');
            beforeString = beforeString.replaceAll('\\)','\\\\)');
            beforeString = beforeString.replaceAll('\\]','\\\\]');
            beforeString = beforeString.replaceAll('\\[','\\\\[');
            beforeString = beforeString.replaceAll('\\{','\\\\{');
            beforeString = beforeString.replaceAll('\\}','\\\\}');
            beforeString = beforeString.replaceAll('\\*','\\\\*');
            beforeString = beforeString.replaceAll('\\.','\\\\.');
            beforeString = beforeString.replaceAll('\\?','\\\\?');
            beforeString = beforeString.replaceAll('\\|','\\\\|');
            beforeString = beforeString.replaceAll('\\^','\\\\^');
            beforeString = beforeString.replaceAll('\\$','\\\\$');
            
            afterString = tempBeforeAndAfterString[1].trim();
            afterString = afterString.replaceAll('\\(','\\\\(');
            afterString = afterString.replaceAll('\\)','\\\\)');
            afterString = afterString.replaceAll('\\[','\\\\[');
            afterString = afterString.replaceAll('\\]','\\\\]');
            afterString = afterString.replaceAll('\\{','\\\\{');
            afterString = afterString.replaceAll('\\}','\\\\}');
            afterString = afterString.replaceAll('\\*','\\\\*');
            afterString = afterString.replaceAll('\\.','\\\\.');
            afterString = afterString.replaceAll('\\?','\\\\?');
            afterString = afterString.replaceAll('\\|','\\\\|');
            afterString = afterString.replaceAll('\\^','\\\\^');
            afterString = afterString.replaceAll('\\$','\\\\$');
            
            System.debug('\n\n theString ' + theString + '\n\n');
            System.debug('\n\n beforeString ' + beforeString + '\n\n');
            System.debug('\n\n afterString ' + afterString + '\n\n');
            
            tempString = theString.replaceFirst(beforeString,'');
                        
            System.debug('\n\n tempString sin beforeString ' + tempString + '\n\n');
            
            tempString = tempString.trim().replaceAll(afterString.trim(),'');
            
            System.debug('\n\n tempString sin afterString ' + tempString + '\n\n');
            
            regExpResult = tempString.trim();
        
            return regExpResult.trim();
        } else {
            return theString.trim();
        }
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

	private Boolean found(String regExp, String theString) {
	        regExp = regExp.toLowerCase();
	        //System.debug('El indice de ' + getMatch(regExp,theString) + ' dentro de ' + theString + ' es ' + theString.indexOf(getMatch(regExp,theString)));
	        if(theString.trim().split(regExp,2).size() > 1) {
	            return true;
	        } else {
	            return false;
	        }
	}
}
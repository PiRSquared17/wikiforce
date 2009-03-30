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
		html = replace.content;
 		
  		
 		ParseHtml ph =new ParseHtml();
 		ph.setHtml(html);
 		ph.setIdWikiPage(idWikiPage);
 		
 		ph.parseHtml();
 		html=ph.html;
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
 		html = html.replaceAll('[\n\r]','<br />');
 		
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
						html =  htmlLinkParts[0] + '[[' + wiki.Wiki__r.Name + ':' + wiki.Name + ']]' + htmlTail;
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
 				tableContent = tableContent.replaceAll('(?i)<br />','');
 				tableContent = tableContent.replaceAll('(?i)<br/>','');
 				//tableContent = tableContent.replaceAll('(?i)\r\n','');
 				
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
 				tableContent = tableContent.replaceAll('(?i)</tr>[ ]*','\n');
 				tableContent = tableContent.replaceAll('(?i)[ ]*<tr>','<br />|-\n');
 				tableContent = tableContent.replaceAll('(?i)[ ]*<td>','<br />|');
 				tableContent = tableContent.replaceAll('(?i)[ ]*<th>','!');
 				
 				
 				
 				if (tableContent.toLowerCase().indexOf('<caption') != -1) {
 					if (tableContent.toLowerCase().indexOf('<caption>') != -1) {
 						tableContent = tableContent.replaceAll('(?i)<caption>','<br />|+');
 					}else {
 						tableContent = tableContent.replaceAll('(?i)[ ]*<caption','<br />|+');
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
	 				tdParts[1] = tdParts[1].replaceFirst('>[ ]*','lc2|');	
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
	 			tableContent = tableContent.replaceFirst('<br />\\|-', '');
 				//tableContent = tableContent.replaceAll('\n','');
 			}else {
 				htmlTail = htmlParts[1];
 			}
 			html = htmlHead + '{|' + tableContent + '<br />|}' + htmlTail;
 		}
 		
 		html = html.replaceAll('(?i)' + '</p>([ ]*[\r\n]*)*<p>','<br /><br />');
 		html = html.replaceAll('(?i)' + '<p>','');
 		html = html.replaceAll('(?i)' + '</p>','<br />');
 		
 	}

	WikiVersions__c editWV;
	
	/**
	* Save changes and redirect
	*@return PageReference
	*/
	public PageReference SaveEdit () {

		parseWiki();
		html = html.replaceAll('&nbsp;',' ');
		html = html.replaceAll('&#43;','+');
		
		html = html.replaceAll('(?i)<br>','\n');
		html = html.replaceAll('<[^>]*>', '');
		
		TeamUtil.hostName = TeamUtil.getHost(ApexPages.currentPage());
		
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
 			//wikiPagesLinks.add(delLinks.ToLink__c);
 		}
 		
 		List<WikiPage__c> wikisToUpdate = [select Id, Name, linkCount__c from WikiPage__c where Id in:wikiPagesLinks];
 		Map<Id, WikiPage__c> wikiMap = new Map<Id, WikiPage__c>{};
 		for(WikiPage__c wiki : wikisToUpdate){
 			wikiMap.put(wiki.Id, wiki);
 		}
 		
 		List<WikiPage__c> wikiUpdated = new List<WikiPage__c>();
 		if( wikiLinksDel.size() > 0 && wikiMap.size() > 0 ) 
 		{
	 		for (WikiLink__c delLink: wikiLinksDel)
	 		{
	 			// UPDATE WIKI LINK COUNT
	 			WikiPage__c wikiUpdate1 = wikiMap.get(delLink.ToLink__c);
				wikiUpdate1.linkCount__c = wikiUpdate1.linkCount__c - 1;
				wikiMap.put(delLink.ToLink__c, wikiUpdate1);
	 		}
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
						
						tmpLnkCntWP.linkCount__c += 1;
						System.debug( '|||:' + tmpLnkCntWP.linkCount__c );
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
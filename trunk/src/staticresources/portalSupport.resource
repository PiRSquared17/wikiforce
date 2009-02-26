var PageStyles = null;
/**
* Portal Rules Object
*/
function Portal() {
	//Tabs Properties
	this.TabCurrentTabTextColor = '';
	this.TabCurrentTabBackground = '';
	this.TabCurrentTabBorderColor = '';
	this.TabOtherTabTextColor = '';

	//Page Properties
	this.PageBackground = '';
	this.PageFontFamily = '';
	this.PageTextFontSize = '';
	this.PageTextColor = '';
	this.PageLinkColor = '';
	this.PageLinkColorHover = '';
	this.PageFieldLabelFontFamily = '';
	this.PageFieldLabelFontColor = '';
	this.PageFieldSeparatorColor = '';
	this.PageBorderBottom = '';

	//Section Properties
	this.SectionHeaderBackground = '';
	this.SectionHeaderTextFontFamily = '';
	this.SectionHeaderTextFontColor = '';
	this.SectionBorderRight = '';
	this.SectionBorderLeft = '';
	this.SectionBorderBottom = '';
	this.SectionBorderTop = '';
	this.SectionBackground = '';

	//List Properties
	this.ListHeaderText = '';
	this.ListHeaderUnderline = '';
	this.ListHighlightRow = '';
	this.ListBorderBottom = '';
	this.ListHeaderFontFamily = '';
}
var Portal = new Portal();
/**
* Get portal.css rules.
*@void
*/
function readPortalCSSRules() {
	// ### Apply Body Id for current module
	applyBodyId();
	
	var styles  = document.styleSheets;
	var portal  = null;
	var rules   = null;
	var propAll	= '';
	var settingProp = new Array();
	//Find portal.css
	for(var it = 0; it < styles.length; it++){
		if(styles[it].href){
			if(styles[it].href.split('portal.css').length > 1){
				portal = styles[it];
				break;
			}
		}
	}

	if(portal){
		//Browser detection
		if (document.all)
			rules = portal.rules;
		else
			rules = portal.cssRules;	
			
		//Iterate style rules
		for(it = 0; it < rules.length; it++){
			//Normalize Selector
			selector = trim(rules[it].selectorText.replace(/[*|]/g, '').toLowerCase());
			propAll += selector + '<br />'
			
			//# Get Tabs Settings
			// Tabs Current Tab Text Color
			if(selector.search('body .currenttab a') > -1){
				if(!Portal.TabCurrentTabTextColor)	
					Portal.TabCurrentTabTextColor = rules[it].style.color;
			}
			//Tabs Current Tab Background
			if(selector == '.tabnavigation'){
				if(!Portal.TabCurrentTabBackground)
					Portal.TabCurrentTabBackground = rules[it].style.backgroundImage;
			}
			//Tabs Border Color
			if(selector == '.tab td'){
				if(!Portal.TabCurrentTabBorderColor)
					Portal.TabCurrentTabBorderColor = rules[it].style.borderBottomColor;
			}
			// Tabs Other Tab Text Color
			if(selector.search('body .tab a') > -1){
				if(!Portal.TabOtherTabTextColor)
					Portal.TabOtherTabTextColor = rules[it].style.color;
			}
			//# Get Page Settings
			//Page Background
			if(selector == trim('.bodydiv')){
				if(!Portal.PageBackground)
					Portal.PageBackground = rules[it].style.backgroundColor;
				if(!Portal.PageBorderBottom) 	                    	
					Portal.PageBorderBottom = rules[it].style.borderBottom;
			}
			//Page Text Font
			if(selector == trim('body')){
				if(!Portal.PageFontFamily)
					Portal.PageFontFamily = rules[it].style.fontFamily;
				if(!Portal.PageTextFontSize)
					Portal.PageTextFontSize = rules[it].style.fontSize; 
			}
			//Page Text Color
			if(selector.search('.bwizardblock .pbtopbuttons') > -1){
				if(!Portal.PageTextColor)	                    	
					Portal.PageTextColor = rules[it].style.color;
			}
			//Page Field Label Text
			if(selector.search(".bpageblock .labelcol a") > -1){
				if(!Portal.PageFieldLabelFontFamily)	                    	
					Portal.PageFieldLabelFontFamily = rules[it].style.fontFamily;
				if(!Portal.PageFieldLabelFontColor)
					Portal.PageFieldLabelFontColor = rules[it].style.color;
			}
			//Page Link
			if(selector.search('.minitab .currenttab a') > -1){
				if(!Portal.PageLinkColor)	                    	
					Portal.PageLinkColor = rules[it].style.color;
			}
			//Page Link Hover
			if(selector.search('.minitab .currenttab a:hover') > -1){
				if(!Portal.PageLinkColorHover)                   	
					Portal.PageLinkColorHover = rules[it].style.color;
			}
			//Page Field Separator
			if(selector.search('.bpageblock .detaillist tr th') > -1){
				if(!Portal.PageFieldSeparatorColor)
					Portal.PageFieldSeparatorColor = rules[it].style.borderBottomColor;
			} 
			//# Get Section Settings
			//Section Header Background
			if(selector.search('.bpageblock .pbheader') > -1){
				if(!Portal.SectionHeaderBackground)
					Portal.SectionHeaderBackground = rules[it].style.backgroundColor;
			}                 	
			//Section Header Text
			if(selector.search('.nestedmodule .sidebarmoduleheader') > -1){
				if(!Portal.SectionHeaderTextFontFamily)
					Portal.SectionHeaderTextFontFamily = rules[it].style.fontFamily;
				if(!Portal.SectionHeaderTextFontColor)
					Portal.SectionHeaderTextFontColor = rules[it].style.color;
			} 
			//Section Borders
			if(selector == trim('.bsubblock')){
				if(!Portal.SectionBorderLeft)
					Portal.SectionBorderLeft = rules[it].style.borderLeft;
				if(!Portal.SectionBorderRight)
					Portal.SectionBorderRight = rules[it].style.borderRight;
				if(!Portal.SectionBorderBottom)
					Portal.SectionBorderBottom = rules[it].style.borderBottom;
				if(!Portal.SectionBorderTop)
					Portal.SectionBorderTop = rules[it].style.borderTop;                  			                  			
			}
			//Section Background
			if(selector == trim('.sidebarmodule')){
				if(!Portal.SectionBackground)
					Portal.SectionBackground = rules[it].style.backgroundColor;
			}
			//# Get List Settings
			//List Header
			if(selector.search('.list .headerrow th a') > -1){
				if(!Portal.ListHeaderText)
					Portal.ListHeaderText = rules[it].style.color;
				if(!Portal.ListHeaderFontFamily)
					Portal.ListHeaderFontFamily = rules[it].style.fontFamily;
				if(!Portal.ListHeaderUnderline)
					Portal.ListHeaderUnderline = rules[it].style.borderBottomColor;
			}
			//List Row Highlight
			if(selector.search('.highlight th') > -1){
				if(!Portal.ListHighlightRow)
					Portal.ListHighlightRow = rules[it].style.backgroundColor;
			}
			//List Border Bottom
			if(selector.search('body.oldforecast .list .last th') > -1){
				if(!Portal.ListBorderBottom)
					Portal.ListBorderBottom = rules[it].style.borderBottom;
			}
		}
		applyPortalStyles();				
	}
}

/**
* Apply Portal Styles
*@void
*/
function applyPortalStyles(){
	/* ### Create style object for overwrite default app styles with portal settings ### */
	var head   = document.getElementsByTagName('head')[0];
	var style  = document.createElement('style');
	style.type ='text/css';
	head.appendChild(style);
	var portalStyles = document.styleSheets[document.styleSheets.length - 1];

	/* ### Apply Section Header Styles for WidgetsThin (Sidebar and TeamDetail)### */
	var sectionHeaderThin  =  'background-color:' + Portal.SectionHeaderBackground + ' !important;';
	sectionHeaderThin +=  'color:' + Portal.SectionHeaderTextFontColor + ' !important;';
	sectionHeaderThin +=  'font-family:' + Portal + ' !important';
	if(document.all){
		portalStyles.addRule('div.thinHeader', sectionHeaderThin);
		portalStyles.addRule('div.subHeader', sectionHeaderThin);
	}else{
		portalStyles.insertRule('div.thinHeader' + '{' + sectionHeaderThin + '}', 0);
		portalStyles.insertRule('div.subHeader' + '{' + sectionHeaderThin + '}', 1);
	}
	/* ### Apply Section Header Styles for WidgetsWide [border-bottom] ### */
	var sectionHeaderWide  = 'border-bottom: 4px solid ' + Portal.SectionHeaderBackground + ' !important;';
	sectionHeaderWide += 'color:' + Portal.SectionHeaderBackground + ' !important;';
	sectionHeaderWide += 'font-family:' + Portal + ' !important';				
	if(document.all)
		portalStyles.addRule('div.wideHeader', sectionHeaderWide);
	else
		portalStyles.insertRule('div.wideHeader' + '{' + sectionHeaderWide + '}', 2);
		
	/* ### Page Link Styles ### */
	linkRule = 'color:' + Portal.PageLinkColor + ' !important'
	if(document.all)
		portalStyles.addRule('table.bodyTable a', linkRule);
	else
		portalStyles.insertRule('table.bodyTable a' + '{' + linkRule + '}', 3);
	  
	/* ### Page Link Hover Styles ### */
	linkOhverRule = 'color:' + Portal.PageLinkColorHover + ' !important';
	if(document.all)
		portalStyles.addRule('table.bodyTable a:hover', linkOhverRule);
	else
		portalStyles.insertRule('table.bodyTable a:hover' + '{' + linkOhverRule + '}', 4);              

	/* ### Section Background for ThinWidgets ### */
	var sectionBackground = 'background: ' + Portal.SectionBackground + ' !important';
	var sectionBackgroundColor = 'background-color: ' + Portal.SectionBackground + ' !important';
	if(document.all){
		portalStyles.addRule('div.thinBody', sectionBackground);
		portalStyles.addRule('div.teamWidget', sectionBackgroundColor);
	}else{
		portalStyles.insertRule('div.thinBody' + '{' + sectionBackground + '}', 5);
		portalStyles.insertRule('div.teamWidget' + '{' + sectionBackgroundColor + '}', 6);
	}	
	  
	/* ### Section Background for ThinWidget Footer  ### */
	var sectionFooterWide = 'background-color:' +  Portal.SectionBackground + ' !important';
	if(document.all)
		portalStyles.addRule('div.teamWidget div.bottom_borders', sectionFooterWide);
	else
		portalStyles.insertRule('div.teamWidget div.bottom_borders' + '{' + sectionFooterWide + '}', 7)
			
	/* ### Section Background for WideWidgets ### */          
	if(document.all)
		portalStyles.addRule('div.wideBody', sectionBackground);
	else
		portalStyles.insertRule('div.wideBody' + '{' + sectionBackground + '}', 8);	              
			  
	/* ### Header background ### */
	var headerColor = 'background-color: ' + Portal.SectionHeaderBackground + ' !important';  
	if(document.all){
		portalStyles.addRule('div.header_portal', headerColor);
		portalStyles.addRule('div.header_portal div.legend_portal', headerColor);
		portalStyles.addRule('div.header_portal .search_btn', headerColor);
	}else{
		portalStyles.insertRule('div.header_portal' + '{' + headerColor + '}', 9);				    
		portalStyles.insertRule('div.header_portal div.legend_portal' + '{' + headerColor + '}', 10);				    
		portalStyles.insertRule('div.header_portal .search_btn' + '{' + headerColor + '}', 11);				    								    
	}
	
	/** #### Apply Lists Styles #### */
	var listHeaderBorders = 'border-bottom:' +  Portal.ListHeaderUnderline + '1px solid !important;';
	listHeaderBorders += 'border-top:' +  Portal.ListHeaderUnderline + '1px solid !important;';
	var listBorderBody = 'border-bottom:' + Portal.ListBorderBottom + ' !important;';
	if(document.all){
		portalStyles.addRule('table.pageList thead td', listHeaderBorders);
		portalStyles.addRule('table.pageList tbody td', listBorderBody);
	}else{
		portalStyles.insertRule('table.pageList thead td' + '{' + listHeaderBorders + '}', 12);		
		portalStyles.insertRule('table.pageList tbody td' + '{' + listBorderBody + '}', 13);										
	}
	/** ### Apply styles for other areas ### **/
	var buttonColor = 'background: ' + Portal.SectionHeaderBackground + ' !important'; 
	
	if(document.all){
		portalStyles.addRule('div.options div.button', headerColor);
		portalStyles.addRule('div.holder div.number', headerColor);
		portalStyles.addRule('div.holder div.discussionTopic', headerColor);
	}else{
		portalStyles.insertRule('div.options div.button' + '{' + headerColor + '}', 14);
		portalStyles.insertRule('div.holder div.number' + '{' + headerColor + '}', 15);		
		portalStyles.insertRule('div.holder div.discussionTopic' + '{' + headerColor + '}', 16);
		portalStyles.insertRule('div.buttonSave ' + '{' + buttonColor + '}', 17);
	}
	
	/*** ### Overlays  ###  ***/
	if(document.all){
		portalStyles.addRule('div.overlayTitleContent', headerColor);
		portalStyles.addRule('div.overlayMainContent .overlaySaveBtn', buttonColor);
	}else{
		portalStyles.insertRule('div.overlayTitleContent' + '{' + headerColor + '}', 18);
		portalStyles.insertRule('div.overlayMainContent .overlaySaveBtn' + '{' + buttonColor + '}', 19);
	}
	
	/*** ### Fixes and Clears styles ### ***/
	var fixBodyDiv = 'background-color: transparent !important; border: none !important;';
	if(document.all){
		portalStyles.addRule('div.bodyDiv', fixBodyDiv);
	}else{
		portalStyles.insertRule('div.bodyDiv' + '{' + fixBodyDiv + '}', 20);
	}	
}
/* ### Utiles ### */
/**
* Apply id to body
*@void
*/
function applyBodyId(){
	var heads = $$('.header_portal');
	if(heads.length > 0 ){
		var module = heads[0].id.split('header')[1];
		var body = $$('body')[0];
		body.id = 'body' + module;	
	}
}
/**
* Trim
*@param String
*@return String
*/
function trim(s) {
 var temp = s.replace(/^\s+/, "");
 return temp.replace(/\s+$/, "");
}
//Overwrite rollover methods for template
/**
*@param HTML <TR> object
*@void
*/
function rollOver(tr){
	  tr.style.background = (Portal.ListHighlightRow) ? Portal.ListHighlightRow : '#EFEFEF';
}
/**
*@param HTML <TR> object
*@void
*/			
function rollOut(tr){
	  tr.style.background = '';
}				

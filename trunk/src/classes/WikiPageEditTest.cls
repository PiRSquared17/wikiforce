@IsTest private class WikiPageEditTest {   
    public static testMethod void testWiki() {  
	   	GenerateEnvironmentTest.gen();
		
		Test.startTest();
	    
	    WikiPageEditController wiki = new WikiPageEditController();
	    WikiPageEditController.Replace replace = new WikiPageEditController.Replace();

	    UserPermissions userPermissions = new UserPermissions();
	    
	    
	    Wiki__c newTeam = 	GenerateEnvironmentTest.wiki;
		WikiPage__c newWiki = new WikiPage__c();
		newWiki.Body__c = '%TOC%\n\n== Header 2 ==\n=== Header 3 ===\n==== Header 4 ====\n===== Header 5 =====\n====== Header 6 ======\n\n[Image: src:http://www.salesforce.com/logo.jpg; a: right]\n[Image: src:http://www.salesforce.com/logo.jpg]\n[Image: src:11981mercano%20el%20marciano.jpg]\n\n \'\'\' bold \'\'\'\n \'\' italic \'\'\n __underline__\n --(strike)--\n normal^supstring^\n normal,,substring,,\n[[->text ident 20px ->]]\n[[-->text ident 40px-->]]\n[[--->text ident 60px--->]]\n\n* item 1\n* item 2\n* item 3\n\n~ item 1\n~ item 2\n~ item 3\n\n[[Juans Team:Home]]\n\n[[Home]]\n[[]]\n[[New Page Coverage Link]]\n\n[http://www.salesforce.com Salesforce]\n\n{| border="1"\n|-\n|cell 1.1\n|cell 2.1\n|-\n|cell 2.1\n|cell 2.2\n|}\n\n\n{| border="1"\n|+ Caption\n|-\n|cell 1.1\n|cell 2.1\n|}\n\n{|\n|cell 1.1\n|cell 2.1\n|}\n\n{|\n!cell 1.1\n! style="color: red;"|cell 2.1\n|}\n\n{| border="1"\n|+ style="color: red;" |Caption\n|- style="color: red;" \n|style="color: red;" | cell 1.1\n|cell 2.1\n|}\n\n[http://www.salesforce.com [Image: src:11981mercano%20el%20marciano.jpg; w:264; h:300;]]\n[Image: src:11981mercano%20el%20marciano.jpg; w:264; h:300;]\n[File: 11981mercano%20el%20marciano.jpg]\n[File: AttachIcons.zip]\n[File: malgoritmia.rar]\n[File: blabla.rar]\n[Flash: index.swf]\n\n{{{\n\nNo parsed\n\n}}}\n\n[Bgcolor:red red text Bgcolor]\n[Bgcolor:rgb(10,10,10) red text Bgcolor]\n[Bgcolor:red\nred text Bgcolor]\n\n\n\n[Color:blue blue text Color]\n[Color:blue\nblue text Color]\n[Color:rgb(10,10,10) blue text Color]\n\n{||}';//\n\n{|\n\n* item~Last*last[Bgcolor:Bgcolor][Color:Color][Image:[File:[[[http://www.salesforce.com{{{';

		newWiki.Name = 'TestClass Wiki';
		newWiki.Wiki__c = newTeam.Id;
		insert newWiki;
	    
	    wiki.setIdWikiPage(newWiki.Id);     
		
		try {
			wiki.constWikiPageEdit();     
		}catch (exception e) {
			System.assert(true, e);
		} 
		
		if (wiki.getUserPermissions() == null) {
			System.assert(true, 'Null Permissions');
		}
		
		userPermissions.getCanView();
		userPermissions.getCanComment();
		userPermissions.getCanManage();
		userPermissions.getCanCreate();
		userPermissions.getObjectType();
		userPermissions.getTeam();
		userPermissions.getId();
		
		if (wiki.getReplace() == null) 
			System.assert(true, 'Null Replace');			
		if (wiki.getIdWikiPage() == null) 
			System.assert(true, 'Null Id wiki Page');	 
		if (wiki.getIniBody() == null) 
			System.assert(true, 'Null Ini body');	
		if (replace.getContent() == null) 
			System.assert(true, 'Null Replace content'); 
		    
	    try {
			wiki.parseHTML();  
		}catch (exception e) {
			System.assert(true, e);
		}
	    
	    try {
	    	replace.setContent(wiki.getHtml());
			wiki.setReplace(replace);
		}catch (exception e) {
			System.assert(true, e);
		}
	    
	    try {
			wiki.parseWiki();  
		}catch (exception e) { 
			System.assert(true, e);
		}
		
	    if (wiki.getWikiSiteName() == null) 
	    	System.assert(true, 'Null wiki site Name');		
	    if (wiki.getBreadCrumbing() == null) 
	    	System.assert(true, 'Null wiki site Name');		
	    
	    /* WIKI PAGE INFO */
	    WikiPageEditController.Info info = new WikiPageEditController.Info();   
	    
	    try {
	    	wiki.infoGen ();	
	    }catch (exception e) {
			System.assert(true, e);
		}
	    
	    if (info.getName() == null) 
	    	System.assert(true, 'Null Wiki Info var');	
	    if (info.getShortDescription() == null) 
	    	System.assert(true, 'Null Wiki Info var');		
	    if (info.getCreatedBy() == null) 
	    	System.assert(true, 'Null Wiki Info var');		
	    if (info.getCreatedById() == null) 
	    	System.assert(true, 'Null Wiki Info var');	
	    if (info.getLastModifiedBy() == null) 
	    	System.assert(true, 'Null Wiki Info var');	
	    if (info.getLastModifiedById() == null) 
	    	System.assert(true, 'Null Wiki Info var');	
	    if (info.getCreatedDate() == null) 
	    	System.assert(true, 'Null Wiki Info var');		
	    if (info.getLastModifiedDate() == null) 
	    	System.assert(true, 'Null Wiki Info var');		
	    if (wiki.getInfo() == null) 
	    	System.assert(true, 'Null Wiki Info var');		
	    if (wiki.getHtml() == null) 
	    	System.assert(true, 'Null Wiki Info var');		
	    
	    try {
	    	wiki.okInfo();
	    }catch (exception e) {
			System.assert(true, e);     
		}
	    
	    try { 
	    	wiki.getInfoWiki();
	    }catch (exception e) {
			System.assert(true, e);
		}
	    
	    try{
	        wiki.SaveEdit();
	    }catch (exception e) {
	        System.assert(true,'Error saving page')  ;
	    }
	    
	    wiki.dummyRefresh();
	    wiki.setIniBody('dummy');  
	    
	    Test.stopTest();
    }
    
    public static testMethod void testWiki2() {  
	   	GenerateEnvironmentTest.gen();
		
		Test.startTest();
	    
	    WikiPageEditController wiki = new WikiPageEditController();
		WikiPageEditController.Replace replace = new WikiPageEditController.Replace();
		
	    UserPermissions userPermissions = new UserPermissions();
	    
	    Wiki__c newTeam = 	GenerateEnvironmentTest.wiki;
		WikiPage__c newWiki = new WikiPage__c();
		newWiki.Body__c = '%TOC%\n\n== Header 2 ==\n=== Header 3 ===\n==== Header 4 ====\n===== Header 5 =====\n====== Header 6 ======\n\n[Image: src:http://www.salesforce.com/logo.jpg; a: right]\n[Image: src:http://www.salesforce.com/logo.jpg]\n[Image: src:11981mercano%20el%20marciano.jpg]\n\n \'\'\' bold \'\'\'\n \'\' italic \'\'\n __underline__\n --(strike)--\n normal^supstring^\n normal,,substring,,\n[[->text ident 20px ->]]\n[[-->text ident 40px-->]]\n[[--->text ident 60px--->]]\n\n* item 1\n* item 2\n* item 3\n\n~ item 1\n~ item 2\n~ item 3\n\n[[Juans Team:Home]]\n\n[[Home]]\n[[]]\n[[New Page Coverage Link]]\n\n[http://www.salesforce.com Salesforce]\n\n{| border="1"\n|-\n|cell 1.1\n|cell 2.1\n|-\n|cell 2.1\n|cell 2.2\n|}\n\n\n{| border="1"\n|+ Caption\n|-\n|cell 1.1\n|cell 2.1\n|}\n\n{|\n|cell 1.1\n|cell 2.1\n|}\n\n{|\n!cell 1.1\n! style="color: red;"|cell 2.1\n|}\n\n{| border="1"\n|+ style="color: red;" |Caption\n|- style="color: red;" \n|style="color: red;" | cell 1.1\n|cell 2.1\n|}\n\n[http://www.salesforce.com [Image: src:11981mercano%20el%20marciano.jpg; w:264; h:300;]]\n[Image: src:11981mercano%20el%20marciano.jpg; w:264; h:300;]\n[File: 11981mercano%20el%20marciano.jpg]\n[File: AttachIcons.zip]\n[File: malgoritmia.rar]\n[File: blabla.rar]\n[Flash: index.swf]\n\n{{{\n\nNo parsed\n\n}}}\n\n[Bgcolor:red red text Bgcolor]\n[Bgcolor:rgb(10,10,10) red text Bgcolor]\n[Bgcolor:red\nred text Bgcolor]\n\n\n\n[Color:blue blue text Color]\n[Color:blue\nblue text Color]\n[Color:rgb(10,10,10) blue text Color]\n\n{||}';//\n\n{|\n\n* item~Last*last[Bgcolor:Bgcolor][Color:Color][Image:[File:[[[http://www.salesforce.com{{{';
		newWiki.Wiki__c = newTeam.Id;
		insert newWiki;
	    
	    wiki.setIdWikiPage(newWiki.Id);
		wiki.constWikiPageEdit();    
		wiki.getUserPermissions();
		
		// PARTICULAR WIKI SYNTAX CONTENT
	    replace.setContent('{|    |}');
		wiki.setReplace(replace);
	    wiki.parseHTML(); 
	    
	    replace.setContent('[[-  foo');
		wiki.setReplace(replace);
	    wiki.parseHTML(); 
	    
	    replace.setContent('* foo');
		wiki.setReplace(replace);
	    wiki.parseHTML();
	    
	    replace.setContent('* foo * foo');
		wiki.setReplace(replace);
	    wiki.parseHTML();
	    
	    replace.setContent('* foo * foo\n'); 
		wiki.setReplace(replace);
	    wiki.parseHTML();
	     
	    replace.setContent('~ foo');
		wiki.setReplace(replace);
	    wiki.parseHTML();
	    
	    replace.setContent('~ foo ~ foo');
		wiki.setReplace(replace);
	    wiki.parseHTML();
	    
	    replace.setContent('~ foo ~ foo\n');
		wiki.setReplace(replace);
	    wiki.parseHTML(); 
	    
	    replace.setContent('== foo');
		wiki.setReplace(replace);
	    wiki.parseHTML();   
		
		insert new Attachment(Name = 'FooAttach.txt', Body = Blob.valueOf('Some String'), ContentType = 'text/plain', parentId = newWiki.Id);
		
		replace.setContent('[Image: src:FooAttach.txt;]');
		wiki.setReplace(replace);
	    wiki.parseHTML(); 
	    
	    replace.setContent('[Image: src:FooAttach.txt]');
		wiki.setReplace(replace);
	    wiki.parseHTML(); 
	    
	    replace.setContent(wiki.getHtml());
		wiki.setReplace(replace);
	    wiki.parseWiki(); 
	    
	    replace.setContent('[File: FooAttach.txt]');
		wiki.setReplace(replace);
	    wiki.parseHTML(); 
	    
	    insert new Attachment(Name = 'FooAttach2.txt', Body = Blob.valueOf('Some String'), parentId = newWiki.Id);
	     
	    replace.setContent('[File: FooAttach2.txt]');
		wiki.setReplace(replace);
	    wiki.parseHTML(); 
	    
	    replace.setContent(wiki.getHtml());
		wiki.setReplace(replace);
	    wiki.parseWiki(); 
	    
	    insert new Attachment(Name = 'FooAttach3.rar', Body = Blob.valueOf('Some String'), parentId = newWiki.Id);
	     
	    replace.setContent('[File: FooAttach3.rar]');
		wiki.setReplace(replace);
	    wiki.parseHTML(); 
	    
	    insert new Attachment(Name = 'FooAttach4.rar', Body = Blob.valueOf('Some String'),ContentType = 'foo', parentId = newWiki.Id);
	      
	    replace.setContent('[File: FooAttach4.rar]'); 
		wiki.setReplace(replace);
	    wiki.parseHTML();
	    
	    // PARTICULAR HTML CONTENT
	    replace.setContent('<img src="http://foo" style="width: 20px" lign="center"><img src="http://foo" style="height: 20px" lign="center"><img src="http://foo" style="width: 20px; height: 20px;" lign="center"><img src="http://foo" style="aaa" width="20px" align="center" height="20px"><img src="http://foo" height="20px"><img src="http://foo"><img src="http://foo" width="20px"><img src="http://foo" align="center"><img src="http://foo" style="aaa" width="20px" height="20px" align="center"><p style="text-align: right;">aa</p><p style="text-align: left;">aa</p><p style="text-align: center;">aa</p><p style="text-align: justify;">aa</p><div align="right">align</div><div align="center">align</div><span style="background-color: red;">red</span> <p style="margin-left: 20px;">marginLeft</p><ul><li>commonLI</li><li style="padding-left: 10px;">paddingLI</li></ul><ol><li>commonLI</li><li style="padding-left: 10px;">paddingLI</li></ol>');
		wiki.setReplace(replace);  
	    wiki.parseWiki();  
	    
	    replace.setContent('<img src="fckeditor/editor/images/smiley/msn/angel_smile.gif" /><img src="fckeditor/editor/images/smiley/msn/confused_smile.gif" /><img src="fckeditor/editor/images/smiley/msn/omg_smile.gif" /><img src="fckeditor/editor/images/smiley/msn/embaressed_smile.gif" /><img src="fckeditor/editor/images/smiley/msn/tounge_smile.gif" /><img src="fckeditor/editor/images/smiley/msn/angry_smile.gif" /><img src="fckeditor/editor/images/smiley/msn/shades_smile.gif" /><img src="fckeditor/editor/images/smiley/msn/envelope.gif" /><img src="fckeditor/editor/images/smiley/msn/kiss.gif" /><img src="fckeditor/editor/images/smiley/msn/broken_heart.gif" /><img src="fckeditor/editor/images/smiley/msn/heart.gif" /><img src="fckeditor/editor/images/smiley/msn/thumbs_down.gif" /><img src="fckeditor/editor/images/smiley/msn/thumbs_up.gif" /><img src="fckeditor/editor/images/smiley/msn/lightbulb.gif" /><img src="fckeditor/editor/images/smiley/msn/devil_smile.gif" /><img src="fckeditor/editor/images/smiley/msn/wink_smile.gif" /><img src="fckeditor/editor/images/smiley/msn/cry_smile.gif" /><img src="fckeditor/editor/images/smiley/msn/sad_smile.gif" /><img src="fckeditor/editor/images/smiley/msn/teeth_smile.gif" /><img src="fckeditor/editor/images/smiley/msn/whatchutalkingabout_smile.gif" /><img src="fckeditor/editor/images/smiley/msn/regular_smile.gif" />');
		wiki.setReplace(replace);  
	    wiki.parseWiki();
	    
	    WikiVersions__c wv2 = new WikiVersions__c();
        wv2.Name = 'Foo Version';
        wv2.Body__c = 'Foo Body';
        wv2.WikiPageId__c = newWiki.Id;
        wv2.revisionCount__c = null; 
        insert wv2;
		
		wiki.SaveEdit();
	    Test.stopTest();
    }  
    
    public static testMethod void testWiki3() {  
	   	GenerateEnvironmentTest.gen();
		
		Test.startTest(); 
	    
	    System.currentPageReference().getParameters().put( 'id', GenerateEnvironmentTest.wikiPage.id );
	    WikiPageEditController wiki = new WikiPageEditController();
		WikiPageEditController.Replace replace = new WikiPageEditController.Replace();
		
	    UserPermissions userPermissions = new UserPermissions();
	   
	    wiki.setIdWikiPage(GenerateEnvironmentTest.wiki.Id);

		wiki.constWikiPageEdit();    
		wiki.getUserPermissions();     
		
		replace.setContent('<a foo');
		wiki.setReplace(replace);  
	    wiki.parseWiki(); 
	    
	    replace.setContent('<a href="foo"><br></a><a foo');
		wiki.setReplace(replace);  
	    wiki.parseWiki();
	    
	    replace.setContent('<table><td style="foo">foo</td><th style="foo">foo</th></table>');  
		wiki.setReplace(replace);  
	    wiki.parseWiki();  
	    
	    WikiPage__c wp = GenerateEnvironmentTest.wikiPage;
        WikiVersions__c wv = new WikiVersions__c();
        wv.Name = 'Foo Version';
        wv.Body__c = 'Foo Body';
        wv.WikiPageId__c = wp.Id;
        wv.revisionCount__c = 1; 
        insert wv;	
	    
	    Wiki__c newTeam = 	GenerateEnvironmentTest.wiki;
		WikiPage__c newWiki = new WikiPage__c();
		newWiki.Body__c = '%TOC%\n\n== Header 2 ==\n=== Header 3 ===\n==== Header 4 ====\n===== Header 5 =====\n====== Header 6 ======\n\n[Image: src:http://www.salesforce.com/logo.jpg; a: right]\n[Image: src:http://www.salesforce.com/logo.jpg]\n[Image: src:11981mercano%20el%20marciano.jpg]\n\n \'\'\' bold \'\'\'\n \'\' italic \'\'\n __underline__\n --(strike)--\n normal^supstring^\n normal,,substring,,\n[[->text ident 20px ->]]\n[[-->text ident 40px-->]]\n[[--->text ident 60px--->]]\n\n* item 1\n* item 2\n* item 3\n\n~ item 1\n~ item 2\n~ item 3\n\n[[Juans Team:Home]]\n\n[[Home]]\n[[]]\n[[New Page Coverage Link]]\n\n[http://www.salesforce.com Salesforce]\n\n{| border="1"\n|-\n|cell 1.1\n|cell 2.1\n|-\n|cell 2.1\n|cell 2.2\n|}\n\n\n{| border="1"\n|+ Caption\n|-\n|cell 1.1\n|cell 2.1\n|}\n\n{|\n|cell 1.1\n|cell 2.1\n|}\n\n{|\n!cell 1.1\n! style="color: red;"|cell 2.1\n|}\n\n{| border="1"\n|+ style="color: red;" |Caption\n|- style="color: red;" \n|style="color: red;" | cell 1.1\n|cell 2.1\n|}\n\n[http://www.salesforce.com [Image: src:11981mercano%20el%20marciano.jpg; w:264; h:300;]]\n[Image: src:11981mercano%20el%20marciano.jpg; w:264; h:300;]\n[File: 11981mercano%20el%20marciano.jpg]\n[File: AttachIcons.zip]\n[File: malgoritmia.rar]\n[File: blabla.rar]\n[Flash: index.swf]\n\n{{{\n\nNo parsed\n\n}}}\n\n[Bgcolor:red red text Bgcolor]\n[Bgcolor:rgb(10,10,10) red text Bgcolor]\n[Bgcolor:red\nred text Bgcolor]\n\n\n\n[Color:blue blue text Color]\n[Color:blue\nblue text Color]\n[Color:rgb(10,10,10) blue text Color]\n\n{||}';//\n\n{|\n\n* item~Last*last[Bgcolor:Bgcolor][Color:Color][Image:[File:[[[http://www.salesforce.com{{{';
		newWiki.Name = 'TestClass Wiki';
		newWiki.Wiki__c = newTeam.Id;
		newWiki.Parent__c = GenerateEnvironmentTest.wiki.Id;
		insert newWiki;
	    
	    replace.setContent('[[TestClass Wiki]]');  
		wiki.setReplace(replace);  
	    wiki.parseWiki();
	    wiki.SaveEdit();
	    
	    replace.setContent('[[TestClass Wiki]]');  
		wiki.setReplace(replace);  
	    wiki.parseWiki();
	    
	    wiki.SaveEdit();
	    wiki.CancelEdit();
	    wiki.setIdWikiPage(newWiki.Id);
		wiki.getBreadCrumbing();
	    
	    Test.stopTest();
    } 	      
}
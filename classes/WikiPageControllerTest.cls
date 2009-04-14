@IsTest private class WikiPageControllerTest { 
	public static testMethod void testWiki() {
		GenerateEnvironmentTest.gen();
	
		Test.startTest();
		
		WikiPageController wiki = new WikiPageController();
		
		Wiki__c newTeam = GenerateEnvironmentTest.wiki;
		WikiPage__c newWiki = new WikiPage__c();
		newWiki.Body__c = '%TOC%\n\n== Header 2 ==\n=== Header 3 ===\n==== Header 4 ====\n===== Header 5 =====\n====== Header 6 ======\n\n[Image: src:http://www.salesforce.com/logo.jpg; a: right]\n[Image: src:http://www.salesforce.com/logo.jpg]\n[Image: src:11981mercano%20el%20marciano.jpg]\n\n \'\'\' bold \'\'\'\n \'\' italic \'\'\n __underline__\n --(strike)--\n normal^supstring^\n normal,,substring,,\n[[->text ident 20px ->]]\n[[-->text ident 40px-->]]\n[[--->text ident 60px--->]]\n\n* item 1\n* item 2\n* item 3\n\n~ item 1\n~ item 2\n~ item 3\n\n[[Juans Team:Home]]\n\n[[Home]]\n[[]]\n[[New Page Coverage Link]]\n\n[http://www.salesforce.com Salesforce]\n\n{| border="1"\n|-\n|cell 1.1\n|cell 2.1\n|-\n|cell 2.1\n|cell 2.2\n|}\n\n\n{| border="1"\n|+ Caption\n|-\n|cell 1.1\n|cell 2.1\n|}\n\n{|\n|cell 1.1\n|cell 2.1\n|}\n\n{|\n!cell 1.1\n! style="color: red;"|cell 2.1\n|}\n\n{| border="1"\n|+ style="color: red;" |Caption\n|- style="color: red;" \n|style="color: red;" | cell 1.1\n|cell 2.1\n|}\n\n[http://www.salesforce.com [Image: src:11981mercano%20el%20marciano.jpg; w:264; h:300;]]\n[Image: src:11981mercano%20el%20marciano.jpg; w:264; h:300;]\n[File: 11981mercano%20el%20marciano.jpg]\n[File: AttachIcons.zip]\n[File: malgoritmia.rar]\n[File: blabla.rar]\n[Flash: index.swf]\n\n{{{\n\nNo parsed\n\n}}}\n\n[Bgcolor:red red text Bgcolor]\n[Bgcolor:rgb(10,10,10) red text Bgcolor]\n[Bgcolor:red\nred text Bgcolor]\n\n\n\n[Color:blue blue text Color]\n[Color:blue\nblue text Color]\n[Color:rgb(10,10,10) blue text Color]\n\n{||}\n\n{|\n\n* item~Last*last[Bgcolor:Bgcolor][Color:Color][Image:[File:[[[http://www.salesforce.com{{{';
		newWiki.Name = 'TestClass Wiki';
		newWiki.Wiki__c = newTeam.Id;
		insert newWiki;
		
		wiki.setParamIdWP(newWiki.Id);  

		wiki.contructMethods();

		if (wiki.getWikiSiteName() == null) 
			System.assert(true, 'Null Wiki Site Name');	
		if (wiki.getidWikiPage() == null) 
			System.assert(true, 'Null Wiki Page Id');	
		if (wiki.getWikiBody() == null) 
			System.assert(true, 'Null Wiki Page Body');	
		
		wiki.getHtml();
		wiki.getHtml2();
		wiki.getChilds();
		
		if (wiki.getChildsCount() == null) 
			System.assert(true, 'Null Wiki Page Childs Count');	
			
		/* INFO INNER CLASS */
		WikiPageController.Info info = new WikiPageController.Info();
		
		if (info.getName() == null) 
			System.assert(true, 'Null Wiki Page Info var');	
		if (info.getShortDescription() == null) 
			System.assert(true, 'Null Wiki Page Info var');	
		if (info.getCreatedBy() == null) 
			System.assert(true, 'Null Wiki Page Info var');	
		if (info.getCreatedById() == null) 
			System.assert(true, 'Null Wiki Page Info var');	
		if (info.getLastModifiedBy() == null) 
			System.assert(true, 'Null Wiki Page Info var');	
		if (info.getLastModifiedById() == null) 
			System.assert(true, 'Null Wiki Page Info var');	
		if (info.getCreatedDate() == null) 
			System.assert(true, 'Null Wiki Page Info var');	
		if (info.getLastModifiedDate() == null) 
			System.assert(true, 'Null Wiki Page Info var');	
		if (wiki.getInfoWiki() == null) 
			System.assert(true, 'Null Wiki Page Info');	  
		
		try {
			wiki.getWiki();	
		}catch (exception e) {
			System.assert(true, e);
		}
		
		/* NEW WIKI PAGE */
		if (wiki.getNewPage() == null) {
			System.assert(true, 'Null New Page Boolean');	  
		}
		
		try {
			wiki.cancelNew();
		}catch (exception e) {
			System.assert(true, e);
		}
		
		try {
			wiki.newWiki();
		}catch (exception e) {
			System.assert(true, e);
		}
		
		if (wiki.getnewWP() == null) 
			System.assert(true, 'Null New Wiki Page');	
		if (wiki.getnewWP() == null) 
			System.assert(true, 'Null New Wiki Page');	
		
		/* ATTACHMENTS */
		WikiPageController.AttachmentInfo attach = new WikiPageController.AttachmentInfo();
		
		if (attach.getId() == null) 
			System.assert(true, 'Null Attach var');	
		if (attach.getName() == null) 
			System.assert(true, 'Null Attach var');	
		if (attach.getAttachImage() == null) 
			System.assert(true, 'Null Attach var');	
		if (wiki.getAttachments() == null) 
			System.assert(true, 'Null Attachments list');	
		if (wiki.getAttachCount() == null) 
			System.assert(true, 'Null Attachments list');
		
		/* BREAD CRUMBRING */
		if (wiki.getBreadCrumbing() == null) 
			System.assert(true, 'Null Bread Crumbing');	
		
		/* OUTGOING AND INCOMING */
		if (wiki.getOutgoing() == null) 
			System.assert(true, 'Null Out/Inc links vars');	
		if (wiki.getCntOutgoing() == null) 
			System.assert(true, 'Null Out/Inc links vars');	
		if (wiki.getIncoming() == null) 
			System.assert(true, 'Null Out/Inc links vars');	
		if (wiki.getCntIncoming() == null) 
			System.assert(true, 'Null Out/Inc links vars');	
		
		/* RECENTLY UPDATED */
		if (wiki.getRecentlyUpdated() == null) 
			System.assert(true, 'Null Recently Updated');	
		
		/* TAG CLOUD */
		WikiPageController.Links tagCloud = new WikiPageController.Links();
		
		if (tagCloud.getLinkName() == null) 
			System.assert(true, 'Null TagCloud vars');		
		if (tagCloud.getLinkId() == null) 
			System.assert(true, 'Null TagCloud vars');		
		if (tagCloud.getLinkCount() == null) 
			System.assert(true, 'Null TagCloud vars');		
		if (tagCloud.getLinkClass() == null) 
			System.assert(true, 'Null TagCloud vars');		
		if (tagCloud.getLinkClass() == null) 
			System.assert(true, 'Null TagCloud vars');	
		if (wiki.getLinkCount() == null) 
			System.assert(true, 'Null TagCloud');		
		if (wiki.getLinksNum() == null) 
			System.assert(true, 'Null TagCloud');		
			
		/* MY FAVOURITES */
		if (wiki.getFavorite() == null) 
			System.assert(true, 'Null Favorite');	
		if (wiki.getIsFav() == null) 
			System.assert(true, 'Null Is Favorite');	
		if (wiki.getCntFav() == null) 
			System.assert(true, 'Null Count Favorite');	
		
		/* RECENTLY VIEW */
		WikiPageController.RecentlyView recentlyView = new WikiPageController.RecentlyView();
		
		if (recentlyView.getWikiId() == null) 
			System.assert(true, 'Null Recently View var');	
		if (recentlyView.getWikiName() == null) 
			System.assert(true, 'Null Recently View var');	
		if (recentlyView.getParentName() == null) 
			System.assert(true, 'Null Recently View var');	
		if (recentlyView.getBelong() == null) 
			System.assert(true, 'Null Recently View var');	
		if (wiki.getRecentlyView() == null) 
			System.assert(true, 'Null Recently View');		
		if (wiki.getCntViews() == null) 
			System.assert(true, 'Null Count of Recently View');	
		
		/* COMMENTS */
		Comment__c newComment = new Comment__c();
		newComment.ParentWikiPage__c = newWiki.Id;
		newComment.Message__c = 'Foo Comment';
		insert newComment;
		
		wiki.setCommentBody('Foo');
		wiki.getCommentBody();
		wiki.saveComment();
		
		
		WikiPageController.Comments comments = new WikiPageController.Comments();
		comments.setCommentName('foo');
		comments.getCommentName();
		//comments.getCommentPicture();
		comments.getCommentDate();
		comments.getCommentBy();
		comments.getComment();
		
		wiki.getComments();
		wiki.getCntComments();
		wiki.getAddComment();
		wiki.addCommentLink();
		wiki.cancelComment();
		
		Test.stopTest();
	}
	
	public static testMethod void testWiki2() {
		GenerateEnvironmentTest.gen();
	
		Test.startTest();
		
		WikiPageController wiki = new WikiPageController();
		
		Wiki__c newTeam = GenerateEnvironmentTest.wiki;
		WikiPage__c newWiki = new WikiPage__c();
		newWiki.Body__c = '%TOC%\n\n== Header 2 ==\n=== Header 3 ===\n==== Header 4 ====\n===== Header 5 =====\n====== Header 6 ======\n\n[Image: src:http://www.salesforce.com/logo.jpg; a: right]\n[Image: src:http://www.salesforce.com/logo.jpg]\n[Image: src:11981mercano%20el%20marciano.jpg]\n\n \'\'\' bold \'\'\'\n \'\' italic \'\'\n __underline__\n --(strike)--\n normal^supstring^\n normal,,substring,,\n[[->text ident 20px ->]]\n[[-->text ident 40px-->]]\n[[--->text ident 60px--->]]\n\n* item 1\n* item 2\n* item 3\n\n~ item 1\n~ item 2\n~ item 3\n\n[[Juans Team:Home]]\n\n[[Home]]\n[[]]\n[[New Page Coverage Link]]\n\n[http://www.salesforce.com Salesforce]\n\n{| border="1"\n|-\n|cell 1.1\n|cell 2.1\n|-\n|cell 2.1\n|cell 2.2\n|}\n\n\n{| border="1"\n|+ Caption\n|-\n|cell 1.1\n|cell 2.1\n|}\n\n{|\n|cell 1.1\n|cell 2.1\n|}\n\n{|\n!cell 1.1\n! style="color: red;"|cell 2.1\n|}\n\n{| border="1"\n|+ style="color: red;" |Caption\n|- style="color: red;" \n|style="color: red;" | cell 1.1\n|cell 2.1\n|}\n\n[http://www.salesforce.com [Image: src:11981mercano%20el%20marciano.jpg; w:264; h:300;]]\n[Image: src:11981mercano%20el%20marciano.jpg; w:264; h:300;]\n[File: 11981mercano%20el%20marciano.jpg]\n[File: AttachIcons.zip]\n[File: malgoritmia.rar]\n[File: blabla.rar]\n[Flash: index.swf]\n\n{{{\n\nNo parsed\n\n}}}\n\n[Bgcolor:red red text Bgcolor]\n[Bgcolor:rgb(10,10,10) red text Bgcolor]\n[Bgcolor:red\nred text Bgcolor]\n\n\n\n[Color:blue blue text Color]\n[Color:blue\nblue text Color]\n[Color:rgb(10,10,10) blue text Color]\n\n{||}\n\n{|\n\n* item~Last*last[Bgcolor:Bgcolor][Color:Color][Image:[File:[[[http://www.salesforce.com{{{';
		newWiki.Name = 'TestClass Wiki';
		newWiki.Wiki__c = newTeam.Id;
		insert newWiki;
		
		wiki.setIdWikiPage(newWiki.Id); 
		
		// PARTICULAR WIKI SYNTAX CONTENT
	    newWiki.Body__c = '{|    |}';
	    update newWiki;
	    wiki.parseHTML(); 
	    
	    newWiki.Body__c = '[[-  foo';
		update newWiki;
	    wiki.parseHTML(); 
	    
	    newWiki.Body__c = '* foo';
		update newWiki;
	    wiki.parseHTML();
	    
	    newWiki.Body__c = '* foo * foo';
		update newWiki;
	    wiki.parseHTML();
	    
	    newWiki.Body__c = '* foo * foo\n'; 
		update newWiki;
	    wiki.parseHTML();
	     
	    newWiki.Body__c = '~ foo';
		update newWiki;
	    wiki.parseHTML();
	    
	    newWiki.Body__c = '~ foo ~ foo';
		update newWiki;
	    wiki.parseHTML();
	    
	    newWiki.Body__c = '~ foo ~ foo\n';
		update newWiki;
	    wiki.parseHTML(); 
	    
	    newWiki.Body__c = '== foo';
		update newWiki;
	    wiki.parseHTML();   
		
		Test.stopTest();
	}	
	
	public static testMethod void testWiki3() {
		GenerateEnvironmentTest.gen();
	
		Test.startTest();
		
		WikiPageController wiki = new WikiPageController();
		
		Wiki__c newTeam = GenerateEnvironmentTest.wiki;
		WikiPage__c newWiki = new WikiPage__c();
		newWiki.Body__c = '%TOC%\n\n== Header 2 ==\n=== Header 3 ===\n==== Header 4 ====\n===== Header 5 =====\n====== Header 6 ======\n\n[Image: src:http://www.salesforce.com/logo.jpg; a: right]\n[Image: src:http://www.salesforce.com/logo.jpg]\n[Image: src:11981mercano%20el%20marciano.jpg]\n\n \'\'\' bold \'\'\'\n \'\' italic \'\'\n __underline__\n --(strike)--\n normal^supstring^\n normal,,substring,,\n[[->text ident 20px ->]]\n[[-->text ident 40px-->]]\n[[--->text ident 60px--->]]\n\n* item 1\n* item 2\n* item 3\n\n~ item 1\n~ item 2\n~ item 3\n\n[[Juans Team:Home]]\n\n[[Home]]\n[[]]\n[[New Page Coverage Link]]\n\n[http://www.salesforce.com Salesforce]\n\n{| border="1"\n|-\n|cell 1.1\n|cell 2.1\n|-\n|cell 2.1\n|cell 2.2\n|}\n\n\n{| border="1"\n|+ Caption\n|-\n|cell 1.1\n|cell 2.1\n|}\n\n{|\n|cell 1.1\n|cell 2.1\n|}\n\n{|\n!cell 1.1\n! style="color: red;"|cell 2.1\n|}\n\n{| border="1"\n|+ style="color: red;" |Caption\n|- style="color: red;" \n|style="color: red;" | cell 1.1\n|cell 2.1\n|}\n\n[http://www.salesforce.com [Image: src:11981mercano%20el%20marciano.jpg; w:264; h:300;]]\n[Image: src:11981mercano%20el%20marciano.jpg; w:264; h:300;]\n[File: 11981mercano%20el%20marciano.jpg]\n[File: AttachIcons.zip]\n[File: malgoritmia.rar]\n[File: blabla.rar]\n[Flash: index.swf]\n\n{{{\n\nNo parsed\n\n}}}\n\n[Bgcolor:red red text Bgcolor]\n[Bgcolor:rgb(10,10,10) red text Bgcolor]\n[Bgcolor:red\nred text Bgcolor]\n\n\n\n[Color:blue blue text Color]\n[Color:blue\nblue text Color]\n[Color:rgb(10,10,10) blue text Color]\n\n{||}\n\n{|\n\n* item~Last*last[Bgcolor:Bgcolor][Color:Color][Image:[File:[[[http://www.salesforce.com{{{';
		newWiki.Name = 'TestClass Wiki';
		newWiki.Wiki__c = newTeam.Id;
		newWiki.Parent__c = GenerateEnvironmentTest.wikiPage.Id;
		insert newWiki;
		
		wiki.setIdWikiPage(newWiki.Id); 
		
		wiki.getBreadCrumbing();
		
		// PARTICULAR WIKI SYNTAX CONTENT
		insert new Attachment(Name = 'FooAttach.txt', Body = Blob.valueOf('Some String'), ContentType = 'text/plain', parentId = newWiki.Id);
		
		newWiki.Body__c = '[Image: src:FooAttach.txt;]';
		update newWiki;
	    wiki.parseHTML(); 
	    
	    newWiki.Body__c = '[Image: src:FooAttach.txt]';
		update newWiki;
	    wiki.parseHTML(); 
	   
	    newWiki.Body__c = '[File: FooAttach.txt]';
		update newWiki;
	    wiki.parseHTML(); 
	    
	    insert new Attachment(Name = 'FooAttach2.txt', Body = Blob.valueOf('Some String'), parentId = newWiki.Id);
	     
	    newWiki.Body__c = '[File: FooAttach2.txt]';
		update newWiki;
	    wiki.parseHTML(); 
	    
	    insert new Attachment(Name = 'FooAttach3.rar', Body = Blob.valueOf('Some String'), parentId = newWiki.Id);
	     
	    newWiki.Body__c = '[File: FooAttach3.rar]';
		update newWiki;
	    wiki.parseHTML(); 
	    
	     Attachment newAttach2 =  new Attachment(Name = 'FooAttach4.rar', Body = Blob.valueOf('Some String'),ContentType = 'foo', parentId = newWiki.Id);
	    insert newAttach2;
	    
	    Attachment newAttach = new Attachment(Name = 'FooAttach4.rar', Body = Blob.valueOf('Some String'),ContentType = 'foo', parentId = newWiki.Id);
	    wiki.setWikiPage(newAttach);
	    wiki.getWikiAttach();
	    wiki.saveWikiAttach();
	    wiki.getAttachments();
	    wiki.refreshAttachs();
	    
	   	System.currentPageReference().getParameters().put('idAttach', newAttach2.Id);
	    //wiki.DeleteAttach();
	    
	    newWiki.Body__c = '[File: FooAttach4.rar]'; 
		update newWiki;
	    wiki.parseHTML();
	    
		Test.stopTest();
	}	
	
	public static testMethod void testWiki4() {
		GenerateEnvironmentTest.gen();
	
		Test.startTest();
		
		WikiPageController wiki = new WikiPageController();
		
		Wiki__c newTeam = GenerateEnvironmentTest.wiki;
		WikiPage__c newWiki = new WikiPage__c();
		newWiki.Body__c = '%TOC%\n\n== Header 2 ==\n=== Header 3 ===\n==== Header 4 ====\n===== Header 5 =====\n====== Header 6 ======\n\n[Image: src:http://www.salesforce.com/logo.jpg; a: right]\n[Image: src:http://www.salesforce.com/logo.jpg]\n[Image: src:11981mercano%20el%20marciano.jpg]\n\n \'\'\' bold \'\'\'\n \'\' italic \'\'\n __underline__\n --(strike)--\n normal^supstring^\n normal,,substring,,\n[[->text ident 20px ->]]\n[[-->text ident 40px-->]]\n[[--->text ident 60px--->]]\n\n* item 1\n* item 2\n* item 3\n\n~ item 1\n~ item 2\n~ item 3\n\n[[Juans Team:Home]]\n\n[[Home]]\n[[]]\n[[New Page Coverage Link]]\n\n[http://www.salesforce.com Salesforce]\n\n{| border="1"\n|-\n|cell 1.1\n|cell 2.1\n|-\n|cell 2.1\n|cell 2.2\n|}\n\n\n{| border="1"\n|+ Caption\n|-\n|cell 1.1\n|cell 2.1\n|}\n\n{|\n|cell 1.1\n|cell 2.1\n|}\n\n{|\n!cell 1.1\n! style="color: red;"|cell 2.1\n|}\n\n{| border="1"\n|+ style="color: red;" |Caption\n|- style="color: red;" \n|style="color: red;" | cell 1.1\n|cell 2.1\n|}\n\n[http://www.salesforce.com [Image: src:11981mercano%20el%20marciano.jpg; w:264; h:300;]]\n[Image: src:11981mercano%20el%20marciano.jpg; w:264; h:300;]\n[File: 11981mercano%20el%20marciano.jpg]\n[File: AttachIcons.zip]\n[File: malgoritmia.rar]\n[File: blabla.rar]\n[Flash: index.swf]\n\n{{{\n\nNo parsed\n\n}}}\n\n[Bgcolor:red red text Bgcolor]\n[Bgcolor:rgb(10,10,10) red text Bgcolor]\n[Bgcolor:red\nred text Bgcolor]\n\n\n\n[Color:blue blue text Color]\n[Color:blue\nblue text Color]\n[Color:rgb(10,10,10) blue text Color]\n\n{||}\n\n{|\n\n* item~Last*last[Bgcolor:Bgcolor][Color:Color][Image:[File:[[[http://www.salesforce.com{{{';
		newWiki.Name = 'TestClass Wiki';
		newWiki.Wiki__c = newTeam.Id;
		insert newWiki;
		
		wiki.setIdWikiPage(newWiki.Id);
		wiki.parseHTML();

		wiki.contructMethods();
		
		wiki.setWikiPageName('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
		wiki.getWikiPageName();
		
		wiki.setWikiPageName('aaaaaa');
		wiki.getWikiPageName();    
		
		wiki.getUserPermissions();
		
		System.currentPageReference().getParameters().put('idWP2',newWiki.Id);
		
		wiki.getWiki();
		
		WikiRecentlyViewed__c newWRV = new WikiRecentlyViewed__c();
		newWRV.User__c = UserInfo.getUserId();
		newWRV.Wiki__c = GenerateEnvironmentTest.wiki.Id;
		newWRV.WikiPage__c = newWiki.Id;
		insert newWRV;
		
		wiki.getWiki();
		
		wiki.getnewWV(); 
		
		WikiVersions__c newWV = new WikiVersions__c();
		wiki.setnewWV(newWV);
		
		wiki.getCurrentRevision(); 
		
		wiki.setIdWikiPage(newWiki.Id); 
		wiki.setIdWikiSite(GenerateEnvironmentTest.wiki.Id);
		wiki.SaveNew();
		wiki.setnewWP(newWiki);
		
		wiki.save_del_fav();
		
		Test.stopTest();
	}					
}
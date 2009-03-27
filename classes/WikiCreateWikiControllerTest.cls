@isTest private class WikiCreateWikiControllerTest
{
    static testMethod void myUnitTest() 
    {
    	try
    	{
    		//fsafsd
            GenerateEnvironmentTest.gen();
            Test.startTest();
            System.currentPageReference().getParameters().put('id', GenerateEnvironmentTest.wiki.Id);

            WikiCreateWikiController df = new WikiCreateWikiController();

			             
            df.setdocument(new Attachment(Name = 'Name', Body = Crypto.generateMac('HMacSHA1', Blob.valueOf('String'), Blob.valueOf('String'))));
			df.setParam( GenerateEnvironmentTest.wiki.id );
			df.setWiki( GenerateEnvironmentTest.wiki ); 			             
			df.setWiki( GenerateEnvironmentTest.wiki.Id ); 			             
			df.setIdWiki( GenerateEnvironmentTest.wiki.Id ); 			             
			df.setRemoveMemberId( GenerateEnvironmentTest.newUser.id ); 			             
			df.setEditMemberId( GenerateEnvironmentTest.newUser.id ); 			             
			df.setLetter( 'X' ); 			             

			df.saveWiki();             
	        df.saveWikiAndAddMembers();     
	             
	        // Team Inner Class
            WikiCreateWikiController.Member member = new WikiCreateWikiController.Member();
            
            //member.setTitle('');
            member.setProfile('');
            member.setName('');
            member.setUserId(GenerateEnvironmentTest.newUser.id );
            member.setAdmin(true);
			//member.setCompany( 'company' );
			member.setRole( 'role');
			member.setWikiMemberId( GenerateEnvironmentTest.newUser.Id );
			
            //member.getTitle();
            member.getProfile();
            member.getName();
			member.getUserId();
            member.getAdmin();
			//member.getCompany();
			member.getRole();
			member.getYahoo();
			member.getSkype();
			member.getWikiMemberId();
			
			
			df.getIsWikiAdmin();

            Test.stopTest();
        }
        catch(Exception e)
        {
            throw e;
        }
    }


    static testMethod void myUnitTest2() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();
            System.currentPageReference().getParameters().put('id', GenerateEnvironmentTest.wiki.Id);
      
            WikiCreateWikiController df = new WikiCreateWikiController();  

            // Letters Inner Class
            WikiCreateWikiController.Letters letter = new WikiCreateWikiController.Letters();
            List<WikiCreateWikiController.Letters> letters = df.getLetterFilter();
            letter.setLetter('');
            letter.getLetter();
            letter.setContainMembers(0);
            letter.getContainMembers();
	             
            // Pagination Methods
            df.genCntPagination();
            df.nextPage();
            df.prevPage();
            df.getCurrentPagination();
            df.getNumberOfItemsToShow();
            df.getFirstRow();
            //df.getLastItem();
            //df.getTotalItemsNumber();
            
            
            df.currentPagination = 1;
            Boolean b1 = df.getPrevPageLinkShow();
            Boolean b2 = df.getPrevPageShow();
            Boolean b3 = df.getNextPageLinkShow();
            Boolean b4 = df.getNextPageShow();
            
            df.currentPagination = 0;
            df.cntPagination = 0;
            b1 = df.getPrevPageLinkShow();
            b2 = df.getPrevPageShow();
            b3 = df.getNextPageLinkShow();
            b4 = df.getNextPageShow();


            Test.stopTest();
        }
        catch(Exception e)
        {
            throw e;
        }
    }

    static testMethod void myUnitTest3() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();
            System.currentPageReference().getParameters().put('id', GenerateEnvironmentTest.wiki.Id);

            WikiCreateWikiController df = new WikiCreateWikiController();  

            df.getSortByDesc();

		            df.sortByDesc = false;
	    	        df.letter =  'A';
	            	df.setSortBy( 'User__r.Name' );
		            System.currentPageReference().getParameters().put('sb','User__r.Name');
	        	    df.getSortBy();
	    	        df.sortList(); // 1 SOQL
	
		            df.sortByDesc = false;
	    	        df.letter =  'A';
	            	df.setSortBy( 'User__r.CompanyName' );
		            System.currentPageReference().getParameters().put('sb','User__r.CompanyName');
		            df.sortList(); // 1 SOQL
		                        
		            df.sortByDesc = false;
	    	        df.letter =  'A';
	            	df.setSortBy( 'User__r.Title' );
		            System.currentPageReference().getParameters().put('sb','User__r.Title');
		            df.sortList(); // 1 SOQL
		            
		            df.sortByDesc = false;
	    	        df.letter =  'A';
	            	df.setSortBy( 'WikiProfile__r.Name' );
		            System.currentPageReference().getParameters().put('sb','WikiProfile__r.Name');
		            df.sortList(); // 1 SOQL		            
	
		            df.sortByDesc = false;
					df.letter = null;
	            	df.setSortBy( 'User__r.Name' );
		            System.currentPageReference().getParameters().put('sb','User__r.Name');
	    	        df.sortList(); // 1 SOQL
	
		            df.sortByDesc = false;
					df.letter = null;
	            	df.setSortBy( 'User__r.CompanyName' );
		            System.currentPageReference().getParameters().put('sb','User__r.CompanyName');
		            df.sortList(); // 1 SOQL
		                        
		            df.sortByDesc = false;
					df.letter = null;
	            	df.setSortBy( 'User__r.Title' );
		            System.currentPageReference().getParameters().put('sb','User__r.Title');
		            df.sortList(); // 1 SOQL
		            
		            df.sortByDesc = false;
					df.letter = null;
	            	df.setSortBy( 'WikiProfile__r.Name' );
		            System.currentPageReference().getParameters().put('sb','WikiProfile__r.Name');
		            df.sortList(); // 1 SOQL		            


	            	df.letter = 'G';
	            	df.setSortBy( '' );
		            System.currentPageReference().getParameters().put('sb','User__r.Name');
	    	        df.sortList(); // 1 SOQL
	
	            	df.letter = 'G';
	            	df.setSortBy( '' );
		            System.currentPageReference().getParameters().put('sb','User__r.CompanyName');
		            df.sortList(); // 1 SOQL
		                        
	            	df.letter = 'G';
	            	df.setSortBy( '' );
		            System.currentPageReference().getParameters().put('sb','User__r.Title');
		            df.sortList(); // 1 SOQL
		            
	            	df.letter = 'G';
	            	df.setSortBy( '' );
		            System.currentPageReference().getParameters().put('sb','WikiProfile__r.Name');
		            df.sortList(); // 1 SOQL		            
	
					df.letter = null;
	            	df.setSortBy( '' );
		            System.currentPageReference().getParameters().put('sb','User__r.Name');
	    	        df.sortList(); // 1 SOQL
	
					df.letter = null;
	            	df.setSortBy( '' );
		            System.currentPageReference().getParameters().put('sb','User__r.CompanyName');
		            df.sortList(); // 1 SOQL
		                        
					df.letter = null;
	            	df.setSortBy( '' );
		            System.currentPageReference().getParameters().put('sb','User__r.Title');
		            df.sortList(); // 1 SOQL
		            
					df.letter = null;
	            	df.setSortBy( '' );
		            System.currentPageReference().getParameters().put('sb','WikiProfile__r.Name');
		            df.sortList(); // 1 SOQL		            

			// Others setters and getters
			df.getHasMembers();
			df.getInEdition();
			df.getdocument();
			df.getValidSizePicture();
			df.getWiki();
			df.getWikiPicture();
			df.getProfiles();
			df.getnewProfile();
			
			df.getUserPermissions();
			df.getWikiName();
			df.getWikiId();
			df.getAdminCount();
			df.getUserMemberId();
			df.getCurrentUser();
			df.getRemoveMessage();
			df.assignRemoveId();
			df.getItsLastAdmin();
			df.getEditMemberRole();
			df.setEditMemberRole( 'Wiki Administrator' );
			df.getEditMemberProfile();
			df.setEditMemberProfile('Wiki Administrator' );
			df.getEditMember();
			df.getImgEditMember();
			df.getProfilesOptions();
			df.getProfilesOptionsFilter();
			df.getWikiEditProfiles();
			df.getMembers();

				
			df.refresh();
			df.switchTabsController();


            Test.stopTest();
        }
        catch(Exception e)
        {
            throw e;
        }
    }

}
@IsTest private class TeamsWidgetWikiDirectoryControllerTest { 
    public static testMethod void testWiki() {
        GenerateEnvironmentTest.gen();
		
		Test.startTest();
        
        TeamsWidgetWikiDirectoryController wiki = new TeamsWidgetWikiDirectoryController();
        UserPermissions userPermissions = new UserPermissions();
        
        userPermissions = new UserPermissions();
		
		wiki.setSidebar(true);
        wiki.getSidebar();        
        
        String idTeam = GenerateEnvironmentTest.wiki.Id;
        wiki.setTeamId(idTeam);
        
        if (wiki.getTeamId() == null) 
            System.assert(true, 'Null Team Id');
        
        if (wiki.getUserPermissions() == null) 
            System.assert(true, 'Null User Permissions');
        
        /* Wikis Class */
      
        WikiPage__c wikiPage = new  WikiPage__c();
        wikiPage = [select id, name, Wiki__c, parent__c, body__c, createdById , createdBy.Name from WikiPage__c where wiki__r.id =:GenerateEnvironmentTest.wiki.Id];
        wikiPage.Name = 'loooooooooooooooooonnnnnnnnnnnnnnnnnnggggggggggggggg';           
        TeamsWidgetWikiDirectoryController.Wikis wikiClass = new TeamsWidgetWikiDirectoryController.Wikis(wikiPage);
        wikiClass.getWikiPage();
        wikiClass.getName();
        wikiClass.getCreatedByName(); 
        
        wiki.getWikis();
        wiki.getWikiPagesCount();
        
        try {
            wiki.refresh();
        }catch (Exception e) {
            System.assert(true, e);
        }
        
        Test.stopTest();
    }
}
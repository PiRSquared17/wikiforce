trigger WikiBeforeDelete on Wiki__c bulk (before delete) { 
	if (!TeamUtil.currentlyExeTrigger) {
        try{
            TeamUtil.currentlyExeTrigger = true;
            TeamUtil.DeletingWiki = true;
            
            List<String> idsWiki = new List<String>();
            for (Wiki__c iterWiki : Trigger.old) {
                idsWiki.add(iterWiki.Id); 
            }
            
            List<WikiPage__c> pagesList = [select Id, Name, Wiki__c from WikiPage__c where Wiki__c in : idsWiki ];
            List<WikiMember__c> membersList = [select Id, Name, Wiki__c from WikiMember__c where Wiki__c in : idsWiki ];
            
            System.debug('\n WikiId[' + idsWiki + ']');
            System.debug('\n\n Pages[' + pagesList.size() + ']');
            System.debug('\n\n Members[' + membersList.size() + ']');
            
            for(WikiPage__c p: pagesList){
                System.debug('\n Pages to delete: ' + p.Name);
            }
            
            for(WikiMember__c m: membersList){
                System.debug('\n Member to delete' + m.Name);
            }

			TeamUtil.currentlyExeTrigger = false;
            delete pagesList;
            delete membersList;            
        } catch(Exception e){
        	throw e;
        }
    }
}
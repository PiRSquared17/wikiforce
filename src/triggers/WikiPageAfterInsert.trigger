trigger WikiPageAfterInsert on WikiPage__c bulk (after insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {    

	        List<String> wikiSharingGroupNames = new List<String>();		
			for(WikiPage__c w : Trigger.new) {
				wikiSharingGroupNames.add('wikiSharing' + w.Wiki__c);
			}
			
			Map<String, Id> teamMap = new Map<String, Id>();					
			for(Group g: [select id, name from Group where Name in: wikiSharingGroupNames]) {
				teamMap.put(g.Name, g.Id);
			}
			List<WikiPage__Share> wikis = new List<WikiPage__Share>();
			for(WikiPage__c w : Trigger.new) {
				
				WikiPage__Share p = new WikiPage__Share();
				p.ParentId = w.Id;
				p.UserOrGroupId = teamMap.get('wikiSharing' + w.Wiki__c);
			    p.AccessLevel = 'Read';
			    p.RowCause = Schema.WikiPage__Share.RowCause.Manual;
			    wikis.add(p);
			}
			
			insert wikis;

        	WikiSubscribersEmailServices wEmail = new WikiSubscribersEmailServices();
            for ( WikiPage__c wp : Trigger.new) 
            {
            	wEmail.sendNewPageMessage( 'newPage', wp.Id );  
            }			
	          
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 	
}
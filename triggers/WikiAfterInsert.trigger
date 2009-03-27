trigger WikiAfterInsert on Wiki__c bulk(after insert) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			
			WikiProfile__c defaultProfile = [select Id from WikiProfile__c where Name = 'Wiki Administrator' limit 1];
			List<Group> go = [Select g.Type, g.Name from Group g where Type = 'Organization'];			

            //Customer Portal Group            
            List<Group> portalGroup = new List<Group>();
            if(WikiCreateWikiController.getAllowCustomerStatic()) 
            portalGroup = [Select g.Type, g.Name from Group g where Type = 'AllCustomerPortal'];
	           
            //Partner Portal Group
            List<Group> partnerGroup = new List<Group>();
            if(WikiCreateWikiController.getAllowPartnerStatic())
            partnerGroup = [Select g.Type, g.Name from Group g where Type = 'PRMOrganization'];
            			
			// build for bulk
			Wiki__c[] t = Trigger.new;
			
			for (Wiki__c team : Trigger.new) {
				/**
				* Group List To Insert.
				*/
				List<Group> newGroups = new List<Group>();
				
				/**
				* Create Sharing Group for current Team.
				*/		
				Group g = new Group();
				g.Name = 'wikiSharing' + team.Id;
				insert g;
				
				if(team.PublicProfile__c != null || team.NewMemberProfile__c != null){
					
					GroupMember gm = new GroupMember();
					gm.GroupId = g.Id;
					gm.UserOrGroupId = go[0].Id;
					insert gm;
				
					//If Customer Portal group exist a to GroupMember
					if(portalGroup.size() > 0){
						GroupMember gmPortal = new GroupMember();
	                    gmPortal.GroupId = g.Id;
	                    gmPortal.UserOrGroupId = portalGroup[0].Id;
	                    insert gmPortal;
					} 
									
					//If Partner Portal group exist add GroupMember
					if(partnerGroup.size() > 0 ){
						GroupMember gmPortal = new GroupMember();
	                    gmPortal.GroupId = g.Id;
	                    gmPortal.UserOrGroupId = partnerGroup[0].Id;
	                    insert gmPortal;
					} 				
				}	
						
				/* ### Create Queues ###*/
					
				// Create Wiki Queue
				Group gdqw = new Group();
				gdqw.Type = 'Queue';
				gdqw.Name = 'Wiki' + team.Id;
				insert gdqw;
				
				String wikiQueueId = gdqw.id;
				
				
				// ### Allow SObjects to be managed by recently created queues ###
				List<QueueSobject> sobjectsQueueAllowed = new List<QueueSobject>();
				
			   	/** Wiki allows */
				QueueSobject allowWikiPages = new QueueSobject(SobjectType = Schema.SObjectType.WikiPage__c.getName() ,QueueId = wikiQueueId);
			   	sobjectsQueueAllowed.add(allowWikiPages);
				
			   	QueueSobject allowRecentlyViewed = new QueueSobject(SobjectType = Schema.SObjectType.WikiRecentlyViewed__c.getName() ,QueueId = wikiQueueId);
			   	sobjectsQueueAllowed.add(allowRecentlyViewed);
			   	
			   	QueueSobject allowWikiLink = new QueueSobject(SobjectType = Schema.SObjectType.WikiLink__c.getName() ,QueueId = wikiQueueId);
			   	sobjectsQueueAllowed.add(allowWikiLink);
			   	
			   	QueueSobject allowFavWiki = new QueueSobject(SobjectType = Schema.SObjectType.FavoriteWikis__c.getName() ,QueueId = wikiQueueId);
			   	sobjectsQueueAllowed.add(allowFavWiki);
			
				QueueSobject allowWikis = new QueueSobject(SobjectType = Schema.SObjectType.Wiki__c.getName() ,QueueId = wikiQueueId);
			   	sobjectsQueueAllowed.add(allowWikis);
			   	
			   	QueueSobject allowWikiMembers = new QueueSobject(SobjectType = Schema.SObjectType.WikiMember__c.getName() ,QueueId = wikiQueueId);
			   	sobjectsQueueAllowed.add(allowWikiMembers);				
			   	 
			   	QueueSobject allowComments = new QueueSobject(SobjectType = Schema.SObjectType.Comment__c.getName() ,QueueId = wikiQueueId);
			   	sobjectsQueueAllowed.add(allowComments);
					    
				//Insert all the allowed sobjects       	
				upsert sobjectsQueueAllowed;
			   	
			   	//Upsert Team owner
			   	Wiki__c tempTeam = [select ownerId, Id, Name from Wiki__c where Id =: team.Id limit 1];
			   	tempTeam.ownerId = wikiQueueId;
			   	// We set this to true becuase we dont want all the minifeed triggers and update 
			   	// triggers firing off when all we want to do is update the owner id.
			   	TeamUtil.currentlyExeTrigger = true;
			   	
			   	update tempTeam;
			   	TeamUtil.currentlyExeTrigger = false;
						
				/**
				* Create __Shared object for team
				*/
				Wiki__Share teamS = new Wiki__Share();
				teamS.ParentId = team.Id;
				teamS.UserOrGroupId = g.Id;
			    teamS.AccessLevel = 'Read';
			    teamS.RowCause = 'Manual';
			    insert teamS;  
			
				/**
				* Create the first team member (the founder)
				*/
				WikiMember__c firstTeamMember = new WikiMember__c();
				firstTeamMember.User__c = Userinfo.getUserId();
				firstTeamMember.Name = UserInfo.getName();
				firstTeamMember.Wiki__c = team.Id;
				firstTeamMember.WikiProfile__c = defaultProfile.Id;
				insert firstTeamMember;
				
				
			}
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	}
	else {
		WikiProfile__c defaultProfile = [select Id from WikiProfile__c where Name = 'Wiki Administrator' limit 1];
		for (Wiki__c team : Trigger.new) {
			WikiMember__c firstTeamMember = new WikiMember__c();
			firstTeamMember.User__c = Userinfo.getUserId();
			firstTeamMember.Name = UserInfo.getName();
			firstTeamMember.Wiki__c = team.Id;
			firstTeamMember.WikiProfile__c = defaultProfile.Id;
			insert firstTeamMember;	
		}
	}
}
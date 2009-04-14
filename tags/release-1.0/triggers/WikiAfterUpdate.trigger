trigger WikiAfterUpdate on Wiki__c (after update) {
  
	if (!TeamUtil.currentlyExeTrigger) {
		try {
			
			List<String> groupsNames = new List<String>();
			List<String> idsTeam = new List<String>();
			for (Wiki__c iterTeam : Trigger.new) {
				groupsNames.add('wikiSharing' + iterTeam.Id);
				idsTeam.add(iterTeam.Id);
			}
			List<Group> groupList = [select id, name from Group where name in:groupsNames];
			List<GroupMember> groupMemberList = [select UserOrGroupId, GroupId, id from GroupMember where GroupId in:groupList];
			List<Group> go = [Select g.Type, g.Name from Group g where Type = 'Organization'];
			List<WikiMember__c> teamMemberList = [select Wiki__c, id, User__c from WikiMember__c where Wiki__c in:idsTeam];

            //Customer Portal Group            
            List<Group> portalGroup = new List<Group>();
            portalGroup = [Select g.Type, g.Name from Group g where Type = 'AllCustomerPortal'];

            //Partner Portal Group
            List<Group> partnerGroup = new List<Group>();
            partnerGroup = [Select g.Type, g.Name from Group g where Type = 'PRMOrganization'];	
            			
			for (Integer it = 0; it < Trigger.new.size(); it++) {
				
				Wiki__c oldTeam = Trigger.old[it];
				Wiki__c newTeam = Trigger.new[it];
				
				//If old team was open or close
				if(oldTeam.PublicProfile__c != null || oldTeam.NewMemberProfile__c != null){
					if(newTeam.PublicProfile__c == null && newTeam.NewMemberProfile__c == null){
						String groupName = 'wikiSharing' + newTeam.Id;
						Group teamGroup;
						Boolean findGroup = false;
						Integer countGroup = 0;
						
						while (!findGroup && countGroup < groupList.size()) {
							if (groupList[countGroup].Name == groupName) {
								findGroup = true;	
								teamGroup = groupList[countGroup];
							}
							else {
								countGroup++;
							}	
						}
						
						//Delete Everyone Member
						Boolean findGM = false;
						Integer countGM = 0;
						GroupMember gm;
						while (!findGM && countGM < groupMemberList.size()) {
							if (groupMemberList[countGM].UserOrGroupId == go[0].id && groupMemberList[countGM].GroupId == teamGroup.Id) {
								findGM = true;
								gm = groupMemberList[countGM];
								List<String> gmToDelete = new List<String>();
								gmToDelete.add(gm.id);
								TeamUtil.deleteGroupMembers(gmToDelete); 
							}
							else {
								countGM++;	
							}	
						}

						if( portalGroup.size() > 0)
						for( GroupMember j: groupMemberList ){
							if( j.UserOrGroupId == portalGroup[ 0 ].Id && j.GroupId == teamGroup.Id ){
								List<String> groupMembersIds = new List<String>();
								groupMembersIds.add( j.Id );
								TeamUtil.deleteGroupMembers(groupMembersIds);
							}	
						}
						if( partnerGroup.size() > 0)
						for( GroupMember j : groupMemberList ){
							if( j.UserOrGroupId == partnerGroup[ 0 ].Id && j.GroupId == teamGroup.Id ){
								List<String> groupMembersIds = new List<String>();
								groupMembersIds.add( j.Id );
								TeamUtil.deleteGroupMembers(groupMembersIds);
							}	
						}

						
						//Create GroupMember for all Team Members
						List<GroupMember> groupMembers = new List<GroupMember>();
						for (WikiMember__c iterMember : teamMemberList) {
							if (iterMember.Wiki__c == newTeam.Id) {	
								GroupMember newGroupMember = new GroupMember();
								newGroupMember.GroupId = teamGroup.Id;
								newGroupMember.UserOrGroupId = iterMember.User__c;
								groupMembers.add(newGroupMember); 
							}
						}
						insert groupMembers;
					}
					else{
						//If Customer Portal group exist add GroupMember
						List<GroupMember> gm2 = new List<GroupMember>();
						Group instance = new Group();
						if(portalGroup.size() > 0 ){
							GroupMember gmPortal = new GroupMember();
							// Get GroupMember if exists
							instance = [ SELECT Id FROM Group WHERE Name =: groupsNames[ it ] LIMIT 1 ];
							gm2 = [ SELECT Id FROM GroupMember WHERE GroupId =: instance.Id AND UserOrGroupId =: portalGroup[0].Id ];
							
							if(WikiCreateWikiController.getAllowCustomerStatic()){
								if( gm2.size() == 0 ){					
				                    gmPortal.GroupId = instance.Id;
				                    gmPortal.UserOrGroupId = portalGroup[0].Id;
				                    insert gmPortal;
								} 
							}
							else if( gm2.size() > 0){
								List<String> groupMembersIds = new List<String>();
								groupMembersIds.add(gm2[0].id);
								TeamUtil.deleteGroupMembers(groupMembersIds);							}							
						}                
	
						//If Partner Portal group exist add GroupMember
						if(partnerGroup.size() > 0 ){
							GroupMember gmPortal = new GroupMember();
							// Get GroupMember if exists
							instance = [ SELECT Id FROM Group WHERE Name =: groupsNames[ it ] LIMIT 1 ];
							gm2 = [ SELECT Id FROM GroupMember WHERE GroupId =: instance.Id AND UserOrGroupId =: partnerGroup[0].Id ];
							
							if(WikiCreateWikiController.getAllowPartnerStatic()){
								if( gm2.size() == 0 ){					
				                    gmPortal.GroupId = instance.Id;
				                    gmPortal.UserOrGroupId = partnerGroup[0].Id;
				                    insert gmPortal;
								}
							}
							else if( gm2.size() > 0){
								List<String> groupMembersIds = new List<String>();
								groupMembersIds.add(gm2[0].id);
								TeamUtil.deleteGroupMembers(groupMembersIds);							}							
						}					
					
					}
				}
				else{
					if(newTeam.PublicProfile__c != null || newTeam.NewMemberProfile__c != null){
						String groupName = 'wikiSharing' + newTeam.Id;
						Group teamGroup;
						Boolean findGroup = false;
						Integer countGroup = 0;
						while (!findGroup && countGroup < groupList.size()) {
							if (groupList[countGroup].Name == groupName) {
								findGroup = true;	
								teamGroup = groupList[countGroup];
							}
							else {
								countGroup++;
							}	
						}				
		
						//Delete all GroupMembers
						Boolean findGM = false;
						Integer countGM = 0;
						List<String> gmToDelete = new List<String>();
						for (GroupMember groupMemberIter : groupMemberList) {
							if (groupMemberIter.GroupId == teamGroup.Id) {
								gmToDelete.add(groupMemberIter.id);
							}	
						}
						TeamUtil.deleteGroupMembers(gmToDelete); 
						
						//Create Everyone Member
						GroupMember newGroupMember = new GroupMember();
						newGroupMember.GroupId = teamGroup.Id;
						newGroupMember.UserOrGroupId = go[0].Id;
						insert newGroupMember;
						
						//If Customer Portal group exist add GroupMember
						if(portalGroup.size() > 0 ){
							GroupMember gmPortal = new GroupMember();
		                    gmPortal.GroupId = teamGroup.Id;
		                    gmPortal.UserOrGroupId = portalGroup[0].Id;
		                    insert gmPortal;
						}                
	
						//If Partner Portal group exist add GroupMember
						if(partnerGroup.size() > 0 ){
							GroupMember gmPortal = new GroupMember();
		                    gmPortal.GroupId = teamGroup.Id;
		                    gmPortal.UserOrGroupId = partnerGroup[0].Id;
		                    insert gmPortal;
						}					
					}
				}
			}
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	}			
}
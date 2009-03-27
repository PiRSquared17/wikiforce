trigger TeamMemberAfterDelete on WikiMember__c bulk (before delete) {
	if (!TeamUtil.currentlyExeTrigger) {
		try {	
			TeamUtil.currentlyExeTrigger = true;	
			
			List<String> idsTeam = new List<String>();
			List<String> teamSharingNames = new List<String>();
			for (WikiMember__c tm : Trigger.old) {
				idsTeam.add(tm.Wiki__c);
				teamSharingNames.add('teamSharing' + tm.Wiki__c);
			}
			
			List<Group> groupTeamSharing = [select g.Id, g.Name from Group g where g.Name in:teamSharingNames];
			
			List<Wiki__c> teamList = [select PublicProfile__c, NewMemberProfile__c, Id, Name from Wiki__c where Id in: idsTeam];
			
			List<WikiProfile__c> lstTp = [Select
											Id, 
											Name,
											PostWikiComments__c, 					
											ManageWikis__c, 
											CreateWikiPages__c from WikiProfile__c];
			
			List<String> groupsNames = new List<String>();
			List<String> userIds = new List<String>();
			for (WikiMember__c wm : Trigger.old) {
				groupsNames.add('Wiki' + wm.Wiki__c);				
				userIds.add(wm.User__c);
			}
			
			List<Group> ManageQueueList = [ select Id, Name From Group where Name in: groupsNames and Type = 'Queue' order by Name];
			List<GroupMember> gmList = [select Id, UserOrGroupId, GroupId from GroupMember where UserOrGroupId in:userIds and GroupId in: ManageQueueList];
			List<GroupMember> gmAllList = [select gm.Id, UserOrGroupId, GroupId from GroupMember gm where gm.UserOrGroupId in: userIds];
			
			List<GroupMember> gm = new List<GroupMember>();
			
			for (WikiMember__c tm : Trigger.old) {
		
				//Get Group
				Group g = new Group();
				
				String groupName = 'teamSharing' + tm.Wiki__c;
				Boolean findGroup = false;
				Integer countGroup = 0;
				while (!findGroup && countGroup < groupTeamSharing.size()) {
					if (groupTeamSharing[countGroup].Name == groupName) {
						findGroup = true;
						g = groupTeamSharing[countGroup];	
					}
					countGroup++;
				}
				 
				if (g != null) {
					//Get Team
					Wiki__c t = new Wiki__c();			
					Boolean findTeam = false;
					Integer countTeam = 0;
					while (!findTeam && countTeam < teamList.size()) {
						if (teamList[countTeam].Id == tm.Wiki__c) {
							findTeam = true;
							t = teamList[countTeam];
						}
						countTeam++;	
					}	
					
					//If team access is private, delete group member.
					WikiProfile__c tp = new WikiProfile__c();				
					Boolean findProfile = false;
					Integer countProfile = 0;
					while (!findProfile && countProfile < lstTp.size()) {
						if (lstTp[countProfile].Id == tm.WikiProfile__c) {
							findProfile = true;	
							tp = lstTp[countProfile];
						}
						countProfile++;
					}
					
					List<Group> ManageQueue = new List<Group>(); 
					Map<String,Group> groupIdsMap = new Map<String, Group>();
					for (Group iterQueue : ManageQueueList) {
						if (iterQueue.Name.indexOf(tm.Wiki__c) != -1) {
							ManageQueue.add(iterQueue);
							groupIdsMap.put(iterQueue.Id, iterQueue);
						}
					}
					
					for (GroupMember iterGroupMember : gmList) {
						if (iterGroupMember.UserOrGroupId == tm.User__c && groupIdsMap.containsKey(iterGroupMember.GroupId)) {
							gm.add(iterGroupMember);	
						}	
					}
					
					if(t.PublicProfile__c == null && t.NewMemberProfile__c == null){			
						Boolean findGM = false;
						Integer countGM = 0;
						while (!findGM && countGM < gmAllList.size()) {
							if (gmAllList[countGM].GroupId == g.Id && gmAllList[countGM].UserOrGroupId == tm.User__c) {
								findGM = true;	
								gm.add(gmAllList[countGM]);
							}
							countGM++;
						}
					}
				}
			}
			delete gm;
			
		} finally {
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 	
}
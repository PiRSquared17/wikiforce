trigger WikiMemberAfterInsert on WikiMember__c bulk (after insert) {
    
    if (!TeamUtil.currentlyExeTrigger) {
        try {
            
            List<String> idsTeam = new List<String>();
            List<String> idsProfile = new List<String>();
            List<String> groupsNames = new List<String>();
            for (WikiMember__c tm : Trigger.new) {
                groupsNames.add('Wiki' + tm.Wiki__c);
                groupsNames.add('wikiSharing' + tm.Wiki__c);

                idsTeam.add(tm.Wiki__c);
                idsProfile.add(tm.WikiProfile__c);  
            }

        	WikiSubscribersEmailServices wEmail = new WikiSubscribersEmailServices();
            for ( WikiMember__c wm : Trigger.new) 
            {
            	wEmail.sendMemberLeaveAdd( 'TeamMemberJoin', wm.Id );  
            }
            
            List<Wiki__c> teamList = [select id, name, PublicProfile__c, NewMemberProfile__c from Wiki__c where id in: idsTeam];
            List<Group> ManageQueueList = [ select Id, Name From Group where Name in: groupsNames];
            
            List<WikiProfile__c> tpList = [ select
                                            t.Id, 
                                            t.Name,
                                            t.PostWikiComments__c, 
                                            t.ManageWikis__c, 
                                            t.CreateWikiPages__c 
                                            from WikiProfile__c t 
                                            where t.Id in:idsProfile];
            
            for(WikiMember__c tm : Trigger.new) {
                //Get Team Sharing Group
                String groupName = 'wikiSharing' + tm.Wiki__c;
                Group g;
                Boolean findTSG = false;
                Integer countTSG = 0;
                while (!findTSG && countTSG < ManageQueueList.size()) {
                    if (ManageQueueList[countTSG].Name == groupName) {
                        findTSG = true;
                        g = ManageQueueList[countTSG];
                    }
                    countTSG++; 
                }
                
                //Get Wiki
                Wiki__c t;
                Boolean findTeam = false;
                Integer countTeam = 0;
                while (!findTeam && countTeam < teamList.size()) {
                    if (teamList[countTeam].Id == tm.Wiki__c) {
                        findTeam = true;
                        t = teamList[countTeam];    
                    }
                    countTeam++;    
                }
                
                // ### Determine Wiki access level ###
                if(t.PublicProfile__c == null && t.NewMemberProfile__c == null){
                    //If team is private
                    GroupMember gm = new GroupMember();
                    gm.GroupId = g.Id;
                    gm.UserOrGroupId = tm.User__c;
                    insert gm;
                }
                
                // Determine Different Queue Additions
                ///////////////////////////////////////
                List<GroupMember> groupMembers = new List<GroupMember>();
                WikiProfile__c tp = new WikiProfile__c();
                Boolean findProfile = false;
                Integer countProfile = 0;
                while (!findProfile && countProfile < tpList.size()) {
                    if (tpList[countProfile].id == tm.WikiProfile__c) {
                        findProfile = true; 
                        tp = tpList[countProfile];
                    }
                    countProfile++; 
                }
                
                if (findProfile) {
                    if(tp.ManageWikis__c){
                        String queueName = 'Wiki' + tm.Wiki__c;
                        Boolean findGroup = false;
                        Integer countGroup = 0;
                        while (!findGroup && countGroup < ManageQueueList.size()) {
                            if (ManageQueueList[countGroup].Name == queueName) {
                                findGroup = true;
                                GroupMember gm = new GroupMember();
                                gm.UserOrGroupId = tm.User__c;
                                gm.GroupId = ManageQueueList[countGroup].Id;
                                groupMembers.add(gm);   
                            }
                            countGroup++;   
                        }
                    }

                    
                    insert groupMembers;
                    
                    /**
                    * Insert into the Sharing Table 
                    */
                    WikiMember__Share tms = new WikiMember__Share();
                    tms.ParentId = tm.Id;
                    tms.UserOrGroupId = g.Id;
                    tms.AccessLevel = 'Read';
                    tms.RowCause = 'Manual';
                    insert tms;
                
                }
            }   
        } finally {
            TeamUtil.currentlyExeTrigger = false;
        }
    } 
                                    
}
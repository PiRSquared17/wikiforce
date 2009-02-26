@IsTest private class WikiMembersWidgetControllerTest {
    public static testMethod void testTeam() {
        try{ 
            //kkjnkjnkj
            GenerateEnvironmentTest.gen();
            Test.startTest();            
                    
            WikiMembersWidgetController team = new WikiMembersWidgetController();
            String curUser = team.getCurrentUser(); 
            
            team.getNamespace();
            Wiki__c t = GenerateEnvironmentTest.wiki;
            //String result = team.getComponentHeader ();
            //result = team.getComponentHeader ();
            //Boolean render = team.getRenderLinkAction ();
            
            WikiMembersWidgetController.Member member = new WikiMembersWidgetController.Member();
            member = team.getNewMemberVars();
            
            /*
            Profile p = [select id from profile where name='System Administrator'];
            User newUser1 = new User(alias = 'test1', email='test1@testorg.com', 
                                    emailencodingkey='UTF-8', lastname='Testing2', languagelocalekey='en_US', 
                                    localesidkey='en_US', profileid = p.Id, 
                                    timezonesidkey='America/Los_Angeles', username='test1@testorg.com');
            insert newUser1;
            
            User newUser2 = new User(alias = 'test2', email='test2@testorg.com', 
                                    emailencodingkey='UTF-8', lastname='Testing2', languagelocalekey='en_US', 
                                    localesidkey='en_US', profileid = p.Id, 
                                    timezonesidkey='America/Los_Angeles', username='test2@testorg.com');
            
            insert newUser2;
            
            User newUser3 = new User(alias = 'test3', email='test3@testorg.com', 
                                    emailencodingkey='UTF-8', lastname='Testing3', languagelocalekey='en_US', 
                                    localesidkey='en_US', profileid = p.Id, 
                                    timezonesidkey='America/Los_Angeles', username='test3@testorg.com');
            
            insert newUser3;
            */
            List<User> users = new User[3];
            users[0] = GenerateEnvironmentTest.newUser;
            users[1] = GenerateEnvironmentTest.newUser;
            users[2] = GenerateEnvironmentTest.newUser;
            member.setColleagueNames( users[0].Name + ',' + users[1].Name + ',' + users[2].Name );
            
            team.setNewMemberVars(member);
            
            List<SelectOption> options = team.getProfilesOptions();
            List<WikiMember__c> members = team.getMemberListToolkit();
            Integer cnt = team.getMemberListToolkitCount();
            
            
            team.syncSaveMembers();
            User user = [select Name, Email from User limit 1];
            team.SendMail(user, 'Message');

			team.setWiki( GenerateEnvironmentTest.wiki.id );
			team.setIdWiki( GenerateEnvironmentTest.wiki.id ); 
            team.getWiki();
            team.getWikiId();

			team.setEmailNotifications( true );
			team.getEmailNotifications();
			team.setMakeMembersAdmins( true );
			team.getMakeMembersAdmins();
			team.getShowWidget();
			team.setShowWidget( true );
			//team.getIsTeamAdmin();
			//team.getMembers();
			team.getWikispaceMembersIds();
			team.assignNewMemberVarsNewProfile();
			team.getAlready();
			team.getUserPermissions();
			team.refreshMethod();
			team.getWikispaceMembers();
			team.getWikiName();
			team.getWikiId(); 
			team.getProfilesOptions();
			team.getNewMemberVars();
			team.setNewMemberVars( member );
			
			
			
			member.getColleagueNames();
			member.getMessage();
			member.setMessage( 'aaaaaaaaaaaa' );
			member.getProfileId();
			member.setProfileId( 'Public Profile' );

	
            team.saveMembers();            
            team.saveMembers();            
			
			team.genPermissions();
			
            Test.stopTest();
        }catch(Exception e){
            throw e;
        }
    }

}
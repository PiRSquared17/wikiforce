@isTest private class WikiDetailsWidgetControllerTest {

    static testMethod void myUnitTest() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();
            
            //lkljlkjlkjk
            //llkokpokpo
            
            WikiDetailsWidgetController wdw = new WikiDetailsWidgetController();
            
            wdw.setWiki( GenerateEnvironmentTest.wiki.id );
            
            wdw.getWiki();
            wdw.getCurrentUser();
            wdw.getNamespace();
            wdw.getUserPermissions();
            wdw.getTeamspace();
            wdw.getTeamIsOpen();
            wdw.getTeamMemberId();
            wdw.getIsTeamAdmin();
            wdw.getTeamAdmins();
            wdw.getTeamCount();
            wdw.getTeamspaceImage();
            
            wdw.refreshJoinEvent();
            wdw.leaveTeam();
            wdw.refreshLeaveEvent();
            
            
            Test.stopTest();
 
		}
        catch(Exception e)
        {
            throw e;
        }
    }
}
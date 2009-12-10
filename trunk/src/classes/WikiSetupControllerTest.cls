public with sharing class WikiSetupControllerTest {
    static testMethod void myUnitTest() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();
			
			List<Profile> pList = [ SELECT id, name FROM Profile LIMIT 3 ]; 

			WikiSetupController ws = new WikiSetupController();
			
			ws.setSelectedProfilesList( new List<String>{'', ''});
			ws.getSelectedProfilesList();
			ws.getAllProfiles();
			ws.getSavedProfiles();
			ws.saveAdmSettings();
			ws.setSelectedProfsStr( pList[0].name );
			ws.getSelectedProfsStr();
			ws.stringProfiles();
			ws.canView();
			ws.getIfCanModifyAllData();

 


            Test.stopTest();
		}
        catch(Exception e)
        {
            throw e;
        }
    }
}
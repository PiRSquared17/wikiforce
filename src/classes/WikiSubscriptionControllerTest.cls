public with sharing class WikiSubscriptionControllerTest {
	
    static testMethod void myUnitTest() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();
            
			System.currentPageReference().getParameters().put('id', GenerateEnvironmentTest.wiki.id );
            WikiSubscriptionController ws = new WikiSubscriptionController();
            
			ws.setIdTeam( GenerateEnvironmentTest.wiki.id );
			ws.constructMethods();
			ws.saveSubscription();
			ws.cancelSubscription();
			ws.deleteSubscription();
	 
			ws.getSubscription();
			ws.getWikiNameShort();
			ws.getWikiName();
			ws.getSubscriptionCount();

            Test.stopTest();
 
		}
        catch(Exception e)
        {
            throw e;
        }
    }
}
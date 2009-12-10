public with sharing class WikiSubscribeControllerTest {
    static testMethod void myUnitTest() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();
            
            WikiSubscribeController ws = new WikiSubscribeController();
            ws.setTEAM( GenerateEnvironmentTest.wiki.id );
            ws.getTEAM();          
            
            Test.stopTest();
		}catch(Exception e){
            throw e;
        }
    }            
}
public class WikiWidgetMyRecentChangesControllerTest {

    static testMethod void myUnitTest() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();
                       
            WikiWidgetMyRecentChangesController ww = new WikiWidgetMyRecentChangesController();
            
            ww.getMyRecentChanges();
            ww.getCntMyRecentChanges();
            
            Test.stopTest();
 
		}
        catch(Exception e)
        {
            throw e;
        }
    }
}
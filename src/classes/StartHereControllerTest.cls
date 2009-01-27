@isTest private class StartHereControllerTest {


    static testMethod void myUnitTest() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();

            StartHereController here = new StartHereController();
            
            here.initPageAction();
            here.getHTMLHeader();
            here.getBannerURL();
            here.getBannerImageURL();
            here.getMainBody();
            here.getSideBar();
            here.getFooter();
            here.getTracker();
            
            Test.stopTest();
        }
        catch(Exception e)
        {
            throw e;
        }
    }
}
public class WikiWidgetMyFavoritesControllerTest {

    static testMethod void myUnitTest() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();
            
            WikiWidgetMyFavoritesController ww = new WikiWidgetMyFavoritesController();
            
            ww.getCntFav();
            ww.getFavorite();
            
            Test.stopTest();
 
		}
        catch(Exception e)
        {
            throw e;
        }
    }
}
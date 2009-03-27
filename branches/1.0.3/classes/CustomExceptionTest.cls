public class CustomExceptionTest {

    static testMethod void myUnitTest() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();
            
            CustomException ce = new CustomException();
            Test.stopTest();
 
		}
        catch(Exception e)
        {
            throw e;
        }
    }
}
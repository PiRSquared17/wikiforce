public class TeamUtilTest {


    static testMethod void myUnitTest() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();
            
            TeamUtil tu = new TeamUtil();
            
	        TeamUtil.isAdminMemberUser();
	        TeamUtil.getOrganizationGroup();
	        TeamUtil.getNamespace();
	        List<Attachment> attachList = new List<Attachment>();
	        TeamUtil.validateFileSize( attachList );
            

            Test.stopTest();
 
		}
        catch(Exception e)
        {
            throw e;
        }
    }
}
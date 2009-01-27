public class WikiMembersRemoveControllerTest {

    static testMethod void myUnitTest() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();

			System.currentPageReference().getParameters().get('id');
			WikiMembersRemoveController wmr = new WikiMembersRemoveController();
			
			System.currentPageReference().getParameters().put( 'delId', GenerateEnvironmentTest.newUser.id );
			//WikiCreateWikiController.removeMemberId = GenerateEnvironmentTest.newUser.id;
			WikiCreateWikiController wwc = new WikiCreateWikiController();
			
			
			wmr.getWikiName();
			wmr.getDelName();
			wmr.getIsLastMemberAdmin();
			
			wmr.removeMember();

            Test.stopTest();
 
		}
        catch(Exception e)
        {
            throw e;
        }
    }
}
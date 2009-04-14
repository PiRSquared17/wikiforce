@isTest private class UserPermissionTest
{
    static testMethod void myUnitTest() 
    {
    	try
    	{

            GenerateEnvironmentTest.gen();
            Test.startTest();

			UserPermissions up = new UserPermissions();
			
			up.setId( GenerateEnvironmentTest.newUser.Id );
			up.setOwnerId( GenerateEnvironmentTest.newUser.Id );
			up.setTeam( GenerateEnvironmentTest.wiki.Id );
			up.setObjectType( GenerateEnvironmentTest.wiki.Id );
			up.setPermissions();
			
			up.getId();
			up.getTeam();
			up.getObjectType();
			up.getCanCreate();
			up.getCanManage();
			up.getCanComment();
			up.getCanView();
                        
            Test.stopTest();
        }
        catch(Exception e)
        {
            throw e;
        }
    }
}
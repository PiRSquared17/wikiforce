@istest private class WikiCreateWikiControllerTest {

    static testMethod void myUnitTest() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();



            System.currentPageReference().getParameters().put('id', GenerateEnvironmentTest.wiki.Id);
            update GenerateEnvironmentTest.wiki;

            WikiCreateWikiController ww = new WikiCreateWikiController();

			             
            Wiki__c t = GenerateEnvironmentTest.wiki;
            ww.setWiki(t);
            t = ww.getWiki();
            ww.getNewProfile();
            ww.setdocument(new Attachment(Name = 'Name', Body = Crypto.generateMac('HMacSHA1', Blob.valueOf('String'), Blob.valueOf('String'))));
            ww.getdocument();
            WikiCreateWikiController.wikiProfile openClose = new WikiCreateWikiController.wikiProfile();
            
                        
                        
                        
                        
                        
            Test.stopTest();
        }
        catch(Exception e)
        {
            throw e;
        }
    }
}
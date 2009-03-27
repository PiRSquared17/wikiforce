public class WikiPageImagesControllerTest {

    static testMethod void myUnitTest() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();
            
            System.currentPageReference().getParameters().put( 'idWP', GenerateEnvironmentTest.wikiPage.Id );
            WikiPageImagesController wp = new WikiPageImagesController();
            
            // Setters
            wp.setIdWikiPage( GenerateEnvironmentTest.wikiPage.Id );
            
            Attachment newAtt = new Attachment();
            
            newAtt.ParentId = GenerateEnvironmentTest.wikiPage.Id;
            newAtt.Name = 'Test';
            newAtt.Body = Blob.valueOf('Content');
            wp.setNewAttach( newAtt );
            
            // GETTERS
            wp.getIdWikiPage();
            wp.getValidAttSize();
            wp.getNewAttach();
            wp.getAttachments();
            wp.getAttachCount();
            
            wp.saveNewImage();

            Test.stopTest();
 
		}
        catch(Exception e)
        {
            throw e;
        }
    }
}
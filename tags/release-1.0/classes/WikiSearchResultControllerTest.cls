public class WikiSearchResultControllerTest {

    static testMethod void myUnitTest() 
    {
    	try
    	{
            GenerateEnvironmentTest.gen();
            Test.startTest();
            
            System.currentPageReference().getParameters().put('key', 'search search' );
            WikiSearchResultController wp = new WikiSearchResultController();
            
            // Setters
            wp.setCriteria( 'search' );
            wp.setJumpPage( 0 );
            
            // getters
            wp.getCriteria();
            wp.getTotalItemsNumber();
            wp.getNoMatches();
            wp.getsrList();
            wp.getResults();
            wp.getFirstItem();
            wp.getLastItem();
            wp.getCurrentPagination();
            wp.getCntPagination();
            wp.getNumberOfItemsToShow();
            wp.getFirstRow();
            wp.getPrevPageLinkShow();
            wp.getPrevPageShow();
            wp.getNextPageLinkShow();
            wp.getNextPageShow();
            wp.getJumpPage();

			// Others methods
            wp.search();
            wp.genCntPagination();
            wp.nextPage();
            wp.prevPage();
            wp.lastPage();
            wp.firstPage();
            wp.refreshPages();
            wp.JumpToPage();
            
            
            
            Test.stopTest();
 
		}
        catch(Exception e)
        {
            throw e;
        }
    }
}
trigger WikiPageAfterUpdate on WikiPage__c ( after update ) 
{
    if ( !TeamUtil.currentlyExeTrigger ) 
    {
        try 
        {
        	WikiSubscribersEmailServices wEmail = new WikiSubscribersEmailServices();
            for ( WikiPage__c wp : Trigger.new ) 
            {
            	wEmail.sendNewPageMessage( 'updatePage',  wp.Id );  
            	wEmail.sendModifiedPageMessage( wp.Id, 'update' );
            }			
		} 
		finally 
		{ 
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 	
}
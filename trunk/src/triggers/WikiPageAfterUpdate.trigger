trigger WikiPageAfterUpdate on WikiPage__c ( after update ) 
{
    if ( !TeamUtil.currentlyExeTrigger ) 
    {
        try 
        {
        	WikiSubscribersEmailServices wEmail = new WikiSubscribersEmailServices();
        	System.debug('+++++++++++++++++++ Trigger outside for');
            for ( WikiPage__c wp : Trigger.new ) 
            {
            	wEmail.sendNewPageMessage( 'updatePage',  wp.Id );  
            	wEmail.sendModifiedPageMessage( wp.Id, 'update' );
            	System.debug('+++++++++++++++++++ Trigger inside for '+ wp.Id);
            }			
		} 
		finally 
		{ 
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 	
}
trigger WikiMemberBeforeDelete on WikiMember__c (before delete) 
{
	if (!TeamUtil.currentlyExeTrigger) 
	{
		try 
		{	
			TeamUtil.currentlyExeTrigger = true;	
		
        	WikiSubscribersEmailServices wEmail = new WikiSubscribersEmailServices();
            for ( WikiMember__c wm : Trigger.old) 
            { 
            	wEmail.sendMemberLeaveAdd( 'TeamMemberLeave', wm.Id );  
            }
		}
		finally 
		{
        	TeamUtil.currentlyExeTrigger = false;
		}
	} 	
}
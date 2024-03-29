public class WikiSubscribersEmailServices {

//E-mail services instance
	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	public Boolean isTaskEdit = false;
	
	public Boolean isTest = false;
    WikiMember__c dm = new  WikiMember__c();
	List<WikiSubscription__c> TeamMemberSubscription = new List<WikiSubscription__c>();
	
	/**
	* Constructor (def)
	*/
	public WikiSubscribersEmailServices()
	{
	}

	/**
	*@param Boolean isTest
	*/
	public void setIsTest ( Boolean isTest ) 
	{
		this.isTest = isTest;	
	}
	
	/**
	*@param Boolean
	*/
	public void setIsTaskEdit ( Boolean isTaskEdit ){
		this.isTaskEdit = isTaskEdit;
	}


	/**
	*@Send a message when add new member or member leave the wiki
	*/
	public void sendMemberLeaveAdd( String acction, String idWikiMember )
	{
		String emailMsj = '';
		String emailSub = '';
		TeamUtil.hostName = TeamUtil.getHost(ApexPages.currentPage());
		
		if ( acction == 'TeamMemberJoin' || acction == 'TeamMemberAdd' || acction == 'TeamMemberLeave') 
		{	
			
			WikiMember__c dm = new WikiMember__c();
			dm = [ SELECT Id, User__r.Name, Wiki__c, Wiki__r.Name FROM WikiMember__c WHERE Id =: idWikiMember ];
			
			
			if ( acction == 'TeamMemberLeave') 
			{
				//Sub:Team Member has Left the team
				//Body: {Name} has left team {team name} 
				
				String oldMemberName = dm.User__r.Name;
				emailMsj = oldMemberName + ' has left wiki  <a href="//' + TeamUtil.hostName +'/apex/WikiTeamOverview?tid=' + dm.Wiki__c + '">' +  dm.Wiki__r.Name+ '</a>.';
				emailSub = 'Wiki Member has Left the Wiki ';
			}
			else 
			{
				//Sub:New Team Member
				//Body: A new team member has joined team {}. Please welcome {name} to the team. 
				emailMsj = 'A new wiki member has joined wiki <a href="//' + TeamUtil.hostName + '/apex/WikiTeamOverview?tid=' + dm.Wiki__c + '">' +  dm.Wiki__r.Name + '</a>. Please welcome ' + dm.User__r.Name + ' to the Wiki.';
				emailSub = 'New Wiki Member';
			}

			if (!isTest) {
				TeamMemberSubscription = [Select 
					t.User__c, 
					t.User__r.Id,
					t.User__r.Name,
					t.User__r.Email,
					t.Team__c,
					t.Team__r.Name,
					t.Team__r.Id, 
					t.TeamMemberStatusUpdated__c,
					t.TeamMemberJoinLeave__c,
					t.Id, 
					t.WikiCreatedByMeUpdated__c, 
					t.WikiNewPage__c, 
					t.WikiPageUpdated__c
					From WikiSubscription__c t
					where Team__c =: dm.wiki__c and TeamMemberJoinLeave__c = true];
			}

			//Array address
			String[] address = new String[]{}; 
			Integer it = 0;
			if(TeamMemberSubscription.size() > 10){
				for(Integer i =0; i < TeamMemberSubscription.size(); i++ ){	
					if(it < 10 || i == TeamMemberSubscription.size() ){
						address.add(TeamMemberSubscription[i].User__r.Email);
						it ++;
					}else{
						SendMail(address, TeamMemberSubscription[0].Team__r, emailMsj, emailSub);
						it = 0;
					}
				}
			}else if(TeamMemberSubscription.size() > 0 && TeamMemberSubscription != null){	
				for(WikiSubscription__c ts : TeamMemberSubscription){
					address.add(ts.User__r.Email);
				}
				SendMail(address, TeamMemberSubscription[0].Team__r, emailMsj, emailSub);
			}	
		}
	}

	/**
	*Sends a message when new page was created in the wiki 
	* The same happens when there is an update or delete, it depends on "acction" param
	*@param String acction
	*@param String IdNewPage
	*/
	public void sendNewPageMessage(  String acction, String IdNewPage )
	{
		
		String wikiName = '';
		String wikiId = ''; 
		String emailSub = '';
		String emailMsj = '';
		WikiPage__c wp = new WikiPage__c();
		wp = [ SELECT Id,Name, Wiki__c, Wiki__r.Name, LastModifiedById, LastModifiedBy.Name FROM WikiPage__c WHERE Id =: IdNewPage ];
System.debug('XXX sendNewPageMessage entreee WP ='+wp);
System.debug('XXX sendNewPageMessage entreee wikic='+IdNewPage);
System.debug('XXX sendNewPageMessage entreee acction='+acction+', IdNewPage='+IdNewPage);
		if( acction == 'newPage' )
		{			

			emailSub = 'Wiki page ' + wikiName + ' has been added to the Wiki ' + wp.Wiki__r.Name + '\'s wiki';
			emailMsj = 'Wiki page ' + wikiName + ' has been added to the Wiki <a href="//' + TeamUtil.hostName + '/apex/WikiTeamOverview?tid=' + wp.Wiki__r.Id + '">' + wp.Wiki__r.Name + '\'s</a> wiki<br><a href="//' + TeamUtil.hostName + '/apex/WikiPage?idWP=' + wp.Id + '">Click here to see the page</a>.';
			if (!isTest) {
			TeamMemberSubscription = [Select 
				t.WikiPageUpdated__c, 
				t.WikiNewPage__c, 
				t.WikiCreatedByMeUpdated__c, 
				t.User__c, 
				t.User__r.Id,
				t.User__r.Name,
				t.User__r.Email,
				t.Team__c,
				t.Team__r.Name,
				t.Team__r.Id, 
				t.TeamMemberStatusUpdated__c, 
				t.TeamMemberJoinLeave__c, 
				t.Id
				From WikiSubscription__c t
				where Team__c =: wp.Wiki__c and WikiNewPage__c = true];
			}
		}
		else{ 
			if( acction == 'updatePage' ){
				System.debug( '::: updating' );
				List<WikiPage__c> wikiPageList = [select id, PageCreatedBy__c from WikiPage__c where id=: IdNewPage ];
				String createdById = wikiPageList[0].PageCreatedBy__c;
			
				emailSub = 'Wiki page ' + wikiName + ' within Wiki ' + wp.Wiki__r.Name + ' has been edited';
				emailMsj = 'Wiki page ' + wikiName + ' has been edited by <a href="https://' + TeamUtil.hostName + '/?id=' + wp.LastModifiedById + '">' +  wp.LastModifiedBy.Name + '</a><br><a href="https://' + TeamUtil.hostName + '/apex/WikiPage?idWP=' + wp.Id + '">Click here to see the page</a>.';
			
				if (!isTest) 
				{
					TeamMemberSubscription = [Select 
						t.WikiPageUpdated__c, 
						t.WikiNewPage__c, 
						t.WikiCreatedByMeUpdated__c, 
						t.User__c, 
						t.User__r.Id,
						t.User__r.Name,
						t.User__r.Email,
						t.Team__c,
						t.Team__r.Name,
						t.Team__r.Id, 
						t.TeamMemberStatusUpdated__c, 
						t.TeamMemberJoinLeave__c, 
						t.Id
						From WikiSubscription__c t
						where Team__c =: wp.Wiki__c and ((WikiPageUpdated__c = true and User__c !=:createdById) or (WikiCreatedByMeUpdated__c = true and User__c =:createdById))];
						
						String aa = 'Select t.WikiPageUpdated__c,t.WikiNewPage__c,t.WikiCreatedByMeUpdated__c,t.User__c,t.User__r.Id,t.User__r.Name,t.User__r.Email,t.Team__c,t.Team__r.Name,t.Team__r.Id,t.TeamMemberStatusUpdated__c,t.TeamMemberJoinLeave__c,t.Id From WikiSubscription__c t where Team__c =: '+wp.Wiki__c+' and ((WikiPageUpdated__c = true and User__c !=:'+createdById+') or (WikiCreatedByMeUpdated__c = true and User__c =:'+createdById+'))';
					System.debug('XXX update :'+TeamMemberSubscription);
					System.debug('XXX update SQL :'+aa);
				}			
			}else{
				if( acction == 'deletePage' ){
					//System.debug( '::: updating' );
					List<WikiPage__c> wikiPageList = [select id, PageCreatedBy__c from WikiPage__c where id=: IdNewPage ];
					String createdById = wikiPageList[0].PageCreatedBy__c;
					
					emailSub = 'Wiki page ' + wikiName + ' with in Wiki ' + wp.Wiki__r.Name + ' has been deleted';
					emailMsj = 'Wiki page <b>' + wp.Name + '</b> has been deleted from <b>' + wp.Wiki__r.Name + '</b> by <a href="https://' + TeamUtil.hostName + '/' + wp.LastModifiedById + '">' +  wp.LastModifiedBy.Name + '</a>';
			
					if (!isTest) 
					{
						TeamMemberSubscription = [Select 
							t.WikiPageUpdated__c, 
							t.WikiNewPage__c, 
							t.WikiCreatedByMeUpdated__c, 
							t.User__c, 
							t.User__r.Id,
							t.User__r.Name,
							t.User__r.Email,
							t.Team__c,
							t.Team__r.Name,
							t.Team__r.Id, 
							t.TeamMemberStatusUpdated__c, 
							t.TeamMemberJoinLeave__c, 
							t.Id
							From WikiSubscription__c t
							where Team__c =: wp.Wiki__c] ;
					}	
					
							
				}//if delete
			}//else update
		}//else new
		
		//Array address
		String[] address = new String[]{}; 
		Integer it = 0;
		System.debug('XXX size:'+TeamMemberSubscription.size());
		System.debug('XXX tms:'+TeamMemberSubscription);
		if(TeamMemberSubscription.size() > 10)
		{
			System.debug('XXX entre if:');
			for(Integer i =0; i < TeamMemberSubscription.size(); i++ )
			{	
				System.debug('XXX entre for:');
				if(it < 10 || i == TeamMemberSubscription.size() ){
					System.debug('XXX entre segundo if:');
					address.add(TeamMemberSubscription[i].User__r.Email);
					it ++;
				}
				else
				{
					System.debug('XXX entre else del segundo if:');
					SendMail(address, TeamMemberSubscription[0].Team__r, emailMsj, emailSub);
					it = 0;
				}
			}
		}
		else if(TeamMemberSubscription.size() > 0 && TeamMemberSubscription != null)
		{	
			System.debug('XXX entre else if, ...');
			for(WikiSubscription__c ts : TeamMemberSubscription)
			{
				System.debug('XXX entre al else if: y for, mail  :'+ts.User__r.Email);
				address.add(ts.User__r.Email);
			}
			SendMail(address, TeamMemberSubscription[0].Team__r, emailMsj, emailSub);
		}
	}

	
	public void sendModifiedPageMessage( String IdPage, String acction )
	{
		String wikiName = '';
		String wikiId = ''; 
		String emailSub = '';
		String emailMsj = '';
		TeamUtil.hostName = TeamUtil.getHost(ApexPages.currentPage());

		WikiPage__c wp = new WikiPage__c();
		wp = [ SELECT Id, Wiki__c, Wiki__r.Name, LastModifiedById, LastModifiedBy.Name, CreatedById FROM WikiPage__c WHERE Id =: IdPage ];
		if( wp.LastModifiedById != wp.CreatedById )
		{
			emailSub = 'Wiki page ' + wikiName + ' with in Discussion Forum ' + wp.Wiki__r.Name + ' has been ' + (( acction == 'update' ) ? 'updated' : 'deleted');
			emailMsj = 'Wiki page ' + wikiName + ' has been '+ acction +' by <a href="// '+ TeamUtil.hostName +'/?id=' + wp.LastModifiedById + '">' +  wp.LastModifiedBy.Name + '</a>'; 
			if( acction == 'update' )
			emailMsj += '<br><a href="https://' + TeamUtil.hostName + '/apex/WikiPage?idWP=' + wp.Id + '">Click here to see the page</a>.';


			if (!isTest) 
			{
				TeamMemberSubscription = [Select  
					t.WikiPageUpdated__c, 
					t.WikiNewPage__c, 
					t.WikiCreatedByMeUpdated__c, 
					t.User__c, 
					t.User__r.Id,
					t.User__r.Name,
					t.User__r.Email,
					t.Team__c,
					t.Team__r.Name,
					t.Team__r.Id, 
					t.TeamMemberStatusUpdated__c, 
					t.TeamMemberJoinLeave__c, 
					t.Id
					From WikiSubscription__c t
					where Team__c =: wp.Wiki__c and ((WikiPageUpdated__c = true and User__c !=:wp.createdById) or (WikiCreatedByMeUpdated__c = true and User__c =:wp.createdById))];
			}			
			//Array address
			String[] address = new String[]{}; 
			if(TeamMemberSubscription.size() > 0 && TeamMemberSubscription != null)
			{	
				for(WikiSubscription__c ts : TeamMemberSubscription)
				{
					address.add(ts.User__r.Email);
				}
				SendMail(address, TeamMemberSubscription[0].Team__r, emailMsj, emailSub);
			}
		}
	}
	
	
	public void wikiDeleted(List<String> idsWiki){
		String emailSub;
		String emailMsj;
		Wiki__c wiki = new Wiki__c();
		
		for(String idWiki : idsWiki){
			
			wiki = [ SELECT Name, LastModifiedById, LastModifiedBy.Name FROM Wiki__c WHERE Id =: idWiki ];
						
			emailSub = 'Wiki ' + wiki.Name + ' has been deleted.';
			emailMsj = 'Wiki <b>' + wiki.Name + '</b> has been deleted by <a href="https://' + TeamUtil.getDomain() + '/' + wiki.LastModifiedById + '">' +  wiki.LastModifiedBy.Name + '</a>';
			
			if (!isTest) 
			{
				TeamMemberSubscription = [Select 
								t.WikiPageUpdated__c, 
								t.WikiNewPage__c, 
								t.WikiCreatedByMeUpdated__c, 
								t.User__c, 
								t.User__r.Id,
								t.User__r.Name,
								t.User__r.Email,
								t.Team__c,
								t.Team__r.Name,
								t.Team__r.Id, 
								t.TeamMemberStatusUpdated__c, 
								t.TeamMemberJoinLeave__c, 
								t.Id
								From WikiSubscription__c t
								where Team__c =: idWiki] ; 
			} 
						
			//Array address
			String[] address = new String[]{}; 
			Integer it = 0;
			if(TeamMemberSubscription.size() > 10)
			{
				for(Integer i =0; i < TeamMemberSubscription.size(); i++ )
				{	
					if(it < 10 || i == TeamMemberSubscription.size() ){
						address.add(TeamMemberSubscription[i].User__r.Email);
						it ++;
					}
					else
					{
						SendMail(address, TeamMemberSubscription[0].Team__r, emailMsj, emailSub);
						it = 0;
					}
				}
			}
			else if(TeamMemberSubscription.size() > 0 && TeamMemberSubscription != null)
			{	
				for(WikiSubscription__c ts : TeamMemberSubscription)
				{
					address.add(ts.User__r.Email);
				}
				SendMail(address, TeamMemberSubscription[0].Team__r, emailMsj, emailSub);
			}
		
		}//end of 'for(String idWiki : idsWiki)'
						
	}
			
	/**
	* SEND MAIL
	*@param String[] e-mails Array
	*@param Team__c team
	*@param String message
	*@param String subject
	*/
	Boolean alreadySent = false;
	public void SendMail(String[] toAddresses , Wiki__c team,  String Message, String subject) {
 		// Assign thsetReplyToe addresses for the To and CC lists to the mail object.
		mail.setToAddresses(toAddresses);
		// Specify the address used when the recipients reply to the email.
		mail.setReplyTo('forwardtosfdc@gmail.com');
 		// Specify the name used as the display name.
		mail.setSenderDisplayName('Team Subscribe');  
		//Specify the subject line for your email address.
		mail.setSubject(subject);

		mail.setSenderDisplayName(team.Name);
		// Set to True if you want to BCC yourself on the email.
		mail.setBccSender(false);
		// Optionally append the salesforce.com email signature to the email.
		// The email address of the user executing the Apex Code will be used.
		mail.setUseSignature(true); 
		//Set Content Mail
		mail.setHtmlBody(Message);
		// Send the email you have created.
        if(!alreadySent)
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    	alreadySent = true;
    }
}
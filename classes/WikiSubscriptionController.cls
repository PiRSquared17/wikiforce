public class WikiSubscriptionController {


	public String idTeam = System.currentPageReference().getParameters().get('id');
	Integer subscriptionCount;

	/**
	* Constructor
	*/
	public WikiSubscriptionController () {
		constructMethods(); 
	}
	
	/**
	*@return Integer
	*/
	public Integer getSubscriptionCount () {
		return subscriptionCount;
	}
	
	public WikiSubscription__c subscription = new WikiSubscription__c();
	
	/**
	*@return TeamSubscription__c
	*/
	public WikiSubscription__c getSubscription () {
		return subscription;
	}
	
	/**
	*@param String
	*/
	public void setIdTeam (String idTeam) {
		this.idTeam = idTeam; 
	}
	
	/**
	*@return String
	*/
	public String getIdTeam () {
		return idTeam;
	}

	/**
	* Execute on Construct
	*/
	public void constructMethods () {
		if (idTeam != null) {
			List<WikiSubscription__c> teamSubList = new List<WikiSubscription__c>();
			teamSubList = [select id,    
							TeamMemberStatusUpdated__c,
							TeamMemberJoinLeave__c, 
							WikiCreatedByMeUpdated__c,
							WikiNewPage__c,
							WikiPageUpdated__c,
							Team__c,
							User__c
						from WikiSubscription__c where User__c =:UserInfo.getUserId() and Team__c =: idTeam limit 1];
			if (teamSubList.size() > 0 ) {
				subscription = teamSubList[0];
			}	
			subscriptionCount = teamSubList.size();
		}
	}
	
	/**
	* Save suscription
	*@return PageReference
	*/
	public PageReference saveSubscription () {
		if (subscriptionCount > 0) {
			update 	subscription;	
		}else {
			subscription.Team__c = idTeam;
			subscription.User__c = UserInfo.getUserId();
			insert subscription;
		}
		PageReference pageRef = Page.WikiTeamOverview;
		pageRef.getParameters().put('tid', idTeam);
		pageRef.setRedirect(true);
		return pageRef;
	}
	
	/**
	* Cancel suscription
	*@return PageReference
	*/
	public PageReference cancelSubscription () {
		PageReference pageRef = Page.WikiTeamOverview;
		pageRef.getParameters().put('tid', idTeam);
		pageRef.setRedirect(true);
		return pageRef;
	}
	
	/**
	* Delete suscription
	*@return PageReference
	*/
	public PageReference deleteSubscription () {
		if (subscription != null && subscriptionCount > 0 ) 
			delete subscription;
		
		PageReference pageRef = Page.WikiTeamOverview;
		pageRef.getParameters().put('tid', idTeam);
		pageRef.setRedirect(true);
		return pageRef;
	}
	
}
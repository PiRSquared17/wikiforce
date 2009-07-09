public class WikiSetupController {


	private List<SelectOption> allProfiles   = new List<SelectOption>(); 
	private List<SelectOption> savedProfiles = new List<SelectOption>(); 
	public String selectedProfsStr = '';
	private List<String> selectedProfsList = new List<String>();
	private	List<WikiSetup__c> savedProfilesStr = new List<WikiSetup__c>();
	
	/**
	* Constructor
	*/
	public WikiSetupController(){		
		this.setingAllProfiles();
	}
	
	public void setSelectedProfilesList( String[] s){
		String p = s[0];
	}
	
	public String[] getSelectedProfilesList(){
		String[] p = new String[]{};
		return p;
	}
	
	/**
	*
	*/
	public List<SelectOption> getAllProfiles(){
		return this.allProfiles;
	}

	/**
	*
	*/
	public List<SelectOption> getSavedProfiles(){
		this.setingAllProfiles();
		/**
		if( this.savedProfiles.size() == 0 ){
			Profile admProfile = [ select id, name from Profile where name = 'System Administrator'];			
			this.savedProfiles.add( new SelectOption( admProfile.id, admProfile.name ));
		}
		*/
		return this.savedProfiles;
	}

	/**
	*
	*/	
	public PageReference saveAdmSettings(){
		
		if( this.savedProfilesStr.size() > 0 ){
			this.savedProfilesStr[0].CanViewButtonNew__c =  selectedProfsStr;
			update this.savedProfilesStr;
		}else{
			WikiSetup__c newSetup  = new WikiSetup__c();
			newSetup.CanViewButtonNew__c = this.selectedProfsStr;
			insert newSetup;
		}

		this.setingAllProfiles();
		
		PageReference pr = new PageReference('/apex/WikiOverview');
		pr.setRedirect( true );
		return pr;
	}
	
	/**
	*
	*/
	public void setSelectedProfsStr( String s ){
		this.selectedProfsStr = s;
	}

	/**
	*
	*/
	public String getSelectedProfsStr(){
		return this.selectedProfsStr;
	}
	
	// Private methods

	/**
	*
	*/
	private void setingAllProfiles(){

		this.allProfiles.clear();
		this.savedProfiles.clear();
		this.selectedProfsList.clear();
		
		this.stringProfiles();
		
		// Profiles can't view
		List<Profile> allProfilesTemp = new List<Profile>(); 
		allProfilesTemp = [ select id, name from Profile where id not in: this.selectedProfsList and name != 'System Administrator'];
		
		if( allProfilesTemp.size() > 0 ){
			this.allProfiles.clear();
			for( Profile pr : allProfilesTemp )
				this.allProfiles.add( new SelectOption( pr.id, pr.name ));
		}	
		
		// Profiles can view
		if( this.savedProfilesStr.size() > 0 )
		if( savedProfilesStr[0].CanViewButtonNew__c != null ){ 
			
			List<Profile> savedProfilesTemp = new List<Profile>(); 
			savedProfilesTemp = [ select id, name from Profile where id in: this.selectedProfsList ];
			
			if( savedProfilesTemp.size() > 0 ){
				this.savedProfiles.clear();
				for( Profile pr : savedProfilesTemp )
					this.savedProfiles.add( new SelectOption( pr.id, pr.name )); 
			}
		}	
	}
	
	/**
	*
	*/
	public void stringProfiles(){
		this.savedProfilesStr = [ select Id, CanViewButtonNew__c from WikiSetup__c limit 1 ];
		if( this.savedProfilesStr.size() > 0 ){
			if(savedProfilesStr[0].CanViewButtonNew__c != null )
				this.selectedProfsList = savedProfilesStr[0].CanViewButtonNew__c.split( '#' );
		}
	}
	
	/**
	*
	*/
	public Boolean canView(){		
		if( savedProfilesStr.size() > 0 )
			if(savedProfilesStr[0].CanViewButtonNew__c != null)
				return  this.getIfCanModifyAllData() || savedProfilesStr[0].CanViewButtonNew__c.contains(UserInfo.getProfileId());


		return  this.getIfCanModifyAllData();
		
	}	

	/**
	*
	*/
	public Boolean getIfCanModifyAllData(){
		List<User> aProfile = new List<User>();
		aProfile = [Select id, Profile.PermissionsModifyAllData From User where id =: UserInfo.getUserId() ];
		
		if( aProfile.size() > 0 ) 		
			return aProfile[0].Profile.PermissionsModifyAllData;
		else
			return false;
	}	

}
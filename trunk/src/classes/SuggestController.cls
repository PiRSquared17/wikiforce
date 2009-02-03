/**
* Class to controll the suggestions of Imput Text fields
*@author Bruno Fagundez @ 5-20-2008
*/
public class SuggestController {

	public String paramInput;
	public String paramClass;
	public String paramTeamId;
	List<Suggestions> suggestionList = new List<Suggestions>();
	
	/**
	* Search results for the inserted text deppending the 'class' param
	* Possible class param values: 'Competency', 'colleagueNames', 'Employer', 'School';
	*@Constructor
	*/
	public SuggestController(){
		 String inputValue = System.currentPageReference().getParameters().get('input').trim();
		 paramInput = '%' + inputValue + '%';
		 paramClass = System.currentPageReference().getParameters().get('class');		
		 paramTeamId = System.currentPageReference().getParameters().get('wikiId');
		
		//Suggestion for colleague names object
		if (paramClass == 'colleagueNames'){
			
			Map<Id, WikiMember__c> teamMemberMap = new Map<Id, WikiMember__c>();
			for (WikiMember__c iterMember : [select Id, User__c from WikiMember__c where wiki__c =:paramTeamId]) {
				teamMemberMap.put(iterMember.User__c, iterMember);
			} 
			
			for(User c : [select Name, Id from User where Name like :paramInput order by Name]){
				System.debug('Estoy recorriendo los resultados');
				if (teamMemberMap.get(c.Id) == null) {
					Suggestions suggest = new Suggestions();
					suggest.setName(c.Name);
					suggest.setId(c.Id);
					suggestionList.add(suggest);
				}				
			}
		}
	}
	
	/**
	* Return the suggestion's list
	*@return List<Suggestions>
	*/
	public List<Suggestions> getSuggestion(){
		return suggestionList;
	}
	
	/**
	* Inner class for Suggestion's type
	*@class
	*/
	public class Suggestions {
		String Name;
		String Id;
		
		/**
		* Set text to the suggerence
		*@param String
		*/
		public void setName(String sName){
			Name = sName;
		}
		
		/**
		* Get text from the suggerence
		*@return String
		*/
		public String getName(){
			return Name;
		}
		
		/**
		* Set id value of the suggerence
		*@param String
		*/
		public void setId(String sId){
			Id = sId;
		}
		
		/**
		* Get id of the suggerence
		*@return String
		*/
		public String getId(){
			return Id;
		}
	
	}	    
}
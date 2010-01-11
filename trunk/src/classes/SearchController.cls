/**
*@author German Barrios @ 05-01-2009
*/ 
public class SearchController {
	// Parameter with action
	private String module = null;
	
	// Parameter with search string
	private String key = null;
	
	// Parameter for seach in team
	private String teamId = null;
	
	// Text of search label
	private String label = '';
	
	// Default input field text value
	private String defText = '';
	
	// Map with action=>PageReference
	private Map<String, PageReference> searchIn = new Map<String, PageReference>{
		'wiki' => Page.WikiSearchResult
	};
	
	/**
	* Redirect to the specific result
	*@return PageReference
	*/
	public PageReference searchKey(){

		if(this.module != null && this.module != ''){
			PageReference pageRef = searchIn.get(module);
			pageRef.getParameters().put('key', this.key);
			if(this.teamId != null || this.teamId != '')
				pageRef.getParameters().put('id', this.teamId);
			pageRef.setRedirect(true);
			
			return pageRef;
		}else {
			return null;
		}
	}
	
	/**
	*@param String action
	*/
	public void setModule(String mod){
		this.module = mod;
	}
	
	/**
	*@return String
	*/
	public String getModule(){
		return this.module;
	}
	
	/**
	*@return String
	*/
	public String getKey(){
		return this.key;
	}
	
	/**
	*@param String
	*/
	public void setKey(String k){
		this.key = k;
	}
	
	/**
	*@return String
	*/
	public String getTeamId(){
		return this.teamId;
	}
	
	/**
	*@param String
	*/
	public void setTeamId(String id){
		this.teamId = id;
	}
	
	/**
	* Get value of label
	*@return String label
	*/
	public String getLabel(){
		String txt;
		if(module == 'wiki'){
			txt = 'Wiki Pages';
		}else if(module == 'wikioverview'){
			txt = 'Wiki';
		}else {
			txt = '';
		}
		this.label = txt;
		return this.label;
	}
	
	/**
	* Get value of default input field value
	*@return String text
	*/
	public String getDefaultText(){
		String txt = 'Enter ';
		if(module == 'wiki'){
			txt = txt + 'wiki page...';	
		}else {
			txt = '';
		}
		this.defText = txt;
		return this.defText;
	}
}
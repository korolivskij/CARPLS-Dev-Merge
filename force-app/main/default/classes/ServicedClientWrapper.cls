public with sharing class ServicedClientWrapper {

	public	Contact				client					{ get; set; }
	public	Case				latestCase				{ get; set; }
	public 	ProblemCodeWrapper	pcWrap					{ get; set; }
	
	public ServicedClientWrapper(Contact client, Case cse) {
		this.client = client;
		this.latestCase = cse;
		this.pcWrap = new ProblemCodeWrapper(cse);
	}
}
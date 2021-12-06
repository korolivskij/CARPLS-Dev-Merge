public  class FeedItemWrapper {
	
	public FeedItem						fi		{	get; set; }
	public ContentVersion				cv		{	get; set; }
	
	public FeedItemWrapper(FeedItem aFi, ContentVersion aCv) {
		this.fi = aFi;	
		this.cv = aCv;
	}
	
	
	
}
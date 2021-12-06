global class NotesWrapper implements Comparable {
    
    public Static Final Datetime	IMPLEMENTATION_DATE = 
    								Datetime.newInstance(2014,06,02);
     
    public Note                 note                { get; set; }
    public String               first100Body        { get; set; }
    public Boolean              longNote            { get; set; }
    public String               creatorProfileName  { get; set; }  
    public Datetime				serviceDate			{ get; set; } 
    public String 				aocName             { get; set; } 
		
    //old version 
    public NotesWrapper(Note n, Datetime d) {
        this.note = n;
        this.servicedate = d;
        this.longNote = false;
        this.aocName=[SELECT Id,AOC__r.Name FROM Consultation__c WHERE Id=:note.parentId].AOC__r.Name;
        if(n!=null && n.body!=null && n.body.length() > 100) {
            first100Body = n.body.subString(0,100);
            this.longNote = true;
            Id createdById  = note.CreatedById;
            this.creatorProfileName = UserUtils.getProfileNameByUserId(createdById);
        }
    }

     // added By Stepan 
		public NotesWrapper(Note n, Datetime d , String aocName) {
			this.note = n;
			this.servicedate = d;
			this.longNote = false;
			this.aocName = aocName;
			if(n!=null && n.body!=null && n.body.length() > 100) {
					first100Body = n.body.subString(0,100);
					this.longNote = true;
					Id createdById  = note.CreatedById;
					this.creatorProfileName = UserUtils.getProfileNameByUserId(createdById);
			}
	}
    
    global Integer CompareTo(Object compareTo) {
    	
    	NotesWrapper nw = (NotesWrapper) compareTo;
    	
    	if ((this.note.createddate < IMPLEMENTATION_DATE) &&
    				(nw.note.createddate < IMPLEMENTATION_DATE)) {
    		if (this.serviceDate == nw.serviceDate) {
    			return 0;
    		} else {
    			if (this.serviceDate < nw.serviceDate) {
    				return -1;
    			} else {
    				return 1;
    			} 
    		}
    	} else {
    		if (this.note.createddate == nw.note.createddate) {
    			return 0;
    		} else {
    			if (this.note.createddate < nw.note.createddate) {
    				return -1;
    			} else {
    				return 1;
    			} 
    		}
    	}
    }
}
global class ContactResult implements Comparable {
       
        public Contact c {get;set;}
        public List<Case_Party__c> caseParties {get;set;}
        
        public String association  { get;set; }
               
        public string matches {get;set;}
        public string confidence {get;set;}
        public string autoMatch {get;set;}
        public integer matchScore {get;set;}
        public string markedAsMatch {get;set;}
         
      //  public Static string sortBy


    	public String getCrLastNameSanitized() {
    		String clean = '';
    		if(c != null) {
    			String rawLn = c.lastName;
    			if(rawLn != null) {
    				clean = String.escapeSingleQuotes(rawLn);
    			}
    		}
    		return clean;
    	}        
        /**
         * RJN Late Add. Case party for display in party search results association field
         * rjn unique case_party__c.type__c (assocation) values. Probably not the best in performance
         * @TODO Performance improvement.
         */       
        public List<String> getCasePartyAssociations() {
            List<String> cpas = new List<String>();
            if(caseParties == null || caseParties.isEmpty()) {
                return cpas;
            }
            for(Case_Party__c cp : caseParties) {
                Boolean alreadyAdded = false;
                for(String s : cpas) {
                    if(s == cp.type__c) {
                        alreadyAdded = true;
                        break;
                    }
                }
                if(!alreadyAdded) {
                    cpas.add(cp.type__c);
                }
            }
            return cpas;
            
        }
        global Integer compareTo(Object compareTo) {
            System.debug(logginglevel.debug, 'RJN Sorting contactResult');
            if (compareTo != null){
            ContactResult contactResult = (ContactResult )compareTo;
            integer tresult = 0;
            //if user marked as no match .. move it one down in the sort order.
            if(markedAsMatch != null) {
                if(markedAsMatch.equalsIgnoreCase('No')) {
                    return 2;
                }
            }
            if(contactResult.markedAsMatch != null) {
                if(contactResult.markedAsMatch.equalsIgnoreCase('No')) {
                    return -2;
                }
            }            
            
            
            
            if (matchScore == contactResult.matchScore) {
                // If they have the same match number, we want them sorted first by record type
                Integer thisTypeNum = 0;
                Integer crTypeNum = 0;
                String sCategory = '';
                List<String> cCategories = Utilities.getPlValues(c.category__c);
                List<String> crCategories = Utilities.getPlValues(contactResult.c.category__c);
                if(cCategories == null || cCategories.isEmpty()) {
                    return -1;
                }
                if(crCategories == null || crCategories.isEmpty()) {
                    return -1;
                }               
                
                if (Utilities.doesListHaveValue(cCategories,'Client')) {
                    thisTypeNum = 3;
                    
                } else if (Utilities.doesListHaveValue(cCategories,'Attorney')) {
                    thisTypeNum = 2;
                } else if (Utilities.doesListHaveValue(cCategories,'Party')) {
                    thisTypeNum = 1;
                }
                
                if (Utilities.doesListHaveValue(crCategories,'Client')) {
                    crTypeNum = 3;
                    
                } else if (Utilities.doesListHaveValue(crCategories,'Attorney')) {
                    crTypeNum = 2;
                } else if (Utilities.doesListHaveValue(crCategories,'Party')) {
                    crTypeNum = 1;
                }

            
                if (thisTypeNum != crTypeNum) {
                    if (thisTypeNum > crTypeNum) {
                        return -1;
                    } else {
                        return 1;
                    }
                }
               
               if (c.Last_Service_date__c == contactResult.c.Last_Service_Date__c){
               		 // do nothing
               } else {
                    if (c.Last_Service_Date__c > contactResult.c.Last_Service_Date__c){
                         return -1;
                    } else {
                         return 1;
                    }
                }
            } 
            if (matchScore > contactResult.matchScore) {
                return -1;
            } else {
                return 1;
            }
        }
        else {
            return -1;
        }
        }
}
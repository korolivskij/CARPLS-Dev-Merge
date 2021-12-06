Public with sharing class DdpWrapper implements Comparable {
        Public Loop__DDP__c ddp{get;set;}
        Public Boolean checkBox{get;set;}   
        public Integer sortOrder{get;set;}
        
        Public DdpWrapper( Loop__DDP__c d, boolean selected){
            ddp         = d;
            checkBox    = selected;
            if(selected) { sortOrder = 1;} else { sortOrder = 0; }
        }
        public Integer compareTo(Object oToCompare) {
            if(sortOrder > ((DdpWrapper)oToCompare).sortOrder) {
                return 0;
            } else {
                return 1;
            }
        }       
     }
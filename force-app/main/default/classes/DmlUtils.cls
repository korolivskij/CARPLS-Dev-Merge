public class DmlUtils {

	/**
     * Executes a Database.DBUpdate for a list of sObjects.
     *
	 * Note: this has the potential to throw a DMLException thus should be 
	 * caught by the calling class if desired.
     *
     * @param 	sObject		- a single sObject.
     * @param   bAllOrNone	- specifiy true to only update if all records updated successfully.
     *
     * @returns Boolean		- true if success.
     */     
     public static Set<Id> DBUpdate(List<Sobject> sObjects, Boolean bAllOrNone) {
     	Set<Id> updatedIds = new Set<Id>();
     	DataBase.Saveresult[] lsr = Database.update(sObjects,bAllOrNone);
     	
     	for(Database.Saveresult sr : lsr) {
     		if(!sr.isSuccess()) {
     			Database.Error err = sr.getErrors()[0];
				System.debug('-------------> DMLWrapper  custom class Update Error!! msg= '+err.getMessage()+ 'sc='+err.getStatusCode());
     		} else {
     			Id updatedId = sr.getId();
     			if(updatedId != null) {
     				updatedIds.add(updatedId);
     			}    				
     		}
     	}
     	return updatedIds;
     }
     
     
     public static Boolean DBUpdate(Sobject sObj) {
     	Boolean success = false;
     	List<SObject> sObjects = new List<SObject>();
     	sObjects.add(sObj);
     	
     	Set<Id> idsUpdated = DBUpdate(sObjects, true);
     	if(idsUpdated == null || idsUpdated.size() == 0) {
     		success = false;
     	} else {
			success = true;
     	}
     	return success;  	
     }
	/**
     * Executes a Database.Insert for a list of sObjects.
     *
	 * Note: this has the potential to throw a DMLException thus should be 
	 * caught by the calling class if desired.
     *
     * @param 	sObject		- a single sObject.
     * @param   bAllOrNone	- specifiy true to only  if all records updated successfully.
     *
     * @returns Set<Id>		- all id's inserted.
     */     
     public static Set<Id> DBInsert(List<Sobject> sObjects, Boolean bAllOrNone) {
     	Set<Id> insertedIds = new Set<Id>();
     	
     	DataBase.Saveresult[] lsr; 
     	//try {
     		lsr = Database.insert(sObjects,bAllOrNone);
     	//} catch (Exception e) {
     	//	System.debug(logginglevel.error,e);
     		
     	//}    	
     	for(Database.Saveresult sr : lsr) {
     		if(!sr.isSuccess()) {
     			Database.Error err = sr.getErrors()[0];
				System.debug('-------------> DMLWrapper  custom class Insert Error!! msg= '+err.getMessage()+ 'sc='+err.getStatusCode());
     		} else {
     			Id insertedId = sr.getId();
     			if(insertedId != null) {
     				insertedIds.add(insertedId);
     			}    				
     		}
     	}
     	return insertedIds;
     }
	/**
     * Executes a Database.Upsert for a list of sObjects.
     *
	 * Note: this has the potential to throw a DMLException thus should be 
	 * caught by the calling class if desired.
     *
     * @param 	sObject		- a single sObject.
     * @param   bAllOrNone	- specifiy true to only  if all records upserted successfully.
     *
     * @returns Set<Id>		- all id's 
     */     
     public static Set<Id> DBUpsert(List<Sobject> sObjects, Boolean bAllOrNone) {
     	Set<Id> upsertedIds = new Set<Id>();
     	
     	DataBase.Upsertresult[] lur; 
     	try {
     		lur = Database.upsert(sObjects,bAllOrNone);
     	} catch (Exception e) {
     		System.debug(logginglevel.error,e);
     		
     	}    	
     	for(Database.Upsertresult ur : lur) {
     		if(!ur.isSuccess()) {
     			Database.Error err = ur.getErrors()[0];
				System.debug('-------------> DMLWrapper  custom class Upsert Error!! msg= '+err.getMessage()+ 'sc='+err.getStatusCode());
     		} else {
     			Id insertedId = ur.getId();
     			if(insertedId != null) {
     				upsertedIds.add(insertedId);
     			}    				
     		}
     	}
     	return upsertedIds;
     }     
     
     public static Id DBInsert(Sobject sObj) {
		Id idInserted;
		
     	List<SObject> sObjects = new List<SObject>();
     	sObjects.add(sObj);
     	
     	Set<Id> idsInserted = DBInsert(sObjects, true);
     	if(idsInserted == null || idsInserted.size() == 0) {
     		//
     	} else {
     		for(Id id :idsInserted) {
     			idInserted = id;
     			break;
     		}
			//idInserted = idsInserted.
     	}
     	return idInserted;  	
     }

     /**
      *
      *
      */
     public static Set<Id> DBDelete(List<Sobject> sObjects, Boolean bAllOrNone) {
     	Set<Id> deletedIds = new Set<Id>();
     	
     	DataBase.DeleteResult[] ldr = Database.delete(sObjects,bAllOrNone);
     	Boolean success = true;
     	for(Database.DeleteResult dr : ldr) {
     		if(!dr.isSuccess()) {
     			Database.Error err = dr.getErrors()[0];
     			success = false;
				System.debug('-------------> DMLWrapper  custom class Delete Error!! msg= '+err.getMessage()+ 'sc='+err.getStatusCode());
     		} else {
				Id deletedId = dr.getId();
     			if(deletedId != null) {
     				deletedIds.add(deletedId);
     			}    	
     		}
     	}
   		return deletedIds;     	
     } 
         
     public static Boolean DBDelete(Sobject sObj) {
     	Boolean success = false;
     	List<SObject> sObjects = new List<SObject>();
     	sObjects.add(sObj);
     	
     	Set<Id> idsDeleted = DBDelete(sObjects, true);
     	if(idsDeleted== null || idsDeleted.size() == 0) {
     		success = false;
     	} else {
			success = true;
     	}
     	return success;  	
     }
}
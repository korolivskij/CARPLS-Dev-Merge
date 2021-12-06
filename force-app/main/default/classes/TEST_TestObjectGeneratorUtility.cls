@isTest
public class TEST_TestObjectGeneratorUtility 
{
    public abstract class TestObjectGenerator
    {
        protected Integer Iterable { get; set; }
        public GeneratorOverride OverwrittenGeneration { get; set; }
        protected abstract sObject AddSpecifiedObjectType();

        public TestObjectGenerator()
        {
            this.Iterable = 0;
        }
        public sObject GenerateSingleTestsObject(Boolean InsertNow) {
            sObject sObj;
            
            List<SObject> sObjects = this.GenerateTestsObjects(1,InsertNow);
            if(sObjects != null && !sObjects.isEmpty()) {
                sObj = sObjects[0]; 
            }   
            return sObj;
        }
        public List<sObject> GenerateTestsObjects(Integer NumberOfObjects, Boolean InsertNow)
        {
            List<sObject> ObjectList = new List<sObject>();

            for(; this.Iterable < NumberOfObjects; this.Iterable++)
                ObjectList.add( (this.OverwrittenGeneration != null) ? this.OverwrittenGeneration.RetrieveOverwrittensObject(this.Iterable) : this.AddSpecifiedObjectType());
            this.Iterable = 0;    
            if(InsertNow)
                INSERT ObjectList;
            return ObjectList;
        }

        public virtual void InitializeRequiredData() { }
        public virtual void DeletedRequiredData() { }
    }

    public abstract class GeneratorOverride
    {
        public abstract sObject RetrieveOverwrittensObject(Integer Iterable);   
    }

    private class ContactGenerator extends TestObjectGenerator {
        public override sObject AddSpecifiedObjectType() {
            return new Contact(LastName = 'Testey ' + this.Iterable /*Fill in fields here*/);
        }
    }
    private class CaseGenerator extends TestObjectGenerator {
        public override sObject AddSpecifiedObjectType() {
            RecordType rt = Utilities.retrieveRecordTypeBySObjectNameAndDevNAme('Case','Carpls_Cases');         
            return new Case(Subject = 'Test Case ' + this.Iterable, recordtypeId = rt.id /*Fill in fields here*/);
        }
    }
    
    private class TaskGenerator extends TestObjectGenerator {
        public override sObject AddSpecifiedObjectType() {              
            return new Task ( type='Call',Status='In Progress',Priority='High',Subject='TEST Task' + this.iterable,ActivityDate=Date.today() );            
        }
    }        
    private class SearchLogClientGenerator extends TestObjectGenerator {
        public override sObject AddSpecifiedObjectType() {
            
            Search_Log__c slClient = new Search_Log__c();
            slClient.Street_Address_Line_1__c = '4916 Main Street Unit 2';
            slClient.Phone__c = '(630) 310-0898';
            slClient.Aliases__c = 'test';
            slClient.First_Name__c = 'Rick';
            slClient.Last_Four_SSN__c = '5419';
            slClient.Association__c = 'Client';
            //Birthdate__c = new Date.today();
            slClient.Last_Name__c = 'Nendza' + this.iterable;     
     
            return slClient;
        }
    }

    public static TestObjectGenerator RetrieveGenerator(Schema.sObjectType sObjectTypeRequested)
    {
        if(sObjectTypeRequested.getDescribe().getName().equals('Contact')) {
            return new ContactGenerator();
        }
        if(sObjectTypeRequested.getDescribe().getName().equals('Case')) {
            return new CaseGenerator();
        }     
        if(sObjectTypeRequested.getDescribe().getName().equals('Search_Log__c')) {
            return new SearchLogClientGenerator();
        }                 
        return null;
    }
}
@isTest
private class TEST_TestObjectGeneratorUtilityDemo 
{
    public class ContactOverwriteDemo extends TEST_TestObjectGeneratorUtility.GeneratorOverride
    {
        private String TestContactName { get; set; }

        public ContactOverwriteDemo (String TestName)
        {
            this.TestContactName = TestName;
        }

        public override sObject RetrieveOverwrittensObject(Integer Iterable)
        {
            return new Contact(LastName = (this.TestContactName != null ? this.TestContactName : 'Test Overwritten Product' )  + String.valueOf(Iterable) /*Initialize other fields here*/);
        }
    }

    /*
        This demonstration shows the versitility of the TEST_TestObjectGeneratorUtility. To best view the log, please change your log level to 'Info'.
    */
    static testMethod void TEST_TestObjectGeneratorUtilityDemonstration() 
    {
        System.Debug(LoggingLevel.Info, '\n*****Let\'s start the TEST_TestObjectGeneratorUtility Demonstration*****\n');

        TEST_TestObjectGeneratorUtility.TestObjectGenerator DemonstrationGenerator = TEST_TestObjectGeneratorUtility.RetrieveGenerator(Contact.sObjectType);

        //Let's create a standard Contact first.
        System.Debug(LoggingLevel.Info, '\nLet\'s create a basic Contact sObject first.\n');
        System.Debug(LoggingLevel.Info, String.valueOf(DemonstrationGenerator.GenerateTestsObjects(1, false)));
 
        //Now let's try an overwritten Contact and insert two of them.
        TEST_TestObjectGeneratorUtility.GeneratorOverride MyCustomOverride = new ContactOverwriteDemo ('ProgrammableMedley ');
        DemonstrationGenerator.OverwrittenGeneration = MyCustomOverride;

        System.Debug(LoggingLevel.Info, String.valueOf(DemonstrationGenerator.GenerateTestsObjects(2, true)));

        //To go back to the standard creation of Contact...
        DemonstrationGenerator.OverwrittenGeneration = null;    
    }
}
@isTest
private class TEST_NotesWrapper {
	@isTest
    static void testWrapperMethod1(){
        Case testCase = new Case();
        insert testCase;
        Consultation__c testServ=new Consultation__c(AOC__c=UserInfo.getUserId(),Case__c=testCase.Id);
        insert testServ;
        Note testNote = (Note) Json.deserialize('{"createdDate" : "2013-05-30T00:00:00Z",' +
                                   '"title" : "foo",' +
                                   '"body" : "fooBody",' +
                                   '"parentId" : "' + testServ.id + '"' +
                                  '}',
                                  Note.class);
		insert testNote; 
        String body100='';
        for(Integer i=0;i<101;i++){
            body100+=i;
        }
        Note testNote2 = (Note) Json.deserialize('{"createdDate" : "2013-05-30T00:00:00Z",' +
                                   '"title" : "foo2",' +
                                   '"body" : "'+body100+'",' +
                                   '"parentId" : "' + testServ.id + '",' +
                                   '"createdbyid" : "' + UserInfo.getUserId() + '"' +
                                  '}',
                                  Note.class);
        insert testNote2; 
        Test.startTest();
        NotesWrapper testWrap=new NotesWrapper(testNote,Date.today());
        NotesWrapper testWrap2=new NotesWrapper(testNote2,Date.today());
        testWrap.CompareTo(testWrap2);
        NotesWrapper testWrap3=new NotesWrapper(testNote2,Date.today()+1);
        testWrap.CompareTo(testWrap3);
        NotesWrapper testWrap4=new NotesWrapper(testNote2,Date.today()-1);
        testWrap.CompareTo(testWrap4);
        Test.stopTest();
 
        
    }
    @isTest
    static void testWrapperMethod2(){
        Case testCase = new Case();
        insert testCase;
        Consultation__c testServ=new Consultation__c(AOC__c=UserInfo.getUserId(),Case__c=testCase.Id);
        insert testServ;
        Note testNote = (Note) Json.deserialize('{"createdDate" : "2019-05-30T00:00:00Z",' +
                                   '"title" : "foo",' +
                                   '"body" : "fooBody",' +
                                   '"parentId" : "' + testServ.id + '"' +
                                  '}',
                                  Note.class);
		insert testNote; 
        Note testNote2 = (Note) Json.deserialize('{"createdDate" : "2019-05-30T00:00:00Z",' +
                                   '"title" : "foo2",' +
                                   '"body" : "fooBody2",' +
                                   '"parentId" : "' + testServ.id + '"' +
                                  '}',
                                  Note.class);
        insert testNote2;
        Test.startTest();
        NotesWrapper testWrap=new NotesWrapper(testNote,Date.today());
        NotesWrapper testWrap2=new NotesWrapper(testNote2,Date.today());
        testWrap.CompareTo(testWrap2);
        Test.stopTest();
    }
     @isTest
    static void testWrapperMethod3(){
        Case testCase = new Case();
        insert testCase;
        Consultation__c testServ=new Consultation__c(AOC__c=UserInfo.getUserId(),Case__c=testCase.Id);
        insert testServ;
        Note testNote = (Note) Json.deserialize('{"createdDate" : "2019-05-30T00:00:00Z",' +
                                   '"title" : "foo",' +
                                   '"body" : "fooBody",' +
                                   '"parentId" : "' + testServ.id + '"' +
                                  '}',
                                  Note.class);
		insert testNote; 
        Note testNote2 = (Note) Json.deserialize('{"createdDate" : "2018-05-30T00:00:00Z",' +
                                   '"title" : "foo2",' +
                                   '"body" : "fooBody2",' +
                                   '"parentId" : "' + testServ.id + '"' +
                                  '}',
                                  Note.class);
        insert testNote2;
        Test.startTest();
        NotesWrapper testWrap=new NotesWrapper(testNote,Date.today());
        NotesWrapper testWrap2=new NotesWrapper(testNote2,Date.today());
        testWrap.CompareTo(testWrap2);
        Test.stopTest();
    }

    @isTest
    static void testWrapperMethod4(){
        Case testCase = new Case();
        insert testCase;
        Consultation__c testServ=new Consultation__c(AOC__c=UserInfo.getUserId(),Case__c=testCase.Id);
        insert testServ;
        Note testNote = (Note) Json.deserialize('{"createdDate" : "2013-05-30T00:00:00Z",' +
                                   '"title" : "foo",' +
                                   '"body" : "fooBody",' +
                                   '"parentId" : "' + testServ.id + '"' +
                                  '}',
                                  Note.class);
		insert testNote; 
        String body100='';
        for(Integer i=0;i<101;i++){
            body100+=i;
        }
        Note testNote2 = (Note) Json.deserialize('{"createdDate" : "2013-05-30T00:00:00Z",' +
                                   '"title" : "foo2",' +
                                   '"body" : "'+body100+'",' +
                                   '"parentId" : "' + testServ.id + '",' +
                                   '"createdbyid" : "' + UserInfo.getUserId() + '"' +
                                  '}',
                                  Note.class);
        insert testNote2; 
        Test.startTest();
        NotesWrapper testWrap=new NotesWrapper(testNote,Date.today());
        NotesWrapper testWrap2=new NotesWrapper(testNote2,Date.today(), 'Test');
        testWrap.CompareTo(testWrap2);
        NotesWrapper testWrap3=new NotesWrapper(testNote2,Date.today()+1);
        testWrap.CompareTo(testWrap3);
        NotesWrapper testWrap4=new NotesWrapper(testNote2,Date.today()-1);
        testWrap.CompareTo(testWrap4);
        Test.stopTest();
 
        
    }

}
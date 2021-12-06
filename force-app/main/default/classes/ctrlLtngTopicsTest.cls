@isTest
private class ctrlLtngTopicsTest {
    @isTest
    private static void getRecentTopicsTest() {
        topic top = new topic(Name = 'Test');
        insert top;

        List<Topic> tops = ctrlLtngTopics.getRecentTopics();
        System.assertEquals(false, !tops.isEmpty());
    }
}
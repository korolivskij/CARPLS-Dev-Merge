/**
 * Created by rnend on 11/4/2016.
 */

@IsTest
private class TEST_ResponseDTO {
    static testMethod void testBehavior() {
        Test.startTest();
        ResponseDTO dto1 = new ResponseDTO();
        ResponseDTO dto2 = new ResponseDto(true,'message','edit');
        ResponseDTO dto3 = new ResponseDTO(false,'message');

        Test.stopTest();
    }
}
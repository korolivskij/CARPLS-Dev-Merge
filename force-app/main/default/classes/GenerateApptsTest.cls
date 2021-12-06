/**
* Provisio Partners
* @author David Cox <david.cox@provisiopartners.com>
* @date 10/01/2020
* @group Appointments
*
* @description Process to generate appointments  
* To Execute: 
* GenerateAppts appt = new GenerateAppts(date.newInstance(2020, 10, 17),1);
* appt.createAppts();
*
* @history David Cox 10/01/2020 Initial Version
**/
@isTest
public class GenerateApptsTest {
    

    @isTest
    static void GenerateApptsTest() {

        Test.startTest();

            GenerateAppts sdPO = new GenerateAppts();

        Test.stopTest();

    }
}
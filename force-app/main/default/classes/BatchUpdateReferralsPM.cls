//**
// Author: Ihor Onyshchenko
// Date: November 4, 2019
// Description: This is a Batch Class that update Referral status.
//
// This code is the property of Provisio Partners and copy or reuse is prohibited.
// Copyright @2018 Provisio Partners Illinois Ltd. All Rights Reserved.
// support@provisiopartners.org
//**

global class BatchUpdateReferralsPM implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        date today = date.today();
        String pickListValue = 'PM_1_5';
		String classQuery =  'SELECT ID FROM Referral__c WHERE Preferred_Call_Back_Date__c = today AND Preferred_Call_Back_Time__c = :pickListValue';
		return Database.getQueryLocator(classQuery);
	}

	global void execute(Database.BatchableContext BC, List<Referral__c > scope) {
		BatchUpdateReferralsHelper.updateReferrals(scope);
	}

	global void finish(Database.BatchableContext BC) {}

}
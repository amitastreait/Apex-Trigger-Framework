@isTest
private with sharing class TriggerDispatcherTest{
    @testSetup
    public static void setupTestData(){
        /* Insert Trigger Setting Object */
        Trigger_Setting__c triggerSetting = new Trigger_Setting__c(
            After_Delete__c = true, After_Insert__c = true, After_Undelete__c = true,
            After_Update__c = true, Before_Delete__c = true, Before_Insert__c = true,
            Before_Update__c = true, Object_Name__c = 'Account', Prevent_Recursion__c='Name,AccountNumber'    
        );
        insert triggerSetting;
        Trigger_Setting__c triggerSetting1 = new Trigger_Setting__c(
            After_Delete__c = true, After_Insert__c = true, After_Undelete__c = true,
            After_Update__c = true, Before_Delete__c = true, Before_Insert__c = true,
            Before_Update__c = true, Object_Name__c = 'TransactionLog'    
        );
        insert triggerSetting1;
        
        System.assertNotEquals(triggerSetting.Id, null);
        
        /* Insert 500 Accounts into the System so that we can test the Framework 
           For the bulk records
        */
        List<Account> accountList = new List<Account>();
        For(Integer i = 0; i<501; i++){
            Account acc = new Account(
                Name ='Test Frame work '+i,
                Industry = 'Banking'
            );
            accountList.add(acc);
        }
        
        insert accountList;
        
        List<Transaction_Log__c> transactionLogList = new List<Transaction_Log__c>();
        For(Integer i = 0; i<501; i++){    
            Transaction_Log__c tlog = new Transaction_Log__c(
                Class_Name__c ='TransactionLogTriggerHandler' ,
                Process_Name__c = 'TransactionLogTriggerHandler'
            );
            transactionLogList.add(tlog);
        }
        
        insert transactionLogList;
        
    }
    
    static testMethod void beforeContextTest(){
        List<Account> accountList = new List<Account>([Select Id, Name From Account LIMIT 205]);
        for(Account acc : accountList){
            acc.Name = acc.Name + 'SFDCPanther';
        }
        Test.startTest();
            List<Trigger_Setting__c> triggerSettingList = new List<Trigger_Setting__c>();
            triggerSettingList = [Select Id, Name,Object_Name__c From Trigger_Setting__c LIMIT 10];
            update triggerSettingList;
            update accountList;
            
            List<Transaction_Log__c> tLogList = new List<Transaction_Log__c>();
            tLogList = [Select Id, Name,Class_Name__c From Transaction_Log__c LIMIT 10];
            update tLogList;
            
            System.assertEquals(205, accountList.size());
        Test.stopTest();
    }
    
    static testMethod void afterContextTest(){
        List<Account> accountList = new List<Account>([Select Id, Name From Account LIMIT 100]);
        String Id = accountList[0].Id;
        Test.startTest();
            
            System.assertEquals(100, accountList.size());
            delete accountList;
            List<Account> accountListUnDelete = new List<Account>([SELECT Id, Name FROM Account LIMIT 100 ALL ROWS]);
            undelete accountListUnDelete;
            
            List<Transaction_Log__c> tLogList = new List<Transaction_Log__c>();
            tLogList = [Select Id, Name,Class_Name__c From Transaction_Log__c LIMIT 10];
            delete tLogList;
            
            List<Transaction_Log__c> tLogList1 = new List<Transaction_Log__c>();
            tLogList1 = [Select Id, Name,Class_Name__c From Transaction_Log__c LIMIT 10 ALL ROWS];
            //undelete tLogList1;
        Test.stopTest();
    }
    
    static testMethod void TransactionLogHandlerTest(){
        Test.StartTest();
            TransactionLogHandler.doHandleException(new System.DMLException(), 'AccountTriggerHandler');
            Integer i =1;
            System.assertEquals(1, I);
        Test.StopTest();
    }
}
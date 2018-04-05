/*
    @Author : Amit Singh
    @BuiltDate : 21st March 2018
    @Description : This class will be called from the Trigger and then will redirect to the correct Handler
    @Company : sfdcpanther
*/

public with sharing class TransactionLogHandler{
    
    public static void doHandleException(System.Exception ex, String ProcessName){
        Transaction_Log__c tLog = new Transaction_Log__c();
        tLog.Exception_Time__c = System.now();
        tLog.Process_Name__c = ProcessName;
        tLog.Class_Name__c = ProcessName;
        tLog.Error_Log__c = ex.getStackTraceString() +'<br/>'+ ex.getLineNumber();
        
        insert tLog;
    }
}
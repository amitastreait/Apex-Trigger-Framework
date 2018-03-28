/*
    @Author : Amit Singh
    @BuiltDate : 20th March 2018
    @Description : 
    @Company : sfdcpanther
*/
public interface TriggerInterface{
    
    /*
        @Author : Amit Singh
        @BuiltDate : 20th March 2018
        @Description : Called by the trigger framework before insert of the records
        @params : List<sObject> newRecordsList 
    */
    void beforeInsert(List<sObject> newRecordsList);
    
    /*
        @Author : Amit Singh
        @BuiltDate : 20th March 2018
        @Description : Called by the trigger framework after insert of the records
        @params : List<sObject> newRecordsList , Map<Id, sObject> newRecordsMap
    */
    void afterInsert(List<sObject> newRecordsList , Map<Id, sObject> newRecordsMap);
    
    /*
        @Author : Amit Singh
        @BuiltDate : 20th March 2018
        @Description : Called by the trigger framework before update of the records
        @params : List<sObject> newRecordsList , Map<Id, sObject> newRecordsMap
                  List<sObject> oldRecordsList , Map<Id, sObject> oldRecordsMap
    */
    void beforeUpdate(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap);
    
    /*
        @Author : Amit Singh
        @BuiltDate : 20th March 2018
        @Description : Called by the trigger framework after update of the records
        @params : List<sObject> newRecordsList , Map<Id, sObject> newRecordsMap
                  List<sObject> oldRecordsList , Map<Id, sObject> oldRecordsMap
    */
    void afterUpdate(Map<Id, sObject> newRecordsMap,  Map<Id, sObject> oldRecordsMap);
    
    /*
        @Author : Amit Singh
        @BuiltDate : 20th March 2018
        @Description : Called by the trigger framework before delete of the records
        @params : List<sObject> newRecordsList , Map<Id, sObject> newRecordsMap
    */            
    void beforeDelete(List<sObject> oldRecordsList , Map<Id, sObject> oldRecordsMap);
    
    /*
        @Author : Amit Singh
        @BuiltDate : 20th March 2018
        @Description : Called by the trigger framework after delete of the records
        @params : List<sObject> newRecordsList , Map<Id, sObject> newRecordsMap
    */
    void afterDelete(Map<Id, sObject> oldRecordsMap);
    
    /*
        @Author : Amit Singh
        @BuiltDate : 20th March 2018
        @Description : Called by the trigger framework after undelete of the records
        @params : List<sObject> newRecordsList , Map<Id, sObject> newRecordsMap
    */
    void afterUnDelete(List<sObject> newRecordsList , Map<Id, sObject> newRecordsMap);
}
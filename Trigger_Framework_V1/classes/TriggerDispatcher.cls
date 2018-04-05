/*
    @Author : Amit Singh
    @BuiltDate : 21st March 2018
    @Description : This class will be called from the Trigger and then will redirect to the correct Handler
    @Company : sfdcpanther
*/
public with sharing class TriggerDispatcher{

    public static void run(TriggerInterface handler, String ObjectName){
    
       /*
        * Fetch the Trigger Settings Records and check in which context Trigger can be executed.
        */ 
        List<Trigger_Setting__c> triggerSettingList = new List<Trigger_Setting__c>();
        triggerSettingList = [Select Id, Name, Disabled__c, Object_Name__c, Before_Update__c, Before_Insert__c, Before_Delete__c,
                                After_Update__c, After_Undelete__c, After_Insert__c, After_Delete__c, Prevent_Recursion__c
                                From Trigger_Setting__c  Where Object_Name__c =: objectName];
        
        execute(handler, triggerSettingList);
    }

    private static void execute(TriggerInterface handler, List<Trigger_Setting__c> triggerSetting){

        if(triggerSetting !=null && triggerSetting.size() > 0){
            if(triggerSetting[0].Disabled__c  ) return ; 
        }else{
            throw new TriggerException('No Trigger Setting found! Please create an entry for '+
                ' Trigger Settings Object. Contact your administrator');
        }
        
        /*
        * If trigger is executing in before context then route to the befor context methods
       */
        if(Trigger.isBefore){
            if(Trigger.isInsert && triggerSetting[0].Before_Insert__c){
                handler.BeforeInsert(Trigger.New);
            }
            if(Trigger.isUpdate && triggerSetting[0].Before_Update__c){
                handler.BeforeUpdate(Trigger.NewMap, Trigger.oldMap);
            }
            if(Trigger.isDelete && triggerSetting[0].Before_Delete__c){
                handler.BeforeDelete(Trigger.old, Trigger.oldMap);
            }
        }
        
       /*
        * If trigger is executing in after context then route to the after context methods
        */
        If(Trigger.isAfter){
            if(Trigger.isInsert && triggerSetting[0].After_Insert__c){
                handler.AfterInsert(Trigger.new, Trigger.newMap);
            }
            
            /* If trigger is executing in After Update Context then Check 
               if the field have been changed or not if not do not call the hanlder
               in order to prevent the recursion
           */
           
            If(Trigger.isUpdate && triggerSetting[0].After_Update__c){
                Map<Id, sObject> newItemsMap = new map<Id, sObject>();
                Map<Id, sObject> oldItemsMap = new map<Id, sObject>();
                List<String> fieldAPINameList = new List<String>();
                if(triggerSetting[0].Prevent_Recursion__c !=null)
                    fieldAPINameList = triggerSetting[0].Prevent_Recursion__c.split(',');
                
                for(sObject obj : Trigger.NewMap.Values()){
                    for(String field : fieldAPINameList){
                        if(obj.get(field.trim()) != Trigger.oldMap.get(obj.Id).get(field.trim())){
                            
                            if(!newItemsMap.containsKey(obj.Id))
                                newItemsMap.put(obj.Id, obj);
                            if(!oldItemsMap.containsKey(obj.Id))
                                oldItemsMap.put(obj.id, Trigger.oldMap.get(obj.Id));
                        }
                    }
                }
                handler.AfterUpdate(newItemsMap, oldItemsMap);
            }
            If(Trigger.isDelete && triggerSetting[0].After_Delete__c){
                handler.AfterDelete(Trigger.oldMap);
            }
            If(Trigger.isUndelete && triggerSetting[0].After_Undelete__c){
                handler.AfterUndelete(Trigger.new, Trigger.newMap);
            }
        }
    }
    
}
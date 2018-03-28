# Apex-Trigger-Framework
Apex can be invoked by using triggers. Apex triggers enable you to perform custom actions before or after changes to Salesforce records, such as insertions, updates, or deletions.
A trigger is Apex code that executes before or after the following types of operations:

insert
update
delete
merge
upsert
undelete


I have seen the code of many triggers in my career. Some were good, bad and ugly whenever it comes to trigger implementation.

Trigger Best Practices
One Trigger per Object
Logic-less trigger
Context-specific handler methods


I started reading and following the trigger best practices and while reading and implementing the trigger I heard about the trigger framework. In my recent project requirement was to develop the trigger with the framework so being as a lead developer I did took the responsibility to build the lightweight trigger framework.

You can deploye the code directoly into you salesforce Production/Sandbox or Developer Org.
<a href="https://githubsfdeploy.herokuapp.com/?owner=amitastreait&repo=Apex-Trigger-Framework">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

# Why Use a Framework?
Now, we have some best practices you must be thinking that what if I am following all the best practices do I need to use the trigger framework. The simple answer is No.

A framework may, however, greatly simplify your development efforts when your code base gets large. In a nutshell, your framework should have the following goals:

### Help you to conform to best practices
### Make implementing new logic and new context handlers very easy
### Simplify testing and maintenance of your application logic
### Enforces consistent implementation of Trigger logic
### Implement tools, utilities, and abstractions to make your handler logic as lightweight as possible
### Assure the Order of execution of the code
### Prevent the recursion.
### Ensure that trigger will do not create any issue while working with large datasets.


I did google, and found many trigger framework, took some ideas and then decided not to use the existing framework and developed my own. I have bellow observation on the existing framework.

1 - Having BeforeInsert(SObject) type method for each event as we all knew that trigger must be bulkified.
2 - Complex TriggerFactory class logic and most of the time process is being executed at runtime which may lead to timeout error.
Complicated design.


## Also, time is another barrier that every developer face while implementing the framework.

The framework I developed includes all the best practices with some additional features that are given below :

### Ability to control the trigger and its triggering event from the UI.
### Prevent recursion based on the field values provided into the Trigger Setting record.
### Ability to see which Object trigger is active and in which event trigger will execute using the report.
### A custom object that catches the exception and stores the information in details for future reference


# The requirement of Trigger Framework
#### Create Record of Trigger Setting Object for those object you want to build the trigger and this record will be used to control the trigger from the UI.
#### While developing the handler class developer must implement TriggerInterface and it's all methods
#### From the trigger use only line code and pass the handler class instance and the Objectname that you did use while creating the Trigger Setting record.


# The Interface - TriggerInterface
The apex interface which contains the methods that needs to be implemented while developing the handler class even if there is no logic for those methods. Using the interface we are assuring that developer will follow all the best practice.

````

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
````



# The Dispatcher Class - TriggerDispatcher
This class is the heart of the framework which contains `2 methods a) run and b) execute.` The developer needs to call the run method from the trigger and pass the parameters then the call will do the trick and will redirect to the correct method of the handler class.

````
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
````

In the above class, we are making a SOQL on Trigger Setting by which we will control the trigger events and also trigger is disabled or Not.  `if(triggerSetting[0].Disabled__c ) return;` checks if the trigger is disabled from the UI if yes then return the trigger and do not execute.



# Develop the handler class - Example (AccountTriggerHandler)
The developer needs to develop the handler class and must implement the TriggerInterface with it's all methods. Here is the sample handler class. Implementation of the TriggerInterface interface is must.

In the handler class method use try and catch where required and in catch method `call doHandleException method of TransactionLogHandler class to catch the exception`.

````

/*
    @Author : Amit Singh
    @BuiltDate : 21st March 2018
    @Description : Handler class that will be created by developer and allowed only one for every object
    @Company : sfdcpanther
*/
public class AccountTriggerHandler implements TriggerInterface{
 
    public void BeforeInsert(List<SObject> newItems) {
        /* Update the Account name before account inserted into Salesorce */
        for(Account acc : (List<Account>)newItems){
            acc.Name = 'Trigger FrameWork ' +acc.Name;
        }
    }
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void BeforeDelete(List<sObject> oldRecordsList , Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(List<sObject> newRecordsList , Map<Id, SObject> newItems) {
        Try{
        }Catch(System.Exception ex){
            /* Call the TransactionLogHandler class method to create a log 
               parameters need to pass in the method are System.Exception and the Handler ClassName
            */
            TransactionLogHandler.doHandleException(ex , 'AccountTriggerHandler');
        }
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        /* Update the AccountNumber */
        List<Account> accountToUpdateList = new List<Account>();
        Try{
           for(Account acc : [Select Id, Name, AccountNumber From Account Where Id =: newItems.keySet()]){
               acc.AccountNumber = '123345543625';
               accountToUpdateList.add(acc);
           }
           /* Update Account and Test if the Recursion is Being prevented */
           update accountToUpdateList;
           
        }Catch(System.Exception ex){
            /* Call the TransactionLogHandler class method to create a log 
               parameters need to pass in the method are System.Exception and the Handler ClassName
            */
            
            TransactionLogHandler.doHandleException(ex , 'AccountTriggerHandler');
        }
    }
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(List<sObject> newRecordsList , Map<Id, sObject> newItems) {}
    
}
````



# Built the trigger and call the dispatcher class -
In the final steps, create the trigger and put a single line of code and rest is magic. See example trigger on account object.

````

/*
    @Author : Amit Singh
    @BuiltDate : 21st March 2018
    @Description : Account Trigger that will call the RUN mthos of TriggerDispatcher class
    @Company : sfdcpanther
*/

trigger AccountTrigger on Account (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    TriggerDispatcher.run(new AccountTriggerHandler() , 'Account');
}
````

In the trigger code, the developer needs to call run method of TriggerDispatcher with 2 parameters

     1 - The instance of the Handler class
     2 - The name of the object of the Trigger Setting for the same Object. For example, we are building the trigger on account object    then ObjectName in Trigger Setting object will be account and then we need to pass Account as the second parameter while calling the method.


# The Log handler class - TransactionLogHandler
The class which is responsible for catching the exception and then inserting into the Transaction Log Object.

Here is the code

````

/*
    @Author : Amit Singh
    @BuiltDate : 20th March 2018
    @Description : to create the Transaction Log record if there is any Error while processing !!
    @Company : sfdcpanther
*/

public with sharing class TransactionLogHandler{

    public static void doHandleException(System.Exception ex , String processName){
        Transaction_Log__c transactionLog = new Transaction_Log__c(
            Error_Log__c = ex.getStackTraceString() +'<br/>' + ex.getMessage() + '<br/>' + ex.getCause() +' <br/>'+ ex.getTypeName(),
            Exception_Time__c = System.Now(),
            Process_Name__c = processName,
            Class_Name__c = processName
        );
        if(Schema.sObjectType.Transaction_Log__c.isCreateable()){
            insert transactionLog;
        }
        
    }

}
````

# Control the Trigger From UI -
The best part of the Framework is you can control the trigger from the UI. Open the Trigger Setting for the Object and you can select whether the trigger is disabled and on which events trigger will execute
![](http://www.sfdcpanther.com/wp-content/uploads/2018/03/TriggerSettingsStep3-1024x487.png)

# See the report -
Open `"Object Trigger Settings"` where you can see the report of the trigger in single place and many important information like the trigger is active?. Events in which trigger will execute.
![](http://www.sfdcpanther.com/wp-content/uploads/2018/03/TriggerReport-1024x456.png)

We simply call the static method on the TriggerDispatcher and pass it a new instance of our AccountTriggerHandler. The framework takes care of the rest.

# Entity Relationship Diagram (ERD)

![](http://www.sfdcpanther.com/wp-content/uploads/2018/03/ERD_Trigger_Framework-1024x506.png)


#### If you’re planning to implement a trigger framework but don’t have the time to implement a more complex solution, then you should probably start with a framework like this and build on it yourself. You can always add new functionality as and when it is required.

### On the other hand, you are NOT considering a trigger handler framework, you should reconsider!

If you have any comments then please feel free to post them here or reach me on [Twitter](https://twitter.com/cloudyamit).

Share with your friends and colleagues because sharing is caring:). Also, like the facebook page to get the latest updates.

Please feel free to give any suggestion!.

<a href="https://githubsfdeploy.herokuapp.com/?owner=amitastreait&repo=Apex-Trigger-Framework">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>



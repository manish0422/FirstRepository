global class BatchClassForCase implements Database.Batchable<sObject>, Database.Stateful{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT CreatedDate, Status, ContactId, ContactReason__c FROM Case';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Case> scope){
        List<Contact> conList = [SELECT Id, Email FROM Contact];
        map<Id,String> getEmail = new map<Id,String>();
        for(Contact c : conList){
            getEmail.put(c.Id, c.Email);
        }
        System.debug(getEmail);
        System.debug('DEBUG LEVEL : '+scope);
        List<case> objCaseLst = new List<case>();
        for(Case c : scope){
            Integer noOfDays = (Date.valueOf(c.CreatedDate).daysBetween(system.today()));
            System.debug(noOfDays);
            System.debug(' firts 1 '+c.ContactReason__c +  ' ' + 'noOfDays '+noOfDays);
            if(c.ContactId != null){
                if(noOfDays >= 60 && (c.ContactReason__c == 'Life Support Management' || c.ContactReason__c == 'Electricity and Gas') ){
                    c.Status = 'Closed';                  
                    EmailManager.sendMail(getEmail.get(c.ContactId), 'about your case' , 'Your Case is Closed');
                }else if(noOfDays >= 30 && noOfDays < 60 && (c.ContactReason__c == 'Life Support Management' || c.ContactReason__c == 'Electricity and Gas')){
                    c.Status = 'Working';
                    EmailManager.sendMail(getEmail.get(c.ContactId), 'about your case' , 'Your Case is near to closed');
                } 
                objCaseLst.add(c);
            }
            update objCaseLst;
            System.debug('=====> '+scope);
        }    
    }
    global void finish(Database.BatchableContext bc){
    }    
}
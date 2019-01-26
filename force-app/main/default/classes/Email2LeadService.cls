/**
* 
* Apex Class Name: Email2LeadService

* Description: This Apex class handles the inbound email messages,
* the apex email service domain receives and retrieves
* the contents of inbound email messages and stores them in the
* QuickQuote custom object except the attachments.
* If any attachment of type PDF is attached with the inbound email,
* this will be indicated via a checkbox in the object.
* 
* Modification Log:
* ------------------------------------------------------
* 
* Date             Developer                Description
* -------------    -------------            ---------------
* 26-Jan-2019      Bobby White              Original Class
**/

global with sharing class Email2LeadService implements Messaging.InboundEmailHandler {
    
    /**
    * Method Name: handleInboundEmail
    * Description: Handler Interface defines this method to process the inbound email message
    * Parameter:
    * @param email - the email body including attachments if any
    * @param envelope - the envelope which includes the addresses
    * Return Type:
    * @return true if successful, false if unsuccessful
    **/ 
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        result.success = createLeadFromEmail(email,envelope);
        return result;
    }
    
    /**
    * Method Name: createLeadFromEmail
    * Description: Inspect the Email and its Envelope and create a new Lead from it
    * For this POC, Subject, Body, Sender, and original Mailbox have been taken into consideration
    * Parameter:
    * @param email - the email body including attachments if any
    * @param envelope - the envelope which includes the addresses
    * Return Type:
    * @return true if successful, false if unsuccessful
    **/ 
    private boolean createLeadFromEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        try {
            Lead theLead = new Lead();
            theLead.LeadSource = 'Web';
            //theLead. = email.subject;
            theLead.description = email.htmlBody == null ? email.plainTextBody : email.htmlBody ;
            theLead.email = envelope.fromAddress;
            setLeadNameFromEmailAddress(theLead,envelope.fromAddress);
            //theLead.???? = envelope.toAddress;
            
            if (theLead.description == null) {
                throw new ServiceException('Empty email body');                
            }
            
            insert theLead;
            return true;
        } catch(Exception e) {
            System.Debug('Create lead failed: ' + e.getMessage());
            return false;
        }  
    }
    
    /**
     * Attempt to Split the Email Address up into a meaningful name
     **/
    @TestVisible
    private void setLeadNameFromEmailAddress(Lead myLead, String emailAddress) {
    
        List<String> nameParts = emailAddress.split('@');
        List<String> subParts = nameParts[0].split('\\.');   // if we get a dot to separate name parts
        
        myLead.firstname = subParts[0];
        myLead.lastname = subParts[subParts.size() > 1 ? 1 : 0];
        myLead.company = nameParts.size() > 1 ? nameParts[1] : 'Unknown';
    }
    
    public class ServiceException extends Exception {
    }
    
 
}
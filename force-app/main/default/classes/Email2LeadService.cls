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
    public static final String EMPTY_BODY=' ';
    public static final String DUPLICATE_FOUND='DUPLICATES_DETECTED';
    
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
        
        Lead theLead = new Lead();

        theLead.LeadSource = 'Web';

        // Plain Text version by default, HTML if plain is missing
        if (email.plainTextBody != null) {
            theLead.description = email.plainTextBody; 
        } else  {
        	// Special handling if no Plaintext body is present
            theLead.description = email.htmlBody == null ? EMPTY_BODY : convertHTMLToPlainText(email.htmlBody);
        }

        theLead.email = envelope.fromAddress;
        setLeadNameFromEmailAddress(theLead,envelope.fromAddress);

        try {     
            insert theLead;
        } catch(DMLException dme) {
        	if (dme.getMessage().contains(DUPLICATE_FOUND)) {
                Lead theOriginalLead=null;

        		// ASSUMES that the Duplicate Rule is based on in part on Email address
        		// Find the existing lead by Email Address and use it instead
        		List<Lead> matches = [SELECT id, email, firstName, lastName 
        				     From Lead
        				    Where email = :envelope.fromAddress
        				    LIMIT 1];
        	    if (matches.isEmpty()) {
        	    	return false;
        	    } else {
        	    	theOriginalLead = matches[0]; // use the first match
                    createTask(theOriginalLead,email,envelope);
                    return true;
        	    }

        	} else {
        		return false;
        	}
        } catch(Exception e) {
            System.Debug('Create lead failed: ' + e.getMessage());
            return false;
        } 

        // Create a Task and Email attached to the lead
        createTask(theLead,email,envelope);
        return true;

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

    @TestVisible
    private void createTask(Lead theLead, Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {


    	try {
	    	EmailMessage msg = new EmailMessage();
			msg.subject = email.subject;
			msg.fromAddress = envelope.fromAddress;
			msg.fromName= theLead.firstName + ' ' + theLead.LastName;
			msg.htmlBody= email.htmlBody;
			msg.TextBody = email.plainTextBody;
			msg.incoming=true;
			msg.ToAddress=envelope.toAddress;
			msg.Status = '0';
			insert msg;

			Task t1 = new Task();
			t1.description='Inbound Email';
			t1.subject= email.subject;
			t1.taskSubtype='Email';
			t1.whoId=theLead.id;
			t1.status='Completed';
			insert t1;

    	} catch (Exception e) {
    		// Eat the exception
    		System.debug(e.getMessage());
    	}


    }
    @TestVisible
    private String convertHTMLToPlainText(String htmlText) {
        String strippedText = (htmlText == null) ? null : htmlText.replaceAll('(?s)<[^>]*>(\\s*<[^>]*>)*', '');
        return strippedText;
    }
    
    public class ServiceException extends Exception {
    }
    
 
}
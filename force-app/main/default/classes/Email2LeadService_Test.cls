@isTest
public class Email2LeadService_Test {
    public static final String MSG_EXPECTED_SUCCESS = 'Expected Success = true as result of handler';
    public static final String DEFAULT_SUBJECT = 'Email Quote Request';
    public static final String DEFAULT_SENDER = 'broker@agency1.com';
    public static final String DEFAULT_MAILBOX = 'email2lead@example.com';
    public static final String HTML_BODY = '<em>Please</em> quote me 50 year old male, diabetes, 500k coverage';
    public static final String TEXT_BODY = 'Text-Please quote me 50 year old male, diabeters, 500k coverage-Text';
    public static final String ERROR_SENDER = 'brokeragency1';

    /**
     * Test the main service interface with an HTML body only
     * Sender, Subject, and other expected fields are supplied
     * along with attachment.
     * 
     **/ 
   static testMethod void testHandleBasicE2EWithHtmlBody() {

      // Create a new email, envelope object and Attachment
       Messaging.InboundEmail email = createEmail(DEFAULT_SUBJECT,HTML_BODY,null);
      Messaging.InboundEnvelope env = createEnvelope(DEFAULT_SENDER,DEFAULT_MAILBOX);


      // call the class and test it with the data in the testMethod
      Email2LeadService emailServiceObj = new Email2LeadService();
      Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env );
       
      System.Assert(result.success,MSG_EXPECTED_SUCCESS);
       
      validateLead(DEFAULT_SUBJECT,HTML_BODY);  

   }
    
    /**
     * Test the main service interface with an TEXT body only
     * Sender, Subject, and other expected fields are supplied.
     * 
     **/ 
   static testMethod void testHandleBasicE2EWithTextBody() {

      // Create a new email, envelope object and Attachment
      Messaging.InboundEmail email = createEmail(DEFAULT_SUBJECT,null,TEXT_BODY);
      Messaging.InboundEnvelope env = createEnvelope(DEFAULT_SENDER,DEFAULT_MAILBOX);


      // call the class and test it with the data in the testMethod
      Email2LeadService emailServiceObj = new Email2LeadService();
      Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env );
       
      System.Assert(result.success,MSG_EXPECTED_SUCCESS);
       
      validateLead(DEFAULT_SUBJECT,TEXT_BODY);  

   }
    
     /**
     * Test the main service interface with both HTMN and TEXT body 
     * Sender, Subject, and other expected fields are supplied.
     * 
     **/ 
   static testMethod void testHandleBasicE2EWith2Body() {

      // Create a new email, envelope object and Attachment
      Messaging.InboundEmail email = createEmail(DEFAULT_SUBJECT,HTML_BODY,TEXT_BODY);
      Messaging.InboundEnvelope env = createEnvelope(DEFAULT_SENDER,DEFAULT_MAILBOX);



      // call the class and test it with the data in the testMethod
      Email2LeadService emailServiceObj = new Email2LeadService();
      Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env );
       
      System.Assert(result.success,MSG_EXPECTED_SUCCESS);
       
      validateLead(DEFAULT_SUBJECT,HTML_BODY);

   }
    
        /**
     * Test the main service interface with both HTMN and TEXT body 
     * Sender, Subject, and other expected fields are supplied.
     * 
     **/ 
   static testMethod void testHandleNoSubject() {

      // Create a new email, envelope object and Attachment
      Messaging.InboundEmail email = createEmail(null,HTML_BODY,TEXT_BODY);
      Messaging.InboundEnvelope env = createEnvelope(DEFAULT_SENDER,DEFAULT_MAILBOX);



      // call the class and test it with the data in the testMethod
      Email2LeadService emailServiceObj = new Email2LeadService();
      Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env );
       
      System.Assert(result.success,MSG_EXPECTED_SUCCESS);
       
      validateLead(null,HTML_BODY);

   }
   
    /**
     * @Start 27-Dec-2016 Technical Review Team
     * Negative Testing for the main service interface with an HTML body only
     * Sender, Subject, and other expected fields are supplied along with attachment.
     * 
     **/ 
   static testMethod void testHandleBasicE2EWithHtmlBodyNegativeTesting() {

      // Create a new email, envelope object and Attachment
      Messaging.InboundEmail email = createEmail(DEFAULT_SUBJECT,HTML_BODY,null);
      Messaging.InboundEnvelope env = createEnvelope(DEFAULT_SENDER,DEFAULT_MAILBOX);


      // call the class and test it with the data in the testMethod
      Email2LeadService emailServiceObj = new Email2LeadService();
      Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env);
      
      //Assertion for the negative testing
      System.assertEquals(result.success, false);
       
   }
    
    /**
     * Helper method to initialize the Email proper with Attachment
     **/ 
    private static Messaging.InboundEmail createEmail(String subject, String htmlBody, String textBody) {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = subject;
        email.htmlbody = htmlBody;
        email.plainTextBody = textBody;
        
        return email;
    }

    /**
     * Helper method to initialize the Envelope
     **/ 
    private static Messaging.InboundEnvelope createEnvelope(String sender, String toMailbox) {
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       env.fromAddress = sender;
       env.toAddress = toMailbox;
       return env;
    }

    /**
     * Helper to validate key info in a reusable fashion
     **/ 
    private static void validateLead(String expectedName, String expectedBody) {
        try {
	       List<Lead> testLeads = [SELECT Id
	                                    , Name
	                                    , LeadSource
	                                    , Description
	                                    , Status
	                               FROM Lead limit 10];
	       
	       System.Assert(testLeads.size() == 1, 'Expected exactly 1 Lead, got:' + testLeads.size());
	       
	       Lead theLead = testLeads[0];
	       System.AssertEquals(theLead.Status,'New','Expected status of NEW');
	       System.AssertEquals(theLead.LeadSource,'Web','Source must be set');
	       System.AssertEquals(theLead.name,'Name must be set');
	       System.AssertEquals(theLead.description,expectedBody,'Description should match body');
	       
	   } catch (System.DMLException dme)  {
	       System.Assert(false,'Exception caught while validating Leads'+dme.getMessage());
	   } 
   }
}
@isTest
public class Email2LeadService_Test {
    public static final String MSG_EXPECTED_SUCCESS = 'Expected Success = true as result of handler';
    public static final String DEFAULT_SUBJECT = 'Email Quote Request';
    public static final String DEFAULT_SENDER = 'broker@agency1.com';
    public static final String DEFAULT_MAILBOX = 'email2lead@example.com';
    public static final String HTML_BODY = '<em>Please</em> quote me <p>50 year old male, diabetes, 500k coverage';
    public static final String TEXT_BODY = 'Please quote me 50 year old male, diabetes, 500k coverage';
    public static final String ERROR_SENDER = 'brokeragency1';

    static testMethod void testConvertHTML() {
        Email2LeadService service = new Email2LeadService();
        String converted = service.convertHTMLToPlainText('<p>This is <em>html</em>');
        System.AssertEquals(converted,'This is html');
    }
    static testMethod void testSimpleName() {
        Lead myLead = new Lead();
        Email2LeadService service = new Email2LeadService();
        service.setLeadNameFromEmailAddress(myLead, 'firstpart@example.com');
        System.AssertEquals(myLead.FirstName,'firstpart');
        System.AssertEquals(myLead.LastName,'firstpart');
        System.AssertEquals(myLead.company,'example.com');
    }
    static testMethod void testGoodDotName() {
        Lead myLead = new Lead();
        Email2LeadService service = new Email2LeadService();
        service.setLeadNameFromEmailAddress(myLead, 'first.last@example.com');
        System.AssertEquals(myLead.FirstName,'first');
        System.AssertEquals(myLead.LastName,'last');
        System.AssertEquals(myLead.company,'example.com');
    }
    static testMethod void testComplexDotName() {
        Lead myLead = new Lead();
        Email2LeadService service = new Email2LeadService();
        service.setLeadNameFromEmailAddress(myLead, 'first.last.other@example.com');
        System.AssertEquals(myLead.FirstName,'first');
        System.AssertEquals(myLead.LastName,'last');
        System.AssertEquals(myLead.company,'example.com');
    }
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
       
      validateLead(DEFAULT_SUBJECT,TEXT_BODY);  

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
       
      validateLead(DEFAULT_SUBJECT,TEXT_BODY);

   }
    
        /**
     * Test the main service interface with both HTMN and TEXT body 
     * Sender, Subject, and other expected fields are supplied.
     * 
     **/ 
   static testMethod void testHandleNoSubject() {

      // Create a new email, envelope object and Attachment
      Messaging.InboundEmail email = createEmail('',HTML_BODY,TEXT_BODY);
      Messaging.InboundEnvelope env = createEnvelope(DEFAULT_SENDER,DEFAULT_MAILBOX);



      // call the class and test it with the data in the testMethod
      Email2LeadService emailServiceObj = new Email2LeadService();
      Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env );
       
      System.Assert(result.success,MSG_EXPECTED_SUCCESS);
       
      validateLead('',TEXT_BODY);

   }
   
    /**
     *  Test for duplicate lead insertion
     **/ 
   static testMethod void testBodyNegativeTesting() {

      // Create a new email, envelope object and Attachment
      Messaging.InboundEmail email = createEmail(DEFAULT_SUBJECT,HTML_BODY,TEXT_BODY);
      Messaging.InboundEnvelope env = createEnvelope(DEFAULT_SENDER,DEFAULT_MAILBOX);


      // call the class and test it with the data in the testMethod
      Email2LeadService emailServiceObj = new Email2LeadService();
      emailServiceObj.handleInboundEmail(email, env);
      

      // Attempt to create the duplicate lead -- Ensure this would work from a clean state
      Email2LeadService emailService2 = new Email2LeadService();
      Messaging.InboundEmailResult result = emailService2.handleInboundEmail(email, env);

      validateLead(DEFAULT_SUBJECT,TEXT_BODY);

      // Extra check to see that at least two Tasks are found for this Lead
      List<Lead> testLeads = [SELECT id, email From Lead Limit 1];
      List<Task> testTasks = [SELECT id from Task Where WhoId=:testLeads[0].id];
      System.Assert(testTasks.size()==2,'Expected to find 2 Tasks for the duplicate lead');

       
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
	                               FROM Lead limit 2];
	       
	       System.Assert(testLeads.size() == 1, 'Expected exactly 1 Lead, got:' + testLeads.size());
	       
	       Lead theLead = testLeads[0];
	       System.AssertEquals('Web',theLead.LeadSource,'Source must be set');
	       System.Assert(theLead.name != null,'Name must be set');
	       System.AssertEquals(expectedBody,theLead.description,'Description should match body');
	       
	   } catch (System.DMLException dme)  {
	       System.Assert(false,'Exception caught while validating Leads'+dme.getMessage());
	   } 
   }
}
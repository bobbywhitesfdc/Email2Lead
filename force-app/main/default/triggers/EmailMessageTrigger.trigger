trigger EmailMessageTrigger on EmailMessage (before insert) {
	if (Trigger.isBefore && Trigger.isInsert) {
		for (EmailMessage current : Trigger.new) {
			// Not bulkified in this prototype
			Case case1 = new Case();
			case1.subject=current.subject;
			case1.status='New';
			case1.description=current.TextBody;
			insert case1;

			Task t1 = new Task();
			t1.description=current.TextBody;
			t1.subject= current.subject;
			t1.taskSubtype='Email';
			//t1.whoId= [SELECT Id from Lead Where email = :current.fromAddress][0].id;
			t1.whatId=case1.id;
			t1.status='Completed';
			insert t1;
			// Attach this to the case
			current.ParentId=case1.id;
			current.ActivityId = t1.id;
		}
	}

}
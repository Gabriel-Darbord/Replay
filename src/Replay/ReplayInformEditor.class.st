"
I edit a ReplayInform: the rich text of its notification, registered as 'Action text', with a button that previews the notification.
"
Class {
	#name : 'ReplayInformEditor',
	#superclass : 'ReplayActionEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplayInformEditor >> addFieldsTo: aLayout [

	aLayout
		add: (self
				 textField: 'text'
				 label: 'Write the rich text to display with an information event:'
				 get: [ action text ]
				 set: [ :aString | action text: aString ]);
		add: (self newButton
				 icon: (self iconNamed: #smallDoIt);
				 label: 'Preview';
				 action: [ self inform: action text ];
				 yourself)
		expand: false
]

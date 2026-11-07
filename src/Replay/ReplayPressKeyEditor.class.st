"
I edit a ReplayPressKey: after its target, its key, its modifiers and its repeat count, registered as 'Action key', 'Action shift', 'Action control', 'Action alt option', 'Action command' and 'Action count'.
"
Class {
	#name : 'ReplayPressKeyEditor',
	#superclass : 'ReplayUIHandlerEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplayPressKeyEditor >> addFieldsTo: aLayout [

	aLayout
		add: (self
				 choiceField: 'key'
				 label: 'Key:'
				 choices: action class keyChoices
				 get: [ action keySelector ]
				 set: [ :aSymbol | action keySelector: aSymbol ])
		expand: false;
		add: (self
				 modifiersField: 'Modifiers:'
				 get: [ action modifiers ]
				 set: [ :anInteger | action modifiers: anInteger ])
		expand: false;
		add: (self
				 positiveIntegerField: 'count'
				 label: 'Repeat count:'
				 get: [ action repeatCount ]
				 set: [ :anInteger | action repeatCount: anInteger ])
		expand: false
]

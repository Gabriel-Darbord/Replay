"
I edit a ReplayAnnotate: after its target, the placement of its label and its text, registered as 'Action placement' and 'Action text'.
"
Class {
	#name : 'ReplayAnnotateEditor',
	#superclass : 'ReplayUIHandlerEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplayAnnotateEditor >> addFieldsTo: aLayout [

	aLayout
		add: (self
				 choiceField: 'placement'
				 label: 'Label placement:'
				 choices: action class placementChoices
				 get: [ action placement ]
				 set: [ :aSymbol | action placement: aSymbol ])
		expand: false;
		add: (self
				 textField: 'text'
				 label: 'Write rich text display next annotated UI element:'
				 get: [ action text ]
				 set: [ :aString | action text: aString ])
]

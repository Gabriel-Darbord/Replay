"
I edit a ReplayNavigate, the navigation at the end of a step: whether it is skipped ('Action skip'), the labels of its buttons ('Action accept label', 'Action cancel label'), its rich text ('Action text') and the placement of its dialog.
"
Class {
	#name : 'ReplayNavigateEditor',
	#superclass : 'ReplayActionEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplayNavigateEditor >> addFieldsTo: aLayout [

	aLayout
		add: (self
				 checkBoxField: 'skip'
				 label: 'Skip user navigation'
				 get: [ action skip ]
				 set: [ :aBoolean | action skip: aBoolean ])
		expand: false;
		add: (self
				 lineField: 'accept label'
				 label: 'Continue label:'
				 get: [ action acceptLabel ]
				 set: [ :aString | action acceptLabel: aString ])
		expand: false;
		add: (self
				 lineField: 'cancel label'
				 label: 'Cancel label:'
				 get: [ action cancelLabel ]
				 set: [ :aString | action cancelLabel: aString ])
		expand: false;
		add: (self
				 textField: 'text'
				 label: 'Write rich text display on navigation window:'
				 get: [ action text ]
				 set: [ :aString | action text: aString ]);
		add: (self placementField: [ action placement ] set: [ :placement | action placement: placement ]) expand: false
]

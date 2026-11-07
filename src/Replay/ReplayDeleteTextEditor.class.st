"
I edit a ReplayDeleteText: after its target, its direction and its count, registered as 'Action direction' and 'Action count'.
"
Class {
	#name : 'ReplayDeleteTextEditor',
	#superclass : 'ReplayUIHandlerEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplayDeleteTextEditor >> addFieldsTo: aLayout [

	aLayout
		add: (self
				 choiceField: 'direction'
				 label: 'Delete direction:'
				 choices: action class directionChoices
				 get: [ action direction ]
				 set: [ :aSymbol | action direction: aSymbol ])
		expand: false;
		add: (self
				 positiveIntegerField: 'count'
				 label: 'Delete count:'
				 get: [ action count ]
				 set: [ :anInteger | action count: anInteger ])
		expand: false
]

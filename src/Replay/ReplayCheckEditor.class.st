"
I edit a ReplayCheck: after its target, its condition ('Action script') and how many seconds to wait for it ('Action timeout').
"
Class {
	#name : 'ReplayCheckEditor',
	#superclass : 'ReplayUIHandlerEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplayCheckEditor >> addFieldsTo: aLayout [

	aLayout
		add: (self
				 positiveIntegerField: 'timeout'
				 label: 'Wait up to (seconds):'
				 get: [ action timeout ]
				 set: [ :anInteger | action timeout: anInteger ])
		expand: false;
		add: (self
				 codeField: 'script'
				 label: 'Condition (self is the target, or the World):'
				 get: [ action script ]
				 set: [ :aString | action script: aString ])
]

"
I edit a ReplayType: after its target, the text it types, registered as 'Action text'.
"
Class {
	#name : 'ReplayTypeEditor',
	#superclass : 'ReplayUIHandlerEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplayTypeEditor >> addFieldsTo: aLayout [

	aLayout add: (self
			 textField: 'text'
			 label: 'Write text to type:'
			 get: [ action text ]
			 set: [ :aString | action text: aString ])
]

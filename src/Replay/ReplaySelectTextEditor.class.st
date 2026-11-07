"
I edit a ReplaySelectText: after its target, the start and stop indexes of the selection, registered as 'Action start index' and 'Action stop index'.
"
Class {
	#name : 'ReplaySelectTextEditor',
	#superclass : 'ReplayUIHandlerEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplaySelectTextEditor >> addFieldsTo: aLayout [

	aLayout
		add: (self
				 positiveIntegerField: 'start index'
				 label: 'Selection start:'
				 get: [ action startIndex ]
				 set: [ :anInteger | action startIndex: anInteger ])
		expand: false;
		add: (self
				 positiveIntegerField: 'stop index'
				 label: 'Selection stop:'
				 get: [ action stopIndex ]
				 set: [ :anInteger | action stopIndex: anInteger ])
		expand: false
]

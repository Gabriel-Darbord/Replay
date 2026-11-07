"
I edit a ReplayDelay: its duration in seconds, registered as 'Action seconds'.
"
Class {
	#name : 'ReplayDelayEditor',
	#superclass : 'ReplayActionEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplayDelayEditor >> addFieldsTo: aLayout [

	aLayout
		add: (self
				 labeled: 'Delay in seconds:'
				 field: ((self
						   numberInput: 'seconds'
						   get: [ action seconds ]
						   set: [ :aNumber | action seconds: aNumber ])
						  minimum: 0;
						  yourself))
		expand: false
]

"
Test double for text selection targets.
"
Class {
	#name : 'ReplaySelectableTarget',
	#superclass : 'Object',
	#instVars : [
		'selectionInterval'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'accessing' }
ReplaySelectableTarget >> selectionInterval [

	^ selectionInterval
]

{ #category : 'accessing' }
ReplaySelectableTarget >> selectionInterval: anInterval [

	selectionInterval := anInterval
]

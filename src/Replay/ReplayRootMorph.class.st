"
I am the root morph used to host Replay-managed UI and overlay content.
"
Class {
	#name : 'ReplayRootMorph',
	#superclass : 'Morph',
	#instVars : [
		'manager'
	],
	#category : 'Replay-Morphs',
	#package : 'Replay',
	#tag : 'Morphs'
}

{ #category : 'geometry' }
ReplayRootMorph >> extent: aPoint [

	super extent: aPoint.
	manager ifNotNil: [ manager syncManagedLayout ]
]

{ #category : 'user interface' }
ReplayRootMorph >> initialExtent [

	^ 1100 @ 600
]

{ #category : 'accessing' }
ReplayRootMorph >> manager [

	^ manager
]

{ #category : 'accessing' }
ReplayRootMorph >> manager: aReplayUIManager [

	manager := aReplayUIManager
]

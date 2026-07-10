"
I am the root morph for a Replay-managed UI and notify the manager when my extent changes.
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

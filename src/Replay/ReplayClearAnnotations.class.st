"
I remove every annotation overlay morph from the active managed UI.
"
Class {
	#name : 'ReplayClearAnnotations',
	#superclass : 'ReplayAction',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayClearAnnotations class >> displayName [

	^ 'Clear Annotations'
]

{ #category : 'running' }
ReplayClearAnnotations >> runOn: runner [

	runner manager ifNotNil: [ :manager |
		manager clearOverlay ]
]

"
A scenario action that removes all annotation overlay morphs from the currently managed UI.
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

"
I represent a UI element resolved by a backend-specific Replay resolver.
"
Class {
	#name : 'ReplayResolvedUIElement',
	#superclass : 'Object',
	#instVars : [
		'backend',
		'reference',
		'nativeElement',
		'morph'
	],
	#category : 'Replay-Backends',
	#package : 'Replay',
	#tag : 'Backends'
}

{ #category : 'instance creation' }
ReplayResolvedUIElement class >> backend: aBackend reference: aReference nativeElement: anObject morph: aMorph [

	^ self new
		backend: aBackend;
		reference: aReference;
		nativeElement: anObject;
		morph: aMorph;
		yourself
]

{ #category : 'accessing' }
ReplayResolvedUIElement >> backend [

	^ backend
]

{ #category : 'accessing' }
ReplayResolvedUIElement >> backend: aBackend [

	backend := aBackend
]

{ #category : 'geometry' }
ReplayResolvedUIElement >> boundsInSurface [

	| surface |
	morph ifNil: [ ^ nil ].
	surface := backend surfaceMorph.
	surface ifNil: [ ^ morph bounds ].
	morph == surface ifTrue: [ ^ morph bounds ].
	^ morph boundsIn: surface
]

{ #category : 'running' }
ReplayResolvedUIElement >> clickTarget [

	^ self morphRequiredFor: 'click'
]

{ #category : 'running' }
ReplayResolvedUIElement >> focusTarget [

	^ nativeElement ifNil: [ morph ]
]

{ #category : 'testing' }
ReplayResolvedUIElement >> hasMorph [

	^ morph notNil
]

{ #category : 'running' }
ReplayResolvedUIElement >> keyboardTarget [

	^ self morphRequiredFor: 'keyboard'
]

{ #category : 'accessing' }
ReplayResolvedUIElement >> morph [

	^ morph
]

{ #category : 'accessing' }
ReplayResolvedUIElement >> morph: aMorph [

	morph := aMorph
]

{ #category : 'running' }
ReplayResolvedUIElement >> morphRequiredFor: interactionName [

	morph ifNotNil: [ ^ morph ].
	ReplayMissingUIError new
		messageText: 'Resolved UI element has no Morphic ' , interactionName , ' target.';
		tag: self;
		signal
]

{ #category : 'accessing' }
ReplayResolvedUIElement >> nativeElement [

	^ nativeElement
]

{ #category : 'accessing' }
ReplayResolvedUIElement >> nativeElement: anObject [

	nativeElement := anObject
]

{ #category : 'printing' }
ReplayResolvedUIElement >> printOn: aStream [

	super printOn: aStream.
	aStream nextPutAll: '('.
	reference printOn: aStream.
	aStream nextPutAll: ')'
]

{ #category : 'accessing' }
ReplayResolvedUIElement >> reference [

	^ reference
]

{ #category : 'accessing' }
ReplayResolvedUIElement >> reference: aReference [

	reference := aReference
]

{ #category : 'running' }
ReplayResolvedUIElement >> runClick: aReplayClick [

	^ backend runClick: aReplayClick on: self
]

{ #category : 'running' }
ReplayResolvedUIElement >> runDeleteText: aReplayDeleteText [

	^ backend runDeleteText: aReplayDeleteText on: self
]

{ #category : 'running' }
ReplayResolvedUIElement >> runDrag: aReplayDrag [

	^ backend runDrag: aReplayDrag on: self
]

{ #category : 'running' }
ReplayResolvedUIElement >> runFocus: aReplayFocus [

	^ backend runFocus: aReplayFocus on: self
]

{ #category : 'running' }
ReplayResolvedUIElement >> runPressKey: aReplayPressKey [

	^ backend runPressKey: aReplayPressKey on: self
]

{ #category : 'running' }
ReplayResolvedUIElement >> runScroll: aReplayScroll [

	^ backend runScroll: aReplayScroll on: self
]

{ #category : 'running' }
ReplayResolvedUIElement >> runSelectText: aReplaySelectText [

	^ backend runSelectText: aReplaySelectText on: self
]

{ #category : 'running' }
ReplayResolvedUIElement >> runShortcut: aReplayShortcut [

	^ backend runShortcut: aReplayShortcut on: self
]

{ #category : 'running' }
ReplayResolvedUIElement >> runType: aReplayType [

	^ backend runType: aReplayType on: self
]

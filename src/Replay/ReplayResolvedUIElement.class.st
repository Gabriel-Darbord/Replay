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

{ #category : 'testing' }
ReplayResolvedUIElement >> hasMorph [

	^ morph notNil
]

{ #category : 'accessing' }
ReplayResolvedUIElement >> morph [

	^ morph
]

{ #category : 'accessing' }
ReplayResolvedUIElement >> morph: aMorph [

	morph := aMorph
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

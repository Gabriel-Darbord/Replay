"
I am the abstract resolver that turns ReplayUIReference values into ReplayResolvedUIElement objects for a backend.
"
Class {
	#name : 'ReplayUIResolver',
	#superclass : 'Object',
	#instVars : [
		'backend',
		'maxAttempts',
		'attemptCount',
		'lastFailure'
	],
	#category : 'Replay-Backends',
	#package : 'Replay',
	#tag : 'Backends'
}

{ #category : 'instance creation' }
ReplayUIResolver class >> on: aBackend [

	^ self new
		backend: aBackend;
		yourself
]

{ #category : 'accessing' }
ReplayUIResolver >> attemptCount [

	^ attemptCount ifNil: [ attemptCount := 0 ]
]

{ #category : 'accessing' }
ReplayUIResolver >> attemptCount: anInteger [

	attemptCount := anInteger
]

{ #category : 'accessing' }
ReplayUIResolver >> backend [

	^ backend
]

{ #category : 'accessing' }
ReplayUIResolver >> backend: aBackend [

	backend := aBackend
]

{ #category : 'accessing' }
ReplayUIResolver >> maxAttempts [

	^ maxAttempts ifNil: [ maxAttempts := 20 ]
]

{ #category : 'accessing' }
ReplayUIResolver >> maxAttempts: anInteger [

	maxAttempts := 1 max: anInteger asInteger
]

{ #category : 'error handling' }
ReplayUIResolver >> missingReference: aReference reason: aString onMissing: missingBlock [

	| error |
	error := ReplayMissingUIError new
		messageText: aString;
		tag: (Dictionary new
			at: #backend put: backend;
			at: #reference put: aReference;
			at: #attempts put: self attemptCount;
			yourself);
		yourself.
	missingBlock value: error.
	^ nil
]

{ #category : 'resolving' }
ReplayUIResolver >> resolve: aReference forAction: anAction thenDo: foundBlock onMissing: missingBlock [

	^ self
		resolve: aReference
		thenDo: foundBlock
		onMissing: missingBlock
]

{ #category : 'resolving' }
ReplayUIResolver >> resolve: aReference thenDo: foundBlock [

	^ self
		resolve: aReference
		thenDo: foundBlock
		onMissing: [ :error | error signal ]
]

{ #category : 'resolving' }
ReplayUIResolver >> resolve: aReference thenDo: foundBlock onMissing: missingBlock [

	self subclassResponsibility
]

{ #category : 'resolving' }
ReplayUIResolver >> resolvedElementFor: aReference nativeElement: anObject morph: aMorph [

	^ ReplayResolvedUIElement
		backend: backend
		reference: aReference
		nativeElement: anObject
		morph: aMorph
]

{ #category : 'resolving' }
ReplayUIResolver >> schedule: aBlock [

	backend defer: aBlock
]

{ #category : 'testing' }
ReplayUIResolver >> supportsReference: aReference [

	^ false
]

"
I am a backend-independent reference to the target of a UI action, resolved by the resolver of the managed UI backend.

My kind is one of:
- #world: the current World, which needs no managed UI;
- #name: a semantic name, the value, that a Spec presenter exposes with replayPresenterAt:ifAbsent:;
- #morphicPath: the child indexes, the value, leading from the managed morph to the target;
- #keyboardFocus: the morph holding the keyboard focus, inside the managed UI.

I am a value: references of the same kind and value are equal.
"
Class {
	#name : 'ReplayUIReference',
	#superclass : 'Object',
	#instVars : [
		'kind',
		'value'
	],
	#category : 'Replay-Backends',
	#package : 'Replay',
	#tag : 'Backends'
}

{ #category : 'instance creation' }
ReplayUIReference class >> keyboardFocus [

	^ self new
		kind: #keyboardFocus;
		value: nil;
		yourself
]

{ #category : 'instance creation' }
ReplayUIReference class >> morphicPath: aCollection [

	^ self new
		kind: #morphicPath;
		value: aCollection;
		yourself
]

{ #category : 'instance creation' }
ReplayUIReference class >> named: aString [

	^ self new
		kind: #name;
		value: aString;
		yourself
]

{ #category : 'instance creation' }
ReplayUIReference class >> world [

	^ self new
		kind: #world;
		value: nil;
		yourself
]

{ #category : 'comparing' }
ReplayUIReference >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ kind = anObject kind and: [ value = anObject value ]
]

{ #category : 'comparing' }
ReplayUIReference >> hash [

	^ kind hash bitXor: value hash
]

{ #category : 'testing' }
ReplayUIReference >> isKeyboardFocus [

	^ kind = #keyboardFocus
]

{ #category : 'testing' }
ReplayUIReference >> isMorphicPath [

	^ kind = #morphicPath
]

{ #category : 'testing' }
ReplayUIReference >> isNamed [

	^ kind = #name
]

{ #category : 'testing' }
ReplayUIReference >> isWorld [

	^ kind = #world
]

{ #category : 'accessing' }
ReplayUIReference >> kind [

	^ kind
]

{ #category : 'accessing' }
ReplayUIReference >> kind: aSymbol [

	kind := aSymbol
]

{ #category : 'printing' }
ReplayUIReference >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: '(';
		print: kind.
	value ifNotNil: [
		aStream
			nextPutAll: ': ';
			print: value ].
	aStream nextPutAll: ')'
]

{ #category : 'accessing' }
ReplayUIReference >> value [

	^ value
]

{ #category : 'accessing' }
ReplayUIReference >> value: anObject [

	value := anObject
]

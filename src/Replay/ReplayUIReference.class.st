"
I am a backend-independent target reference, such as a semantic name or a Morphic path.
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

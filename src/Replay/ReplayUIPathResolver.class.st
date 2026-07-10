"
I resolve a recorded Replay UI path against a Morph tree on UI cycles.

Replay UI actions store paths as child indexes. Some Morph trees, especially browser and Spec-backed widgets, finish building asynchronously. I centralize the retry policy so actions do not recursively fork and defer their own lookup logic.
"
Class {
	#name : 'ReplayUIPathResolver',
	#superclass : 'Object',
	#instVars : [
		'root',
		'path',
		'whenFound',
		'whenMissing',
		'maxAttempts',
		'attemptCount',
		'lastFailure'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'instance creation' }
ReplayUIPathResolver class >> findPath: aCollection in: aMorph thenDo: foundBlock onMissing: missingBlock [

	^ self new
		  root: aMorph;
		  path: aCollection;
		  whenFound: foundBlock;
		  whenMissing: missingBlock;
		  resolve
]

{ #category : 'accessing' }
ReplayUIPathResolver >> attemptCount [

	^ attemptCount
]

{ #category : 'resolving' }
ReplayUIPathResolver >> attemptResolve [

	| target |
	attemptCount := attemptCount + 1.
	target := self resolvedTarget.
	target ifNotNil: [ ^ self found: target ].
	attemptCount >= maxAttempts ifTrue: [ ^ self missing ].
	self scheduleAttempt
]

{ #category : 'error handling' }
ReplayUIPathResolver >> availableChildSummaries [

	| current |
	root ifNil: [ ^ #(  ) ].
	current := root.
	path ifNil: [ ^ self childSummariesOf: current ].
	path do: [ :childIndex |
		(self shouldWaitFor: current) ifTrue: [ ^ self childSummariesOf: current ].
		current submorphs ifEmpty: [ ^ #(  ) ].
		(childIndex isInteger and: [ childIndex between: 1 and: current submorphs size ]) ifFalse: [
			^ self childSummariesOf: current ].
		current := current submorphs at: childIndex ].
	^ self childSummariesOf: current
]

{ #category : 'error handling' }
ReplayUIPathResolver >> childSummariesOf: aMorph [

	| summaries |
	summaries := OrderedCollection new.
	aMorph submorphs withIndexDo: [ :child :index |
		summaries add: (self childSummaryFor: child at: index) ].
	^ summaries asArray
]

{ #category : 'error handling' }
ReplayUIPathResolver >> childSummaryFor: aMorph at: index [

	^ (Dictionary new: 6)
		  at: #index put: index;
		  at: #class put: aMorph class name;
		  at: #bounds put: aMorph bounds printString;
		  at: #visible put: aMorph visible;
		  at: #submorphCount put: aMorph submorphs size;
		  at: #printString put: (aMorph printStringLimitedTo: 80);
		  yourself
]

{ #category : 'resolving' }
ReplayUIPathResolver >> found: aMorph [

	whenFound value: aMorph.
	^ aMorph
]

{ #category : 'initialization' }
ReplayUIPathResolver >> initialize [

	super initialize.
	maxAttempts := 120.
	attemptCount := 0.
	lastFailure := 'Target has not been resolved yet'
]

{ #category : 'accessing' }
ReplayUIPathResolver >> lastFailure [

	^ lastFailure
]

{ #category : 'accessing' }
ReplayUIPathResolver >> maxAttempts [

	^ maxAttempts
]

{ #category : 'accessing' }
ReplayUIPathResolver >> maxAttempts: anInteger [

	maxAttempts := 1 max: anInteger asInteger
]

{ #category : 'error handling' }
ReplayUIPathResolver >> missing [

	| error |
	error := ReplayMissingUIError new
		         messageText: self missingMessage;
		         tag: self missingDetails;
		         yourself.
	whenMissing value: error.
	^ nil
]

{ #category : 'error handling' }
ReplayUIPathResolver >> missingDetails [

	^ (Dictionary new: 5)
		  at: #root put: root;
		  at: #path put: path;
		  at: #attempts put: attemptCount;
		  at: #reason put: lastFailure;
		  at: #availableChildren put: self availableChildSummaries;
		  yourself
]

{ #category : 'error handling' }
ReplayUIPathResolver >> missingMessage [

	^ String streamContents: [ :stream |
		stream nextPutAll: 'Could not resolve UI target'.
		path ifNotNil: [
			stream nextPutAll: ' at path '.
			path printOn: stream ].
		stream
			nextPutAll: ' after ';
			print: attemptCount;
			nextPutAll: ' UI cycle(s).'.
		lastFailure ifNotNil: [
			stream space; nextPutAll: lastFailure ] ]
]

{ #category : 'accessing' }
ReplayUIPathResolver >> path [

	^ path
]

{ #category : 'accessing' }
ReplayUIPathResolver >> path: aCollection [

	path := aCollection
]

{ #category : 'resolving' }
ReplayUIPathResolver >> resolve [

	(path isNil or: [ path isEmpty ]) ifTrue: [ ^ self found: root ].
	^ self attemptResolve
]

{ #category : 'resolving' }
ReplayUIPathResolver >> resolvedTarget [

	| current |
	root ifNil: [
		lastFailure := 'No root morph was available.'.
		^ nil ].
	current := root.
	path withIndexDo: [ :childIndex :pathIndex |
		(self shouldWaitFor: current) ifTrue: [
			lastFailure := 'Waiting for ', current class name asString, ' to finish loading at path position ', pathIndex asString, '.'.
			^ nil ].
		current submorphs ifEmpty: [
			lastFailure := current class name asString, ' has no submorphs at path position ', pathIndex asString, '.'.
			^ nil ].
		(childIndex isInteger and: [ childIndex between: 1 and: current submorphs size ]) ifFalse: [
			lastFailure := String streamContents: [ :stream |
				stream
					nextPutAll: 'Path index ';
					print: childIndex;
					nextPutAll: ' at position ';
					print: pathIndex;
					nextPutAll: ' is outside ';
					print: current submorphs size;
					nextPutAll: ' submorph(s) of ';
					nextPutAll: current class name asString ].
			^ nil ].
		current := current submorphs at: childIndex ].
	^ current
]

{ #category : 'accessing' }
ReplayUIPathResolver >> root [

	^ root
]

{ #category : 'accessing' }
ReplayUIPathResolver >> root: aMorph [

	root := aMorph
]

{ #category : 'resolving' }
ReplayUIPathResolver >> scheduleAttempt [

	self currentWorld defer: [ self attemptResolve ].
	^ self
]

{ #category : 'testing' }
ReplayUIPathResolver >> shouldWaitFor: aMorph [

	aMorph class == ClyQueryViewMorph ifFalse: [ ^ false ].
	^ aMorph areItemsLoaded not
]

{ #category : 'accessing' }
ReplayUIPathResolver >> whenFound: aBlock [

	whenFound := aBlock
]

{ #category : 'accessing' }
ReplayUIPathResolver >> whenMissing: aBlock [

	whenMissing := aBlock
]

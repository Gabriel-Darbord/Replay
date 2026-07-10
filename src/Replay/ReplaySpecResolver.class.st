"
I resolve Spec presenter references semantically, falling back to Morphic surface paths.
"
Class {
	#name : 'ReplaySpecResolver',
	#superclass : 'ReplayUIResolver',
	#instVars : [
		'reference',
		'whenFound',
		'whenMissing'
	],
	#category : 'Replay-Backends',
	#package : 'Replay',
	#tag : 'Backends'
}

{ #category : 'resolving' }
ReplaySpecResolver >> attemptResolveNamed [

	| presenter morph |
	attemptCount := self attemptCount + 1.
	presenter := backend
		presenterNamed: reference value
		ifAbsent: [
			^ self
				missingReference: reference
				reason: 'No Spec presenter named ', reference value printString, ' was exposed by the managed presenter.'
				onMissing: whenMissing ].
	morph := self morphForPresenter: presenter.
	morph ifNotNil: [
		^ whenFound value: (self
			resolvedElementFor: reference
			nativeElement: presenter
			morph: morph) ].
	attemptCount >= self maxAttempts ifTrue: [
		^ self
			missingReference: reference
			reason: 'Spec presenter ', reference value printString, ' was found, but no rendered widget was available.'
			onMissing: whenMissing ].
	self schedule: [ self attemptResolveNamed ]
]

{ #category : 'resolving' }
ReplaySpecResolver >> morphForPresenter: aPresenter [

	| adapter |
	aPresenter isMorph ifTrue: [ ^ aPresenter ].
	adapter := aPresenter adapter.
	adapter ifNil: [ ^ nil ].
	^ adapter widget
]

{ #category : 'accessing' }
ReplaySpecResolver >> reference [

	^ reference
]

{ #category : 'resolving' }
ReplaySpecResolver >> resolve: aReference thenDo: foundBlock onMissing: missingBlock [

	aReference isNamed ifTrue: [
		^ self
			resolveNamed: aReference
			thenDo: foundBlock
			onMissing: missingBlock ].
	aReference isMorphicPath ifTrue: [
		^ (ReplayMorphicResolver on: backend)
			resolve: aReference
			thenDo: foundBlock
			onMissing: missingBlock ].
	^ self
		missingReference: aReference
		reason: 'Spec backend cannot resolve this UI reference.'
		onMissing: missingBlock
]

{ #category : 'resolving' }
ReplaySpecResolver >> resolveNamed: aReference thenDo: foundBlock onMissing: missingBlock [

	reference := aReference.
	whenFound := foundBlock.
	whenMissing := missingBlock.
	attemptCount := 0.
	^ self attemptResolveNamed
]

{ #category : 'testing' }
ReplaySpecResolver >> supportsReference: aReference [

	^ aReference isNamed or: [ aReference isMorphicPath ]
]

{ #category : 'accessing' }
ReplaySpecResolver >> whenFound [

	^ whenFound
]

{ #category : 'accessing' }
ReplaySpecResolver >> whenMissing [

	^ whenMissing
]

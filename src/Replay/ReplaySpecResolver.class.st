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

	^ self attemptResolveNamedForAction: nil
]

{ #category : 'resolving' }
ReplaySpecResolver >> attemptResolveNamedForAction: anAction [

	| targetPresenter targetMorph |
	attemptCount := self attemptCount + 1.
	targetPresenter := backend
		presenterNamed: reference value
		ifAbsent: [
			^ self
				missingReference: reference
				reason: 'No Spec presenter named ' , reference value printString , ' was exposed by managed presenter.'
				onMissing: whenMissing ].
	targetMorph := self morphForPresenter: targetPresenter.
	targetMorph ifNotNil: [
		^ whenFound value:
			(self resolvedElementFor: reference nativeElement: targetPresenter morph: targetMorph) ].
	(backend canRun: anAction nativelyOn: targetPresenter) ifTrue: [
		^ whenFound value:
			(self resolvedElementFor: reference nativeElement: targetPresenter morph: nil) ].
	attemptCount >= self maxAttempts ifTrue: [
		^ self
			missingReference: reference
			reason: 'Spec presenter ' , reference value printString , ' was found, but no rendered widget was available.'
			onMissing: whenMissing ].
	self schedule: [ self attemptResolveNamedForAction: anAction ]
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
ReplaySpecResolver >> resolve: aReference forAction: anAction thenDo: foundBlock onMissing: missingBlock [

	aReference isNamed ifTrue: [
		^ self
			resolveNamed: aReference
			forAction: anAction
			thenDo: foundBlock
			onMissing: missingBlock ].
	^ self resolve: aReference thenDo: foundBlock onMissing: missingBlock
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
ReplaySpecResolver >> resolveNamed: aReference forAction: anAction thenDo: foundBlock onMissing: missingBlock [

	reference := aReference.
	whenFound := foundBlock.
	whenMissing := missingBlock.
	attemptCount := 0.
	^ self attemptResolveNamedForAction: anAction
]

{ #category : 'resolving' }
ReplaySpecResolver >> resolveNamed: aReference thenDo: foundBlock onMissing: missingBlock [

	^ self
		resolveNamed: aReference
		forAction: nil
		thenDo: foundBlock
		onMissing: missingBlock
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

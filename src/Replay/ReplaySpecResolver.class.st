"
I resolve semantic names against the presenters that the managed Spec presenter exposes with replayPresenterAt:ifAbsent:, and other references like my superclass, against the rendered widget.

A named presenter resolves to itself as the native element, with its widget as morph. Until the presenter has a widget, I resolve it only for an action that can run natively on it (see ReplayUIHandler>>canRunNativelyOn:); otherwise I wait for the widget, like a name that is not exposed yet.
"
Class {
	#name : 'ReplaySpecResolver',
	#superclass : 'ReplayMorphicResolver',
	#category : 'Replay-Backends',
	#package : 'Replay',
	#tag : 'Backends'
}

{ #category : 'resolving' }
ReplaySpecResolver >> lookUpNamed: aReference forAction: anAction [

	| presenter morph |
	presenter := backend presenterNamed: aReference value ifAbsent: [
		             self
			             missing: aReference
			             because: 'No Spec presenter named ' , aReference value printString , ' was exposed by the managed presenter.' ].
	morph := self morphOf: presenter.
	(morph isNotNil or: [ anAction isNotNil and: [ anAction canRunNativelyOn: presenter ] ]) ifFalse: [
		self
			missing: aReference
			because: 'Spec presenter ' , aReference value printString , ' was found, but it has no rendered widget.' ].
	^ self resolvedElementFor: aReference nativeElement: presenter morph: morph
]

{ #category : 'resolving' }
ReplaySpecResolver >> lookupFor: aReference forAction: anAction [

	aReference isNamed ifTrue: [ ^ [ self lookUpNamed: aReference forAction: anAction ] ].
	^ super lookupFor: aReference forAction: anAction
]

{ #category : 'resolving' }
ReplaySpecResolver >> morphOf: aPresenter [

	aPresenter isMorph ifTrue: [ ^ aPresenter ].
	^ aPresenter adapter ifNotNil: [ :adapter | adapter widget ]
]

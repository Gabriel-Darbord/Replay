Class {
	#name : 'ReplayButtonSemanticPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'button',
		'clicked'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'accessing' }
ReplayButtonSemanticPresenter >> button [

	^ button
]

{ #category : 'accessing' }
ReplayButtonSemanticPresenter >> clicked [

	^ clicked
]

{ #category : 'layout' }
ReplayButtonSemanticPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		add: button;
		yourself
]

{ #category : 'initialization' }
ReplayButtonSemanticPresenter >> initializeLayout [

	self layout: self defaultLayout
]

{ #category : 'initialization' }
ReplayButtonSemanticPresenter >> initializePresenters [

	clicked := false.
	button := self newButton.
	button
		label: 'Click';
		action: [ clicked := true ]
]

{ #category : 'accessing' }
ReplayButtonSemanticPresenter >> replayPresenterAt: aPresenterName ifAbsent: absentBlock [

	aPresenterName = 'Button' ifTrue: [ ^ button ].
	^ absentBlock value
]

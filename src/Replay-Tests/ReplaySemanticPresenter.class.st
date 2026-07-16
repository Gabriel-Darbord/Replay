"
Test helper presenter exposing a child through Replay semantic lookup.
"
Class {
	#name : 'ReplaySemanticPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'field'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'layout' }
ReplaySemanticPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		add: field;
		yourself
]

{ #category : 'accessing' }
ReplaySemanticPresenter >> field [

	^ field
]

{ #category : 'initialization' }
ReplaySemanticPresenter >> initializeLayout [

	self layout: (SpBoxLayout newTopToBottom
		add: field;
		yourself)
]

{ #category : 'initialization' }
ReplaySemanticPresenter >> initializePresenters [

	field := self newTextInput.
	field text: 'semantic field'
]

{ #category : 'accessing' }
ReplaySemanticPresenter >> replayPresenterAt: aPresenterName ifAbsent: absentBlock [

	aPresenterName = 'Field' ifTrue: [ ^ field ].
	^ absentBlock value
]

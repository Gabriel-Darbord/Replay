"
Test helper presenter used by ReplayPresenterScriptTest.
"
Class {
	#name : 'ReplayScriptablePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'log'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'accessing' }
ReplayScriptablePresenter >> log [

	^ log ifNil: [ log := OrderedCollection new ]
]

{ #category : 'accessing' }
ReplayScriptablePresenter >> log: aCollection [

	log := aCollection
]

{ #category : 'recording' }
ReplayScriptablePresenter >> record: anObject [

	self log add: anObject
]

{ #category : 'recording' }
ReplayScriptablePresenter >> recordRun [

	self record: #ran
]

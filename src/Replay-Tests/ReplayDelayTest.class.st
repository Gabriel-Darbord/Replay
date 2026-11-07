"
Tests for ReplayDelay configuration and continuation.
"
Class {
	#name : 'ReplayDelayTest',
	#superclass : 'TestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'tests' }
ReplayDelayTest >> testDefaults [

	| action |
	action := ReplayDelay new.

	self assert: action controlsRunnerContinuation.
	self assert: action seconds equals: 1.
	self assert: (ReplayDelay seconds: 2) seconds equals: 2
]

{ #category : 'tests' }
ReplayDelayTest >> testEditionPresenterBuilds [

	| action presenter |
	action := ReplayDelay seconds: 1.
	presenter := ReplayEditor new editAction: action.

	self assert: presenter notNil
]

{ #category : 'tests' }
ReplayDelayTest >> testPrintsConfiguredSeconds [

	self assert: ((ReplayDelay seconds: 2) printString includesSubstring: '2s')
]

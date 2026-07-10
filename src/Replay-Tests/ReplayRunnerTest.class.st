"
Headless tests for ReplayRunner sequencing.
"
Class {
	#name : 'ReplayRunnerTest',
	#superclass : 'TestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'tests' }
ReplayRunnerTest >> testDelayActionDefaults [

	| action |
	action := ReplayDelay new.

	self assert: action controlsRunnerContinuation.
	self assert: action seconds equals: 1.
	self assert: (ReplayDelay seconds: 2) seconds equals: 2
]

{ #category : 'tests' }
ReplayRunnerTest >> testDelayActionEditionPresenterBuilds [

	| action presenter |
	action := ReplayDelay seconds: 1.
	presenter := action editionPresenterOn: ReplayEditor new.

	self assert: presenter notNil
]

{ #category : 'tests' }
ReplayRunnerTest >> testDelayActionPrintsConfiguredSeconds [

	self assert: ((ReplayDelay seconds: 2) printString includesSubstring: '2s')
]

{ #category : 'tests' }
ReplayRunnerTest >> testNextActionAfterStopDoesNothing [

	| scenario step runner |
	scenario := ReplayScenario new.
	step := ReplayStep new.
	step navigation skip: true.
	scenario addStep: step.
	runner := ReplayRunner on: scenario.

	[
		runner run.
		runner stop.
		self shouldnt: [ runner nextAction ] raise: Error ]
		ensure: [ runner manager ifNotNil: [ :manager | manager close ] ]
]

{ #category : 'tests' }
ReplayRunnerTest >> testRunDelayActionContinuesRunnerAsynchronously [

	| log scenario step runner |
	log := OrderedCollection new.
	scenario := ReplayScenario new.
	step := ReplayStep new.
	step navigation skip: true.
	step addAction: (ReplayRecordingAction label: #before log: log).
	step addAction: (ReplayDelay seconds: 0).
	step addAction: (ReplayRecordingAction label: #after log: log).
	scenario addStep: step.
	runner := ReplayRunner on: scenario.

	runner run.
	self assert: log asArray equals: #( before ).
	20 timesRepeat: [ World doOneCycle. (Delay forMilliseconds: 10) wait ].
	self assert: log asArray equals: #( before after )
]

{ #category : 'tests' }
ReplayRunnerTest >> testRunExecutesActionsInStepOrderWithoutOpeningNavigation [

	| log scenario step |
	log := OrderedCollection new.
	scenario := ReplayScenario new.
	step := ReplayStep new.
	step navigation skip: true.
	step addAction: (ReplayRecordingAction label: #first log: log).
	step addAction: (ReplayRecordingAction label: #second log: log).
	scenario addStep: step.
	scenario run.
	self assert: log asArray equals: #( first second )
]

{ #category : 'tests' }
ReplayRunnerTest >> testStopClosesAndClearsManager [

	| runner manager |
	runner := ReplayRunner new.
	manager := ReplayUIManager new manage: (Morph new extent: 100 @ 50); yourself.
	runner manager: manager.

	runner stop.

	self assert: runner isStopped.
	self assert: runner manager isNil
]

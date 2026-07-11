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
ReplayRunnerTest >> testAwaitUIActionDelegatesToManagerBackend [

	| backend manager runner |
	backend := ReplayRecordingBackend new.
	manager := ReplayUIManager new
		manage: (Morph new extent: 100 @ 50)
		usingBackend: backend.
	runner := ReplayRunner on: ReplayScenario new.
	runner manager: manager.

	ReplayAwaitUI new runOn: runner.

	self assert: backend lastInteraction equals: #settleUI
]

{ #category : 'tests' }
ReplayRunnerTest >> testAwaitUIActionEditionPresenterBuilds [

	| presenter |
	presenter := ReplayAwaitUI new editionPresenterOn: ReplayEditor new.

	self assert: presenter notNil
]

{ #category : 'tests' }
ReplayRunnerTest >> testAwaitUIActionRunsWithoutControllingContinuation [

	| action runner |
	action := ReplayAwaitUI new.
	runner := ReplayRunner on: ReplayScenario new.
	self deny: action controlsRunnerContinuation.
	self shouldnt: [ action runOn: runner ] raise: Error
]

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
ReplayRunnerTest >> testNavigateActionEditionPresenterBuilds [

	| action presenter |
	action := ReplayNavigate new.
	presenter := action editionPresenterOn: ReplayEditor new.

	self assert: presenter notNil
]

{ #category : 'tests' }
ReplayRunnerTest >> testNavigateBoundsOverridePositionAndExtent [

	| action window requestedBounds |
	requestedBounds := 50 @ 70 extent: 360 @ 150.
	action := ReplayNavigate new
		position: 12 @ 34;
		extent: 320 @ 140;
		bounds: requestedBounds;
		yourself.
	window := SpPresenter new asDialogWindow.
	action applyPlacementTo: window.
	self assert: action position isNil.
	self assert: action extent isNil.
	self assert: window initialPosition equals: requestedBounds origin.
	self assert: window initialExtent equals: requestedBounds extent
]

{ #category : 'tests' }
ReplayRunnerTest >> testNavigatePlacementAppliesPositionAndExtent [

	| action window |
	action := ReplayNavigate new
		position: 12 @ 34;
		extent: 320 @ 140;
		yourself.
	window := SpPresenter new asDialogWindow.
	action applyPlacementTo: window.
	self assert: window initialPosition equals: 12 @ 34.
	self assert: window initialExtent equals: 320 @ 140
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
ReplayRunnerTest >> testRunnerDeferDelegatesToManagerBackend [

	| backend manager runner ran |
	backend := ReplayRecordingBackend new.
	manager := ReplayUIManager new
		manage: (Morph new extent: 100 @ 50)
		usingBackend: backend.
	runner := ReplayRunner on: ReplayScenario new.
	runner manager: manager.
	ran := false.

	runner defer: [ ran := true ].

	self deny: ran.
	self assert: backend deferredBlockCount equals: 1.
	backend runDeferredBlocks.
	self assert: ran
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

"
Tests for ReplayRunner sequencing, UI manager ownership, and failure handling.
"
Class {
	#name : 'ReplayRunnerTest',
	#superclass : 'ReplayTestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayRunnerTest >> openPresenterAction [

	^ ReplayOpenPresenter new script: 'ReplayScriptablePresenter new'
]

{ #category : 'support' }
ReplayRunnerTest >> scenarioTitle [

	^ 'Replay runner test ' , self selector
]

{ #category : 'support' }
ReplayRunnerTest >> scenarioWithSteps: actionLists [

	| scenario |
	scenario := ReplayScenario new title: self scenarioTitle.
	actionLists do: [ :actions |
		| step |
		step := ReplayStep new.
		actions do: [ :action | step addAction: action ].
		scenario addStep: step ].
	^ scenario
]

{ #category : 'support' }
ReplayRunnerTest >> windowCountAction [
	"The runner focus is a block counting the windows of the scenario."

	^ ReplayScript new script: 'self focus value'
]

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
	presenter := ReplayEditor new editAction: ReplayAwaitUI new.

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
ReplayRunnerTest >> testCloseUIThroughRunnerClosesOwnedWindow [

	| counts runner |
	counts := OrderedCollection new.
	runner := ReplayRunner on: (self scenarioWithSteps: { {
		self openPresenterAction.
		self windowCountAction.
		ReplayCloseUI new.
		self windowCountAction } }).
	runner focus: [ counts add: (self newWindowsLabeled: self scenarioTitle) size ].

	runner run.

	self assert: counts asArray equals: #( 1 0 ).
	self assert: runner isStopped.
	self assert: runner manager isNil
]

{ #category : 'tests' }
ReplayRunnerTest >> testErrorInDeferredContinuationStopsRunner [

	| backend manager scenario runner |
	backend := ReplayRecordingBackend new.
	manager := ReplayUIManager new
		manage: (Morph new extent: 100 @ 50)
		usingBackend: backend.
	Morph new addMorph: manager ui.
	scenario := self scenarioWithSteps: { {  } }.
	scenario steps first navigation skip: false.
	runner := ReplayRunner on: scenario.
	runner run. "Waits on the navigation dialog"
	runner manager: manager.
	runner defer: [ self error: 'Deferred failure' ].

	self deny: runner isStopped.
	self should: [ backend runDeferredBlocks ] raise: Error.
	self assert: runner isStopped.
	self assert: runner manager isNil.
	self assert: manager ui owner isNil
]

{ #category : 'tests' }
ReplayRunnerTest >> testErrorMidScenarioStopsRunnerAndClosesOwnedUI [

	| log runner |
	log := OrderedCollection new.
	runner := ReplayRunner on: (self scenarioWithSteps: { {
		self openPresenterAction.
		(ReplayScript new script: 'self error: ''Scenario failure''').
		(ReplayRecordingAction label: #after log: log) } }).

	self should: [ runner run ] raise: ReplayScriptError.
	self assert: runner isStopped.
	self assert: runner manager isNil.
	self assert: log isEmpty.
	self assert: (self newWindowsLabeled: self scenarioTitle) isEmpty
]

{ #category : 'tests' }
ReplayRunnerTest >> testLongScenarioDoesNotDeepenTheStack [

	| depths runner |
	depths := OrderedCollection new.
	runner := ReplayRunner on: (self scenarioWithSteps: ((1 to: 50) collect: [ :index |
		{ ReplayScript new script: 'self focus add: thisContext stack size' } ])).
	runner focus: depths.

	runner run.

	self assert: depths size equals: 50.
	self assert: depths asSet size equals: 1
]

{ #category : 'tests' }
ReplayRunnerTest >> testManagerReplacementClosesPreviousManager [

	| runner firstRoot first second |
	runner := ReplayRunner new.
	firstRoot := Morph new.
	first := ReplayUIManager new manage: (Morph new extent: 100 @ 50).
	firstRoot addMorph: first ui.
	second := ReplayUIManager new manage: (Morph new extent: 100 @ 50).

	runner manager: first.
	runner manager: second.

	self assert: runner manager identicalTo: second.
	self assert: first ui owner isNil.
	runner manager: second.
	self assert: runner manager identicalTo: second
]

{ #category : 'tests' }
ReplayRunnerTest >> testNextActionAfterStopDoesNothing [

	| scenario step runner |
	scenario := ReplayScenario new.
	step := ReplayStep new.
	step navigation skip: true.
	scenario addStep: step.
	runner := ReplayRunner on: scenario.

	runner run.
	runner stop.
	self shouldnt: [ runner nextAction ] raise: Error.
	self assert: runner isStopped
]

{ #category : 'tests' }
ReplayRunnerTest >> testRunDelayActionContinuesRunnerAsynchronously [

	| log runner |
	log := OrderedCollection new.
	runner := ReplayRunner on: (self scenarioWithSteps: { {
		(ReplayRecordingAction label: #before log: log).
		(ReplayDelay seconds: 0).
		(ReplayRecordingAction label: #after log: log) } }).

	runner run.
	self assert: log asArray equals: #( before ).
	self waitUntil: [ runner isStopped ].
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
ReplayRunnerTest >> testRunExecutesEveryStepInOrder [

	| log runner |
	log := OrderedCollection new.
	runner := ReplayRunner on: (self scenarioWithSteps: {
		{ ReplayRecordingAction label: #first log: log }.
		{  }.
		{
			(ReplayRecordingAction label: #second log: log).
			(ReplayRecordingAction label: #third log: log) } }).

	runner run.

	self assert: log asArray equals: #( first second third ).
	self assert: runner isStopped
]

{ #category : 'tests' }
ReplayRunnerTest >> testRunStepNotInScenarioSignalsReplayError [

	| runner |
	runner := ReplayRunner on: (self scenarioWithSteps: { {  } }).

	self should: [ runner runStep: ReplayStep new ] raise: ReplayError
]

{ #category : 'tests' }
ReplayRunnerTest >> testRunStepStartsFromTheGivenStep [

	| log scenario runner |
	log := OrderedCollection new.
	scenario := self scenarioWithSteps: {
		{ ReplayRecordingAction label: #first log: log }.
		{ ReplayRecordingAction label: #second log: log }.
		{ ReplayRecordingAction label: #third log: log } }.
	runner := ReplayRunner on: scenario.

	runner runStep: scenario steps second.

	self assert: log asArray equals: #( second third ).
	self assert: runner isStopped
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

{ #category : 'tests' }
ReplayRunnerTest >> testTwoOpenersInARowKeepOnlyTheLastWindow [

	| runner windowCounts |
	windowCounts := OrderedCollection new.
	runner := ReplayRunner on: (self scenarioWithSteps: { {
		self openPresenterAction.
		self openPresenterAction.
		self windowCountAction } }).
	runner focus: [ windowCounts add: (self newWindowsLabeled: self scenarioTitle) size ].

	runner run.

	self assert: windowCounts asArray equals: #( 1 ).
	self assert: (self newWindowsLabeled: self scenarioTitle) isEmpty
]

"
Tests for ReplayNavigate defaults, placement, and the navigation dialog answers.
"
Class {
	#name : 'ReplayNavigateTest',
	#superclass : 'ReplayTestCase',
	#instVars : [
		'log'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayNavigateTest >> dialog [

	| windows |
	windows := self newWindowsLabeled: self scenarioTitle.
	self assert: windows size equals: 1.
	^ windows first model
]

{ #category : 'support' }
ReplayNavigateTest >> runTwoStepScenario [
	"The first step asks the user before the second one."

	| scenario first second runner |
	log := OrderedCollection new.
	scenario := ReplayScenario new title: self scenarioTitle.
	first := ReplayStep new.
	first navigation skip: false.
	scenario addStep: first.
	second := ReplayStep new.
	second addAction: (ReplayRecordingAction label: #second log: log).
	scenario addStep: second.
	runner := ReplayRunner on: scenario.
	runner run.
	^ runner
]

{ #category : 'support' }
ReplayNavigateTest >> scenarioTitle [

	^ 'Replay navigate test ' , self selector
]

{ #category : 'tests' }
ReplayNavigateTest >> testAcceptContinuesWithNextStep [

	| runner |
	runner := self runTwoStepScenario.
	self deny: runner isStopped.

	(self dialog buttons detect: [ :button | button label = 'Next' ]) click.
	self waitUntil: [ runner isStopped ].

	self assert: log asArray equals: #( second ).
	self assert: (self newWindowsLabeled: self scenarioTitle) isEmpty
]

{ #category : 'tests' }
ReplayNavigateTest >> testCancelStopsRunner [

	| runner |
	runner := self runTwoStepScenario.

	(self dialog buttons detect: [ :button | button label = 'Stop' ]) click.

	self assert: runner isStopped.
	self assert: log isEmpty
]

{ #category : 'tests' }
ReplayNavigateTest >> testClosingDialogStopsRunner [

	| runner |
	runner := self runTwoStepScenario.

	self dialog close.
	self currentWorld doOneCycle.

	self assert: runner isStopped.
	self assert: log isEmpty
]

{ #category : 'tests' }
ReplayNavigateTest >> testDefaultsAreAnsweredWithoutBeingStored [

	| action |
	action := ReplayNavigate new.

	self assert: action skip.
	self assert: action acceptLabel equals: 'Next'.
	self assert: action cancelLabel equals: 'Stop'.
	self assert: action text equals: 'Proceed?'.
	self assert: action printString equals: 'Navigate'.
	self assert: action isDefault.
	self assert: (action instVarNamed: #text) isNil.
	self assert: (action instVarNamed: #skip) isNil
]

{ #category : 'tests' }
ReplayNavigateTest >> testEditionPresenterBuilds [

	| action presenter |
	action := ReplayNavigate new.
	presenter := ReplayEditor new editAction: action.

	self assert: presenter notNil.
	self assert: action isDefault
]

{ #category : 'tests' }
ReplayNavigateTest >> testIsDefaultUntilConfigured [

	self deny: (ReplayNavigate new skip: false; yourself) isDefault.
	self deny: (ReplayNavigate new text: 'Hello'; yourself) isDefault.
	self deny: (ReplayNavigate new acceptLabel: 'Go'; yourself) isDefault.
	self deny: (ReplayNavigate new cancelLabel: 'Quit'; yourself) isDefault.
	self deny: (ReplayNavigate new placement: (ReplayPlacement position: 1 @ 2); yourself) isDefault.
	self assert: (ReplayNavigate new skip: true; yourself) isDefault
]

{ #category : 'tests' }
ReplayNavigateTest >> testPlacementAppliesBoundsToDialog [

	| action window requestedBounds |
	requestedBounds := 50 @ 70 extent: 360 @ 150.
	action := ReplayNavigate new placement: (ReplayPlacement bounds: requestedBounds).
	window := SpPresenter new asDialogWindow.

	action placement applyToWindowPresenter: window.

	self assert: window initialPosition equals: requestedBounds origin.
	self assert: window initialExtent equals: requestedBounds extent
]

{ #category : 'tests' }
ReplayNavigateTest >> testPlacementAppliesPositionAndExtentToDialog [

	| action window |
	action := ReplayNavigate new placement: (ReplayPlacement position: 12 @ 34 extent: 320 @ 140).
	window := SpPresenter new asDialogWindow.

	action placement applyToWindowPresenter: window.

	self assert: window initialPosition equals: 12 @ 34.
	self assert: window initialExtent equals: 320 @ 140
]

{ #category : 'tests' }
ReplayNavigateTest >> testSkipsByDefault [

	self assert: ReplayNavigate new skip.
	self assert: ReplayStep new navigation skip
]

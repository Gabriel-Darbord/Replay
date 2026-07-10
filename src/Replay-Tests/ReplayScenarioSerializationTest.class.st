"
Headless tests for Replay scenario STON serialization.
"
Class {
	#name : 'ReplayScenarioSerializationTest',
	#superclass : 'TestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayScenarioSerializationTest >> roundTripAction: anAction [

	| scenario step copy |
	scenario := ReplayScenario new.
	step := ReplayStep new.
	step addAction: anAction.
	scenario addStep: step.
	copy := STON fromString: (STON toString: scenario).
	^ copy steps first actions first
]

{ #category : 'tests' }
ReplayScenarioSerializationTest >> testOpenPlacementRoundTripsThroughSton [

	| action copy |
	action := ReplayOpenPresenter new
		script: 'SpPresenter new';
		extent: 1083 @ 532;
		bounds: (10 @ 20 corner: 300 @ 400);
		yourself.
	copy := self roundTripAction: action.
	self assert: copy class equals: ReplayOpenPresenter.
	self assert: copy script equals: 'SpPresenter new'.
	self assert: copy extent equals: 1083 @ 532.
	self assert: copy bounds equals: (10 @ 20 corner: 300 @ 400)
]

{ #category : 'tests' }
ReplayScenarioSerializationTest >> testScenarioRoundTripsThroughSton [

	| scenario step action copy copyStep copyAction |
	scenario := ReplayScenario new
		            title: 'Serialization demo';
		            description: 'Headless scenario';
		            yourself.
	step := ReplayStep new.
	step navigation
		skip: true;
		acceptLabel: 'Continue';
		cancelLabel: 'Stop';
		text: 'Done'.
	action := ReplayScript new script: '1 + 1'.
	step addAction: action.
	scenario addStep: step.
	copy := STON fromString: (STON toString: scenario).
	self assert: copy title equals: scenario title.
	self assert: copy description equals: scenario description.
	self assert: copy steps size equals: 1.
	copyStep := copy steps first.
	self assert: copyStep navigation skip.
	self assert: copyStep navigation acceptLabel equals: 'Continue'.
	self assert: copyStep navigation cancelLabel equals: 'Stop'.
	self assert: copyStep navigation text equals: 'Done'.
	copyAction := copyStep actions first.
	self assert: copyAction class equals: ReplayScript.
	self assert: copyAction script equals: '1 + 1'
]

{ #category : 'tests' }
ReplayScenarioSerializationTest >> testSelectTextActionRoundTripsThroughSton [

	| action copy |
	action := ReplaySelectText new
		targetNamed: 'Action script';
		startIndex: 2;
		stopIndex: 5;
		yourself.
	copy := self roundTripAction: action.
	self assert: copy class equals: ReplaySelectText.
	self assert: copy targetName equals: 'Action script'.
	self assert: copy startIndex equals: 2.
	self assert: copy stopIndex equals: 5
]

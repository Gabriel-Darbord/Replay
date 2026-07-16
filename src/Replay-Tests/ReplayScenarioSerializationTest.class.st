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
ReplayScenarioSerializationTest >> testAnnotatePlacementRoundTripsThroughSton [

	| copy |
	copy := self roundTripAction: (ReplayAnnotate new
		placement: #aboveLeft;
		text: 'Placed label';
		yourself).
	self assert: copy placement equals: #aboveLeft.
	self assert: copy text equals: 'Placed label'
]

{ #category : 'tests' }
ReplayScenarioSerializationTest >> testAwaitUIActionRoundTripsThroughSton [

	| copy |
	copy := self roundTripAction: ReplayAwaitUI new.
	self assert: copy class equals: ReplayAwaitUI
]

{ #category : 'tests' }
ReplayScenarioSerializationTest >> testClickActionOptionsRoundTripThroughSton [

	| action copy |
	action := ReplayClick new
		targetNamed: 'Button';
		position: 12 @ 8;
		clickCount: 2;
		modifiers: UserInputEvent shiftKeyMask;
		yourself.
	copy := self roundTripAction: action.
	self assert: copy class equals: ReplayClick.
	self assert: copy targetName equals: 'Button'.
	self assert: copy position equals: 12 @ 8.
	self assert: copy clickCount equals: 2.
	self assert: copy modifiers equals: UserInputEvent shiftKeyMask
]

{ #category : 'tests' }
ReplayScenarioSerializationTest >> testDeleteTextActionRoundTripsThroughSton [

	| action copy |
	action := ReplayDeleteText new targetNamed: 'Action script'; direction: #forward; count: 3; yourself.
	copy := self roundTripAction: action.
	self assert: copy class equals: ReplayDeleteText.
	self assert: copy targetName equals: 'Action script'.
	self assert: copy direction equals: #forward.
	self assert: copy count equals: 3
]

{ #category : 'tests' }
ReplayScenarioSerializationTest >> testDragActionRoundTripsThroughSton [

	| action copy |
	action := ReplayDrag new
		targetNamed: 'Slider';
		startPosition: 3 @ 4;
		endPosition: 30 @ 40;
		steps: 5;
		flags: MouseEvent yellowButton;
		modifiers: UserInputEvent cmdKeyMask;
		yourself.
	copy := self roundTripAction: action.
	self assert: copy class equals: ReplayDrag.
	self assert: copy targetName equals: 'Slider'.
	self assert: copy startPosition equals: 3 @ 4.
	self assert: copy endPosition equals: 30 @ 40.
	self assert: copy steps equals: 5.
	self assert: copy flags equals: MouseEvent yellowButton.
	self assert: copy modifiers equals: UserInputEvent cmdKeyMask
]

{ #category : 'tests' }
ReplayScenarioSerializationTest >> testNavigatePlacementRoundTripsThroughSton [

	| scenario positionedStep boundedStep copy positionedNavigation boundedNavigation |
	scenario := ReplayScenario new.
	positionedStep := ReplayStep new.
	positionedStep navigation
		position: 12 @ 34;
		extent: 320 @ 140.
	scenario addStep: positionedStep.
	boundedStep := ReplayStep new.
	boundedStep navigation bounds: (50 @ 70 extent: 360 @ 150).
	scenario addStep: boundedStep.

	copy := STON fromString: (STON toString: scenario).
	positionedNavigation := copy steps first navigation.
	boundedNavigation := copy steps second navigation.
	self assert: positionedNavigation position equals: 12 @ 34.
	self assert: positionedNavigation extent equals: 320 @ 140.
	self assert: positionedNavigation bounds isNil.
	self assert: boundedNavigation bounds equals: (50 @ 70 extent: 360 @ 150).
	self assert: boundedNavigation position isNil.
	self assert: boundedNavigation extent isNil
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
ReplayScenarioSerializationTest >> testScrollActionRoundTripsThroughSton [

	| action copy |
	action := ReplayScroll new
		targetNamed: 'List';
		direction: #left;
		count: 4;
		position: 9 @ 7;
		modifiers: UserInputEvent ctrlKeyMask;
		yourself.
	copy := self roundTripAction: action.
	self assert: copy class equals: ReplayScroll.
	self assert: copy targetName equals: 'List'.
	self assert: copy direction equals: #left.
	self assert: copy count equals: 4.
	self assert: copy position equals: 9 @ 7.
	self assert: copy modifiers equals: UserInputEvent ctrlKeyMask
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

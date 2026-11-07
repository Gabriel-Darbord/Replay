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
ReplayScenarioSerializationTest >> testAttachActionsRoundTripThroughSton [

	| copy |
	copy := self roundTripAction: (ReplayAttachUI new script: 'self focus').
	self assert: copy class equals: ReplayAttachUI.
	self assert: copy script equals: 'self focus'.
	self assert: (self roundTripAction: ReplayAttachWorld new) class equals: ReplayAttachWorld.
	self
		assert: (self roundTripAction: ReplayAttachActiveWindow new) class
		equals: ReplayAttachActiveWindow
]

{ #category : 'tests' }
ReplayScenarioSerializationTest >> testBrowseActionsRoundTripThroughSton [

	| copy |
	copy := self roundTripAction: (ReplayBrowseClass new targetClass: ReplayStep; yourself).
	self assert: copy targetClass equals: ReplayStep.
	copy := self roundTripAction: (ReplayBrowseMethod new targetMethod: ReplayScenario class >> #example; yourself).
	self assert: copy targetMethod equals: ReplayScenario class >> #example.
	copy := self roundTripAction: (ReplayBrowsePackage new targetPackage: ReplayStep package; yourself).
	self assert: copy targetPackage equals: ReplayStep package
]

{ #category : 'tests' }
ReplayScenarioSerializationTest >> testDefaultsAreNotSerialized [

	| scenario step ston |
	scenario := ReplayScenario new.
	step := ReplayStep new.
	step addAction: ReplayScript new.
	step addAction: ReplayInform new.
	step addAction: ReplayOpenPresenter new.
	scenario addStep: step.
	"Reading defaults or printing must not store them"
	scenario title; description.
	step navigation skip; text; acceptLabel; cancelLabel.
	step printString.
	step actions do: [ :each | each printString ].

	ston := STON toString: scenario.

	#( 'title' 'description' 'navigation' 'ReplayNavigate' 'script' 'text' 'placement' ) do: [ :key |
		self deny: (ston includesSubstring: key) ].
	self assert: (STON fromString: ston) steps first navigation isDefault
]

{ #category : 'tests' }
ReplayScenarioSerializationTest >> testDelayActionRoundTripsThroughSton [

	self assert: (self roundTripAction: (ReplayDelay seconds: 2.5)) seconds equals: 2.5
]

{ #category : 'tests' }
ReplayScenarioSerializationTest >> testExampleStonLoads [

	| scenario step |
	scenario := STON fromString: ReplayScenario exampleSton.
	self assert: scenario title equals: 'Example Scenario'.
	self assert: scenario steps size equals: 1.
	step := scenario steps first.
	self assert: step actions first targetClass equals: ReplayScenario.
	self assert: step actions second class equals: ReplayAnnotate.
	self deny: step navigation skip.
	self assert: step navigation text equals: 'Thus concludes this example.'.
	self assert: step navigation acceptLabel equals: 'Next'
]

{ #category : 'tests' }
ReplayScenarioSerializationTest >> testInformActionRoundTripsThroughSton [

	self assert: (self roundTripAction: (ReplayInform new text: 'Hello')) text equals: 'Hello'
]

{ #category : 'tests' }
ReplayScenarioSerializationTest >> testNavigateSkipFalseRoundTripsThroughSton [

	| scenario step copy |
	scenario := ReplayScenario new.
	step := ReplayStep new.
	step navigation skip: false.
	scenario addStep: step.

	copy := STON fromString: (STON toString: scenario).

	self deny: copy steps first navigation skip
]

{ #category : 'tests' }
ReplayScenarioSerializationTest >> testUIActionsWithoutSettingsRoundTripThroughSton [

	{ ReplayCloseUI. ReplayClearAnnotations } do: [ :class |
		self assert: (self roundTripAction: class new) class equals: class ]
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
		buttons: MouseEvent yellowButton;
		modifiers: UserInputEvent cmdKeyMask;
		yourself.
	copy := self roundTripAction: action.
	self assert: copy class equals: ReplayDrag.
	self assert: copy targetName equals: 'Slider'.
	self assert: copy startPosition equals: 3 @ 4.
	self assert: copy endPosition equals: 30 @ 40.
	self assert: copy steps equals: 5.
	self assert: copy buttons equals: MouseEvent yellowButton.
	self assert: copy modifiers equals: UserInputEvent cmdKeyMask
]

{ #category : 'tests' }
ReplayScenarioSerializationTest >> testNavigatePlacementRoundTripsThroughSton [

	| scenario positionedStep boundedStep copy |
	scenario := ReplayScenario new.
	positionedStep := ReplayStep new.
	positionedStep navigation placement: (ReplayPlacement position: 12 @ 34 extent: 320 @ 140).
	scenario addStep: positionedStep.
	boundedStep := ReplayStep new.
	boundedStep navigation placement: (ReplayPlacement bounds: (50 @ 70 extent: 360 @ 150)).
	scenario addStep: boundedStep.

	copy := STON fromString: (STON toString: scenario).
	self
		assert: copy steps first navigation placement
		equals: (ReplayPlacement position: 12 @ 34 extent: 320 @ 140).
	self
		assert: copy steps second navigation placement
		equals: (ReplayPlacement bounds: (50 @ 70 extent: 360 @ 150))
]

{ #category : 'tests' }
ReplayScenarioSerializationTest >> testOpenPlacementRoundTripsThroughSton [

	| action copy |
	action := ReplayOpenPresenter new
		script: 'SpPresenter new';
		placement: (ReplayPlacement bounds: (10 @ 20 corner: 300 @ 400));
		yourself.
	copy := self roundTripAction: action.
	self assert: copy class equals: ReplayOpenPresenter.
	self assert: copy script equals: 'SpPresenter new'.
	self assert: copy placement equals: (ReplayPlacement bounds: (10 @ 20 corner: 300 @ 400))
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

{ #category : 'tests' }
ReplayScenarioSerializationTest >> testPointerActionDefaultsAreNotSerialized [

	| ston |
	ston := STON toString: { ReplayClick new. ReplayDrag new. ReplayScroll new }.

	#( 'buttons' 'modifiers' 'clickCount' 'mousePhase' 'steps' 'target' ) do: [ :key |
		self deny: (ston includesSubstring: key) ]
]

{ #category : 'tests' }
ReplayScenarioSerializationTest >> testUIActionTargetRoundTripsThroughSton [

	{
		(ReplayUIReference morphicPath: #( 3 1 2 )).
		(ReplayUIReference named: 'Button').
		ReplayUIReference keyboardFocus } do: [ :reference |
		| copy |
		copy := self roundTripAction: (ReplayClick target: reference).
		self assert: copy target equals: reference ].
	self assert: (self roundTripAction: ReplayFocus new) target isWorld
]

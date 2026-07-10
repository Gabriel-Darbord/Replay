"
Tests for the Replay editor demo scenario.
"
Class {
	#name : 'ReplayEditorDemoTest',
	#superclass : 'TestCase',
	#category : 'Replay-Demo-Tests',
	#package : 'Replay-Demo-Tests'
}

{ #category : 'tests' }
ReplayEditorDemoTest >> testDemoScenarioRoundTripsThroughSton [

	| copy |
	copy := STON fromString: (STON toString: ReplayEditorDemo scenario).
	self assert: copy title equals: 'Replay Editor Feature Tour'.
	self assert: copy steps size equals: 7
]

{ #category : 'tests' }
ReplayEditorDemoTest >> testReplayEditorExposesDemoSemanticTargets [

	| editor missing |
	editor := ReplayEditor on: ReplayScenario new.
	#('Step list' 'Action list' 'Action chooser' 'Action editor') do: [ :targetName |
		self assert: (editor replayPresenterAt: targetName ifAbsent: [ nil ]) notNil ].
	missing := editor replayPresenterAt: 'Missing target' ifAbsent: [ #missing ].
	self assert: missing equals: #missing
]

{ #category : 'tests' }
ReplayEditorDemoTest >> testScenarioEditsCurrentActionScriptField [

	| actions selectAction typeAction |
	actions := ReplayEditorDemo scenario steps flatCollect: [ :step | step actions ].
	selectAction := actions detect: [ :action | action isKindOf: ReplaySelectText ].
	typeAction := actions detect: [ :action | action isKindOf: ReplayType ].
	self assert: selectAction targetName equals: 'Action script'.
	self assert: typeAction targetName equals: 'Action script'.
	self assert: typeAction text equals: ReplayEditorDemo new replacementScript
]

{ #category : 'tests' }
ReplayEditorDemoTest >> testScenarioStructure [

	| scenario expectedNavigationPosition |
	scenario := ReplayEditorDemo scenario.
	expectedNavigationPosition := ReplayEditorDemo new navigationPosition.
	self assert: scenario title equals: 'Replay Editor Feature Tour'.
	self assert: scenario steps size equals: 7.
	self assert: (scenario steps first actions anySatisfy: [ :action | action isKindOf: ReplayAttachUI ]).
	self assert: (scenario steps anySatisfy: [ :step |
		step actions anySatisfy: [ :action | action isKindOf: ReplayScript ] ]).
	self assert: (scenario steps anySatisfy: [ :step |
		step actions anySatisfy: [ :action | action isKindOf: ReplayAnnotate ] ]).
	self assert: (scenario steps anySatisfy: [ :step |
		step actions anySatisfy: [ :action | action isKindOf: ReplaySelectText ] ]).
	self assert: (scenario steps anySatisfy: [ :step |
		step actions anySatisfy: [ :action | action isKindOf: ReplayType ] ]).
	self assert: (scenario steps noneSatisfy: [ :step |
		step actions anySatisfy: [ :action | action isKindOf: ReplayDelay ] ]).
	self assert: (scenario steps noneSatisfy: [ :step | step navigation skip ]).
	self assert: (scenario steps allSatisfy: [ :step |
		step navigation position = expectedNavigationPosition ]).
	self assert: (scenario steps allSatisfy: [ :step | step navigation extent isNil ]).
	self assert: (scenario steps allSatisfy: [ :step | step navigation bounds isNil ])
]

{ #category : 'tests' }
ReplayEditorDemoTest >> testScriptActionRunsWithRunnerAsReceiver [

	| runner action |
	runner := ReplayRunner on: ReplayScenario new.
	action := ReplayScript new
		script: 'self focus: #scriptRan';
		yourself.
	action runOn: runner.
	self assert: runner focus equals: #scriptRan
]

{ #category : 'tests' }
ReplayEditorDemoTest >> testSetupEditorActionPositionsWindowWithoutChangingExtent [

	| action script |
	action := ReplayEditorDemo new setupEditorAction.
	script := action script.
	self assert: (script includesSubstring: 'initialPosition:').
	self assert: (script includesSubstring: ReplayEditorDemo new editorPosition storeString).
	self deny: (script includesSubstring: 'initialExtent:')
]

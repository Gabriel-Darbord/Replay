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
	self assert: copy steps size equals: 5
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
ReplayEditorDemoTest >> testScenarioStructure [

	| scenario |
	scenario := ReplayEditorDemo scenario.
	self assert: scenario title equals: 'Replay Editor Feature Tour'.
	self assert: scenario steps size equals: 5.
	self assert: (scenario steps first actions anySatisfy: [ :action | action isKindOf: ReplayAttachUI ]).
	self assert: (scenario steps anySatisfy: [ :step |
		step actions anySatisfy: [ :action | action isKindOf: ReplayScript ] ]).
	self assert: (scenario steps anySatisfy: [ :step |
		step actions anySatisfy: [ :action | action isKindOf: ReplayAnnotate ] ]).
	self assert: (scenario steps allSatisfy: [ :step | step navigation skip ])
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

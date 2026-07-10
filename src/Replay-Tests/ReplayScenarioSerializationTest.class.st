"
Headless tests for Replay scenario STON serialization.
"
Class {
	#name : 'ReplayScenarioSerializationTest',
	#superclass : 'TestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

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

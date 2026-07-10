"
Tests semantic target registration in the Replay editor.
"
Class {
	#name : 'ReplayEditorSemanticTargetTest',
	#superclass : 'TestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayEditorSemanticTargetTest >> newEditor [

	^ ReplayEditor on: ReplayScenario new
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testRegistersAndClearsDynamicReplayTargets [

	| editor presenter |
	editor := self newEditor.
	presenter := editor newText.
	editor registerReplayPresenter: presenter named: 'Registered target'.

	self assert: (editor replayPresenterAt: 'Registered target' ifAbsent: [ nil ]) equals: presenter.
	editor clearReplayPresenterTargets.
	self assert: (editor replayPresenterAt: 'Registered target' ifAbsent: [ #missing ]) equals: #missing
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testScenarioFieldsAreRegistered [

	| editor |
	editor := self newEditor.
	editor model scenario editionPresenterOn: editor.
	self assert: (editor replayPresenterAt: 'Scenario title' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Scenario description' ifAbsent: [ nil ]) notNil
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testSelectingActionReplacesDynamicTargets [

	| editor scenario step typeAction delayAction |
	scenario := ReplayScenario new.
	step := ReplayStep new.
	typeAction := ReplayType new.
	delayAction := ReplayDelay seconds: 1.
	step addAction: typeAction.
	step addAction: delayAction.
	scenario addStep: step.
	editor := ReplayEditor on: scenario.

	editor selectAction: typeAction.
	self assert: (editor replayPresenterAt: 'Action text' ifAbsent: [ nil ]) notNil.
	editor selectAction: delayAction.
	self assert: (editor replayPresenterAt: 'Action text' ifAbsent: [ #missing ]) equals: #missing.
	self assert: (editor replayPresenterAt: 'Action seconds' ifAbsent: [ nil ]) notNil
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testSelectionAndTargetNameFieldTargetsAreRegistered [

	| editor |
	editor := self newEditor.
	ReplaySelectText new startIndexPresenterOn: editor.
	ReplaySelectText new stopIndexPresenterOn: editor.
	self assert: (editor replayPresenterAt: 'Action selection start' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Select text selection start' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Action selection stop' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Select text selection stop' ifAbsent: [ nil ]) notNil.

	editor clearReplayPresenterTargets.
	ReplayType new semanticTargetPresenterOn: editor.
	self assert: (editor replayPresenterAt: 'Action target name' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Type target name' ifAbsent: [ nil ]) notNil
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testSharedActionFieldTargetsAreRegistered [

	| editor |
	editor := self newEditor.
	ReplayType new textPresenterOn: editor labeled: 'Text:'.
	self assert: (editor replayPresenterAt: 'Action text' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Type text' ifAbsent: [ nil ]) notNil.

	editor clearReplayPresenterTargets.
	ReplayScript new scriptPresenterOn: editor labeled: 'Script:'.
	self assert: (editor replayPresenterAt: 'Action script' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Script source' ifAbsent: [ nil ]) notNil
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testSpecificActionFieldTargetsAreRegistered [

	| editor |
	editor := self newEditor.
	(ReplayDelay seconds: 1) secondsPresenterOn: editor labeled: 'Delay in seconds:'.
	self assert: (editor replayPresenterAt: 'Action seconds' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Delay seconds' ifAbsent: [ nil ]) notNil.

	editor clearReplayPresenterTargets.
	ReplayPressKey new keyPresenterOn: editor.
	self assert: (editor replayPresenterAt: 'Action key' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Press key selector' ifAbsent: [ nil ]) notNil.

	editor clearReplayPresenterTargets.
	ReplayPressKey new repeatCountPresenterOn: editor.
	self assert: (editor replayPresenterAt: 'Action repeat count' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Press key repeat count' ifAbsent: [ nil ]) notNil
]

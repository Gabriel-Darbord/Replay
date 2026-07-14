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
ReplayEditorSemanticTargetTest >> testBrowseTargetsAreRegistered [

	| editor |
	editor := self newEditor.
	ReplayBrowseClass new settingsPresenterOn: editor.
	self assert: (editor replayPresenterAt: 'Browse class target' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Action extent width' ifAbsent: [ nil ]) notNil.

	editor clearReplayPresenterTargets.
	ReplayBrowsePackage new settingsPresenterOn: editor.
	self assert: (editor replayPresenterAt: 'Browse package target' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Action bounds left' ifAbsent: [ nil ]) notNil.

	editor clearReplayPresenterTargets.
	ReplayBrowseMethod new settingsPresenterOn: editor.
	self assert: (editor replayPresenterAt: 'Browse method browser' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Browse method target' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Action clear placement' ifAbsent: [ nil ]) notNil
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testFlagTargetsAreRegistered [

	| editor |
	editor := self newEditor.
	ReplayClick new buttonsPresenterOn: editor.
	self assert: (editor replayPresenterAt: 'Action left click' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Click left click' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Action right click' ifAbsent: [ nil ]) notNil.

	editor clearReplayPresenterTargets.
	ReplayShortcut new modifierPresenterOn: editor.
	self assert: (editor replayPresenterAt: 'Action shift' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Shortcut shift' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Action alt option' ifAbsent: [ nil ]) notNil
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testOpenPlacementDimensionSetters [

	| action |
	action := ReplayOpenPresenter new.
	action extentWidth: 1083.
	action extentHeight: 532.
	self assert: action extent equals: 1083 @ 532.

	action boundsLeft: 10.
	action boundsTop: 20.
	action boundsRight: 300.
	action boundsBottom: 400.
	self assert: action bounds equals: (10 @ 20 corner: 300 @ 400).

	action clearPlacement.
	self assert: action extent isNil.
	self assert: action bounds isNil
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testOpenPlacementTargetsAreRegistered [

	| editor |
	editor := self newEditor.
	ReplayOpenPresenter new settingsPresenterOn: editor.
	self assert: (editor replayPresenterAt: 'Action extent width' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Open Presenter extent width' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Action extent height' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Action bounds left' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Action bounds top' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Action bounds right' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Action bounds bottom' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Action clear placement' ifAbsent: [ nil ]) notNil
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testRecordingStatusShowsShortcut [

	| editor |
	editor := self newEditor.
	self assert: editor recordingShortcutDescription equals: editor recordingShortcut asString.
	self assert: (editor recordingStatusText includesSubstring: editor recordingShortcutDescription).
	self assert: (editor recordingStatusText includesSubstring: 'Record or stop')
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
ReplayEditorSemanticTargetTest >> testScenarioEditorCreatesMacroForCurrentScenarioInRegistry [

	| registry editor scenario macro |
	registry := ReplayMacroRegistry new.
	scenario := ReplayScenario new title: 'Scenario macro'; yourself.
	editor := ReplayEditor on: scenario.
	macro := editor macroForCurrentScenarioIn: registry.

	self assert: macro scenario identicalTo: scenario.
	self assert: macro name equals: 'Scenario macro'.
	self assert: (registry library macros includes: macro)
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

	| editor scenario step typeAction scriptAction |
	scenario := ReplayScenario new.
	step := ReplayStep new.
	typeAction := ReplayType new.
	scriptAction := ReplayScript new.
	step addAction: typeAction.
	step addAction: scriptAction.
	scenario addStep: step.
	editor := ReplayEditor on: scenario.

	editor selectAction: typeAction.
	self assert: (editor replayPresenterAt: 'Action text' ifAbsent: [ nil ]) notNil.
	editor selectAction: scriptAction.
	self assert: (editor replayPresenterAt: 'Action text' ifAbsent: [ #missing ]) equals: #missing.
	self assert: (editor replayPresenterAt: 'Action script' ifAbsent: [ nil ]) notNil
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
ReplayEditorSemanticTargetTest >> testShortcutActionRegistersVisibleKeyEditors [

	| editor action presenter |
	editor := self newEditor.
	action := ReplayShortcut new
		text: (String with: (Character arrowLeft));
		yourself.
	presenter := action shortcutKeysPresenterOn: editor.
	self assert: presenter class equals: ReplayShortcutKeysPresenter.
	self assert: (editor replayPresenterAt: 'Action text' ifAbsent: [ nil ]) identicalTo: presenter.
	self assert: (editor replayPresenterAt: 'Action shortcut key list' ifAbsent: [ nil ]) identicalTo: presenter keyList.
	self assert: (editor replayPresenterAt: 'Shortcut key list' ifAbsent: [ nil ]) identicalTo: presenter keyList
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testSpecificActionFieldTargetsAreRegistered [

	| editor |
	editor := self newEditor.
	ReplayPressKey new keyPresenterOn: editor.
	self assert: (editor replayPresenterAt: 'Action key' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Press key selector' ifAbsent: [ nil ]) notNil.
	editor clearReplayPresenterTargets.
	ReplayPressKey new repeatCountPresenterOn: editor.
	self assert: (editor replayPresenterAt: 'Action repeat count' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Press key repeat count' ifAbsent: [ nil ]) notNil
]

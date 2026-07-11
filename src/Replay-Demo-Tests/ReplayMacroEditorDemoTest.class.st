Class {
	#name : 'ReplayMacroEditorDemoTest',
	#superclass : 'TestCase',
	#category : 'Replay-Demo-Tests',
	#package : 'Replay-Demo-Tests'
}

{ #category : 'tests' }
ReplayMacroEditorDemoTest >> testMacroEditorSemanticTargets [

	| library editor macroEditor |
	library := ReplayMacroLibrary new.
	library addNewMacro.
	editor := ReplayMacroLibraryEditor on: library.
	editor macroList selectIndex: 1.
	macroEditor := editor macroEditorPresenter.

	self assert: (editor replayPresenterAt: 'Macro list' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Macro editor' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Shortcut keys' ifAbsent: [ nil ]) notNil.
	self assert: (editor replayPresenterAt: 'Install macro button' ifAbsent: [ nil ]) notNil.
	self assert: (macroEditor replayPresenterAt: 'Uninstall macro button' ifAbsent: [ nil ]) notNil
]

{ #category : 'tests' }
ReplayMacroEditorDemoTest >> testScenarioStructure [

	| scenario |
	scenario := ReplayMacroEditorDemo scenario.

	self assert: scenario title equals: 'Replay Macro Editor Feature Tour'.
	self assert: scenario steps size equals: 7.
	self assert: (scenario steps anySatisfy: [ :step |
		step actions anySatisfy: [ :action |
			action isKindOf: ReplayAnnotate ] ]).
	self assert: (scenario steps noneSatisfy: [ :step |
		step actions anySatisfy: [ :action |
			action isKindOf: ReplayDelay ] ])
]

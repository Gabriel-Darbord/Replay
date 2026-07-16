Class {
	#name : 'ReplayMacroExistingWindowDemoTest',
	#superclass : 'TestCase',
	#category : 'Replay-Demo-Tests',
	#package : 'Replay-Demo-Tests'
}

{ #category : 'tests' }
ReplayMacroExistingWindowDemoTest >> testScenarioStructure [

	| scenario |
	scenario := ReplayMacroExistingWindowDemo scenario.
	self assert: scenario title equals: 'Replay Macro Existing Window Tour'.
	self assert: scenario steps size equals: 8.
	self assert: (scenario steps anySatisfy: [ :step |
		step actions anySatisfy: [ :action | action isKindOf: ReplayAnnotate ] ]).
	self assert: (scenario steps noneSatisfy: [ :step |
		step actions anySatisfy: [ :action | action isKindOf: ReplayDelay ] ])
]

{ #category : 'tests' }
ReplayMacroExistingWindowDemoTest >> testTriggerMacroUpdatesExistingReplayEditor [

	| demo targetScenario targetEditor targetWindow macroEditor runner macro |
	demo := ReplayMacroExistingWindowDemo new.
	targetScenario := ReplayScenario new title: 'Existing target'; yourself.
	targetScenario addStep: ReplayStep new.
	targetEditor := ReplayEditor on: targetScenario.
	targetWindow := targetEditor asWindow.
	targetWindow open.
	Smalltalk globals at: demo targetEditorKey put: targetEditor.
	macroEditor := ReplayMacroLibraryEditor on: ReplayMacroLibrary new.
	macroEditor addMacro.
	runner := ReplayRunner on: ReplayScenario new.
	runner focus: macroEditor.

	[
		World doOneCycle.
		demo configureMacroAction runOn: runner.
		demo installMacroAction runOn: runner.
		demo triggerInstalledShortcutAction runOn: runner.
		self assert: targetEditor actions items size equals: 1.
		demo updateInstalledShortcutAction runOn: runner.
		demo triggerUpdatedShortcutAction runOn: runner.
		self assert: targetEditor actions items size equals: 2.
		macro := macroEditor macroEditorPresenter macro.
		demo uninstallMacroAction runOn: runner.
		self deny: (macro installedInContextNamed: #RubTextEditor) ]

		ensure: [
			ReplayMacro uninstallAllInstalledKeymaps.
			Smalltalk globals removeKey: demo targetEditorKey ifAbsent: [ ].
			targetWindow close ]
]

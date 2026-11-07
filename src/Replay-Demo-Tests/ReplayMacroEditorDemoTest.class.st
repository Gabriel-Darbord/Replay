"
I test the macro library demo scenario and the actions it runs.
"
Class {
	#name : 'ReplayMacroEditorDemoTest',
	#superclass : 'ReplayMacroTestCase',
	#category : 'Replay-Demo-Tests',
	#package : 'Replay-Demo-Tests'
}

{ #category : 'running' }
ReplayMacroEditorDemoTest >> tearDown [

	[ Smalltalk globals removeKey: #ReplayMacroEditorDemoTriggered ifAbsent: [  ] ] ensure: [
		super tearDown ]
]

{ #category : 'tests' }
ReplayMacroEditorDemoTest >> testAnnotatedTargetsExist [
	"Every target the demo annotates is a semantic name of the library window once a macro is configured"

	| demo editor runner names |
	demo := ReplayMacroEditorDemo new.
	editor := ReplayMacroLibraryEditor on: ReplayMacroLibrary new.
	editor addMacro.
	runner := ReplayRunner on: ReplayScenario new.
	runner focus: editor.
	demo configureFindMacroAction runOn: runner.
	names := (demo scenario steps flatCollect: [ :step | step actions ])
		         select: [ :action | action isKindOf: ReplayAnnotate ]
		         thenCollect: [ :action | action targetName ].

	names do: [ :name |
		self
			assert: (editor replayPresenterAt: name ifAbsent: [ nil ]) notNil
			description: 'Missing demo target: ' , name ]
]

{ #category : 'tests' }
ReplayMacroEditorDemoTest >> testScenarioStructure [

	| scenario |
	scenario := ReplayMacroEditorDemo scenario.
	self assert: scenario title equals: 'Replay Macro Editor Feature Tour'.
	self assert: scenario steps size equals: 9.
	self assert: (scenario steps anySatisfy: [ :step |
		step actions anySatisfy: [ :action | action isKindOf: ReplayAnnotate ] ]).
	self assert: (scenario steps noneSatisfy: [ :step |
		step actions anySatisfy: [ :action | action isKindOf: ReplayDelay ] ])
]

{ #category : 'tests' }
ReplayMacroEditorDemoTest >> testTriggerShortcutActionRunsInstalledMacroPayload [

	| demo editor runner |
	demo := ReplayMacroEditorDemo new.
	editor := ReplayMacroLibraryEditor on: ReplayMacroLibrary new.
	editor addMacro.
	runner := ReplayRunner on: ReplayScenario new.
	runner focus: editor.

	demo configureFindMacroAction runOn: runner.
	self assert: editor selectedMacro name equals: 'Find helper'.
	demo installMacroAction runOn: runner.
	demo triggerInstalledShortcutAction runOn: runner.
	self assert: (Smalltalk globals at: #ReplayMacroEditorDemoTriggered ifAbsent: [ false ])
]

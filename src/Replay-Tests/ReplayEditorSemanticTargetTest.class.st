"
Tests the semantic names of the Replay editor: its own widgets, and the names of the pane shown in its action editor, which follow one scheme for action panes: 'Action <field>'.
"
Class {
	#name : 'ReplayEditorSemanticTargetTest',
	#superclass : 'TestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayEditorSemanticTargetTest >> assertEditor: editor names: names [

	names do: [ :name |
		self
			assert: (editor replayPresenterAt: name ifAbsent: [ nil ]) notNil
			description: name , ' should be registered' ]
]

{ #category : 'support' }
ReplayEditorSemanticTargetTest >> newEditor [

	^ ReplayEditor on: ReplayScenario new
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testActionPanesUseOnlyTheActionScheme [
	"No name of an action pane is built from the name of its action class"

	| editor |
	editor := self newEditor.
	(ReplayAction allSubclasses reject: [ :each | each isAbstract ]) do: [ :actionClass |
		| actionEditor |
		actionEditor := editor editAction: actionClass new.
		(actionEditor instVarNamed: #fields) keysDo: [ :name |
			self assert: (name beginsWith: 'Action ') description: name.
			self deny: (name includesSubstring: actionClass displayName) description: name ] ]
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testBrowseTargetsAreRegistered [

	| editor |
	editor := self newEditor.
	editor editAction: ReplayBrowseClass new.
	self assertEditor: editor names: #( 'Action class' 'Action extent width' ).

	editor editAction: ReplayBrowsePackage new.
	self assertEditor: editor names: #( 'Action package' 'Action bounds left' ).
	self assert: (editor replayPresenterAt: 'Action class' ifAbsent: [ #missing ]) equals: #missing.

	editor editAction: ReplayBrowseMethod new.
	self assertEditor: editor names: #( 'Action method browser' 'Action method' 'Action clear placement' )
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testFlagTargetsAreRegistered [

	| editor |
	editor := self newEditor.
	editor editAction: ReplayClick new.
	self assertEditor: editor names: #( 'Action left button' 'Action right button' 'Action middle button' 'Action shift' 'Action control' 'Action alt option' 'Action command' ).

	editor editAction: ReplayPressKey new.
	self assertEditor: editor names: #( 'Action shift' 'Action alt option' ).
	self assert: (editor replayPresenterAt: 'Action left button' ifAbsent: [ #missing ]) equals: #missing
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testOpenPlacementTargetsAreRegistered [

	| editor |
	editor := self newEditor.
	editor editAction: ReplayOpenPresenter new.
	self assertEditor: editor names: #( 'Action script' 'Action position x' 'Action position y' 'Action extent width' 'Action extent height' 'Action bounds left' 'Action bounds top' 'Action bounds right' 'Action bounds bottom' 'Action clear placement' )
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testRecordingStatusShowsShortcut [

	| editor |
	editor := self newEditor.
	self assert: editor recordingShortcutDescription equals: editor recordingKeyBinding displayString.
	self assert: (editor recordingStatusText includesSubstring: editor recordingShortcutDescription).
	self assert: (editor recordingStatusText includesSubstring: 'to record the active window')
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testScenarioFieldsAreRegistered [

	| editor |
	editor := self newEditor.
	editor editScenarioData.
	self assertEditor: editor names: #( 'Scenario title' 'Scenario description' ).
	editor showHome.
	self assert: (editor replayPresenterAt: 'Scenario title' ifAbsent: [ #missing ]) equals: #missing
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
	self assert: (editor replayPresenterAt: 'Action editor' ifAbsent: [ nil ]) identicalTo: editor actionEditor.
	editor selectAction: scriptAction.
	self assert: (editor replayPresenterAt: 'Action text' ifAbsent: [ #missing ]) equals: #missing.
	self assert: (editor replayPresenterAt: 'Action script' ifAbsent: [ nil ]) notNil
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testSelectionAndTargetNameFieldTargetsAreRegistered [

	| editor |
	editor := self newEditor.
	editor editAction: ReplaySelectText new.
	self assertEditor: editor names: #( 'Action start index' 'Action stop index' 'Action target name' 'Action target world' ).

	editor editAction: ReplayAnnotate new.
	self assertEditor: editor names: #( 'Action target name' 'Action placement' 'Action text' ).
	"Annotate needs a target: it cannot target the World"
	self assert: (editor replayPresenterAt: 'Action target world' ifAbsent: [ #missing ]) equals: #missing
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testSharedActionFieldTargetsAreRegistered [

	| editor |
	editor := self newEditor.
	{ ReplayType new. ReplayInform new. ReplayNavigate new } do: [ :action |
		editor editAction: action.
		self assertEditor: editor names: #( 'Action text' ) ].
	{ ReplayScript new. ReplayPresenterScript new. ReplayAttachUI new. ReplayOpenPresenter new } do: [ :action |
		editor editAction: action.
		self assertEditor: editor names: #( 'Action script' ) ]
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testShortcutActionRegistersVisibleKeyEditors [

	| editor action actionEditor presenter |
	editor := self newEditor.
	action := ReplayShortcut keyBinding: (ReplayKeyBinding character: Character arrowLeft modifiers: 0).
	actionEditor := editor editAction: action.
	presenter := actionEditor keyBindingPresenter.
	self assert: presenter class equals: ReplayKeyBindingPresenter.
	self assert: (editor replayPresenterAt: 'Action key binding' ifAbsent: [ nil ]) identicalTo: presenter.
	self assert: (editor replayPresenterAt: 'Action key list' ifAbsent: [ nil ]) identicalTo: presenter keyList.
	self assert: (editor replayPresenterAt: 'Action capture shortcut button' ifAbsent: [ nil ]) identicalTo: presenter captureShortcutButton.
	self
		assert: (editor replayPresenterAt: 'Action command' ifAbsent: [ nil ])
		identicalTo: presenter modifiersPresenter commandCheckBox.
	self
		assert: (editor replayPresenterAt: 'Action alt option' ifAbsent: [ nil ])
		identicalTo: presenter modifiersPresenter altCheckBox.
	self assert: (editor replayPresenterAt: 'Action keymap list' ifAbsent: [ nil ]) notNil
]

{ #category : 'tests' }
ReplayEditorSemanticTargetTest >> testSpecificActionFieldTargetsAreRegistered [

	| editor |
	editor := self newEditor.
	editor editAction: ReplayPressKey new.
	self assertEditor: editor names: #( 'Action key' 'Action count' ).
	editor editAction: ReplayScroll new.
	self assertEditor: editor names: #( 'Action direction' 'Action count' 'Action x' 'Action y' ).
	editor editAction: ReplayDeleteText new.
	self assertEditor: editor names: #( 'Action direction' 'Action count' ).
	editor editAction: ReplayDrag new.
	self assertEditor: editor names: #( 'Action start x' 'Action start y' 'Action end x' 'Action end y' 'Action steps' ).
	editor editAction: ReplayClick new.
	self assertEditor: editor names: #( 'Action phase' 'Action x' 'Action y' 'Action count' ).
	editor editAction: ReplayDelay new.
	self assertEditor: editor names: #( 'Action seconds' )
]

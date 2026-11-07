"
I test editing a scenario with ReplayEditor: the current step and action follow the list selections, adding with the action chooser and the + button, removing actions and steps, the panes of the action editor, and the shortcut captures that must not outlive the pane that shows them.
"
Class {
	#name : 'ReplayEditorTest',
	#superclass : 'ReplayTestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayEditorTest >> scenarioWithSteps: actionLists [

	| scenario |
	scenario := ReplayScenario new.
	actionLists do: [ :actions |
		| step |
		step := ReplayStep new.
		actions do: [ :action | step addAction: action ].
		scenario addStep: step ].
	^ scenario
]

{ #category : 'tests' }
ReplayEditorTest >> testAddActionAfterAnActionOutsideTheStepAddsLast [

	| first editor added |
	first := ReplayClick new.
	editor := ReplayEditor on: (self scenarioWithSteps: { { first } }).
	added := ReplayType new.
	editor addAction: added after: nil.

	self assert: editor currentStep actions asArray equals: { first. added }.
	self assert: editor currentAction identicalTo: added
]

{ #category : 'tests' }
ReplayEditorTest >> testCaptureIsCancelledByEscape [

	| hand presenter binding |
	hand := HandMorph new.
	binding := ReplayKeyBinding character: $k modifiers: 0.
	presenter := ReplayKeyBindingPresenter on: binding.
	presenter hand: hand.
	presenter open.
	presenter startShortcutCapture.
	self press: (ReplayKeyBinding chords: { ReplayKeyChord namedKey: #escape }) on: hand.

	self assert: presenter captureListener isNil.
	self assert: hand eventListeners isEmptyOrNil.
	self assert: presenter keyBinding equals: binding.
	self assert: presenter captureShortcutButton label equals: 'Capture shortcut'.

	presenter startShortcutCapture.
	self press: (ReplayKeyBinding character: $j modifiers: 0) on: hand.
	self assert: presenter keyBinding equals: (ReplayKeyBinding character: $j modifiers: 0)
]

{ #category : 'tests' }
ReplayEditorTest >> testCaptureOfAHiddenPresenterCapturesNothing [

	| hand presenter binding |
	hand := HandMorph new.
	binding := ReplayKeyBinding character: $k modifiers: 0.
	presenter := ReplayKeyBindingPresenter on: binding.
	presenter hand: hand.
	presenter startShortcutCapture.
	self assert: (hand eventListeners includes: presenter captureListener).
	self press: (ReplayKeyBinding character: $j modifiers: 0) on: hand.

	self assert: presenter keyBinding equals: binding.
	self assert: presenter captureListener isNil.
	self assert: hand eventListeners isEmptyOrNil
]

{ #category : 'tests' }
ReplayEditorTest >> testCaptureStopsWhenTheMacroSettingsAreReplacedOrTheWindowCloses [

	| hand macro editor keys |
	hand := HandMorph new.
	macro := ReplayMacro
		         scenario: ReplayScenario new
		         keyBinding: (ReplayKeyBinding character: $k modifiers: 0).
	editor := ReplayEditor
		          onMacro: macro
		          inLibrary: (ReplayMacroLibrary new
				           addMacro: macro;
				           yourself).
	editor open.
	editor editShortcut.
	keys := editor macroEditor keyBindingPresenter.
	keys hand: hand.

	keys startShortcutCapture.
	self assert: keys captureShortcutButton label equals: 'Listening...'.
	editor editScenarioData.
	self assert: keys captureListener isNil.
	self assert: hand eventListeners isEmptyOrNil.
	self assert: keys captureShortcutButton label equals: 'Capture shortcut'.

	editor editShortcut.
	keys startShortcutCapture.
	editor window close.
	self assert: keys captureListener isNil.
	self assert: hand eventListeners isEmptyOrNil.
	self assert: macro keyBinding equals: (ReplayKeyBinding character: $k modifiers: 0)
]

{ #category : 'tests' }
ReplayEditorTest >> testChooserPicksTheKindOfActionThatPlusAdds [

	| editor chooser |
	editor := ReplayEditor new.
	chooser := editor replayPresenterAt: 'Action chooser' ifAbsent: [ nil ].
	chooser selectItem: ReplayClick.
	chooser selectItem: ReplayType.
	chooser selectItem: ReplayClick.
	self assert: editor currentStep actions isEmpty.

	editor actions addButton click.
	editor actions addButton click.
	self assert: (editor currentStep actions collect: [ :action | action class ]) asArray equals: { ReplayClick. ReplayClick }.
	self assert: editor actions items asArray equals: editor currentStep actions asArray.
	self assert: editor currentAction identicalTo: editor currentStep actions last
]

{ #category : 'tests' }
ReplayEditorTest >> testCurrentStepAndActionAreTheSelections [

	| click type editor |
	click := ReplayClick new.
	type := ReplayType new.
	editor := ReplayEditor on: (self scenarioWithSteps: { { click }. { type } }).

	self assert: editor currentStep identicalTo: editor scenario steps first.
	self assert: editor currentAction identicalTo: click.
	editor steps selectIndex: 2.
	self assert: editor currentStep identicalTo: editor scenario steps second.
	self assert: editor currentAction identicalTo: type
]

{ #category : 'tests' }
ReplayEditorTest >> testDeletingTheLastStepShowsNoActionAndDisablesStepTools [

	| type editor |
	type := ReplayType new.
	editor := ReplayEditor on: (self scenarioWithSteps: { { type } }).
	self assert: (editor replayPresenterAt: 'Action text' ifAbsent: [ nil ]) notNil.
	editor removeStep: editor currentStep.

	self assert: editor scenario steps isEmpty.
	self assert: editor currentStep isNil.
	self assert: editor currentAction isNil.
	self assert: editor actions items isEmpty.
	self assert: (editor replayPresenterAt: 'Action text' ifAbsent: [ #missing ]) equals: #missing.
	self shouldnt: [ editor editStepNavigation ] raise: Error.
	self shouldnt: [ editor runStep ] raise: Error.

	"Adding an action makes a step again"
	editor addActionLast: ReplayClick new.
	self assert: editor scenario steps size equals: 1.
	self assert: editor currentStep identicalTo: editor scenario steps first
]

{ #category : 'tests' }
ReplayEditorTest >> testEmbeddedEditorFindsMacroSettingsOnlyWhileShown [

	| macro editor |
	macro := ReplayMacro scenario: ReplayScenario new keyBinding: ReplayKeyBinding new.
	editor := ReplayEditor
		          onMacro: macro
		          inLibrary: (ReplayMacroLibrary new
				           addMacro: macro;
				           yourself).

	self assert: (editor replayPresenterAt: 'Key binding' ifAbsent: [ #missing ]) equals: #missing.
	editor editShortcut.
	self assert: (editor replayPresenterAt: 'Key binding' ifAbsent: [ nil ]) identicalTo: editor macroEditor keyBindingPresenter.
	editor editScenarioData.
	self assert: (editor replayPresenterAt: 'Key binding' ifAbsent: [ #missing ]) equals: #missing
]

{ #category : 'tests' }
ReplayEditorTest >> testOtherPanesUnselectTheActionSoItCanBeShownAgain [

	| type editor |
	type := ReplayType new.
	editor := ReplayEditor on: (self scenarioWithSteps: { { type } }).

	#( #editScenarioData #editStepNavigation ) do: [ :selector |
		editor perform: selector.
		self assert: editor currentAction isNil.
		self assert: (editor replayPresenterAt: 'Type text' ifAbsent: [ #missing ]) equals: #missing.
		editor actions selectItem: type.
		self assert: (editor replayPresenterAt: 'Type text' ifAbsent: [ nil ]) notNil ]
]

{ #category : 'tests' }
ReplayEditorTest >> testRemoveButtonWithoutSelectionRemovesNothing [

	| click editor |
	click := ReplayClick new.
	editor := ReplayEditor on: (self scenarioWithSteps: { { click } }).
	editor actions selectIndex: 0.

	self shouldnt: [ editor actions removeButton click ] raise: Error.
	self assert: editor currentStep actions asArray equals: { click }
]

{ #category : 'tests' }
ReplayEditorTest >> testRemovingAStepSelectsTheNextOneAndItsFirstAction [

	| click type editor |
	click := ReplayClick new.
	type := ReplayType new.
	editor := ReplayEditor on: (self scenarioWithSteps: { { click }. { type } }).
	editor removeStep: editor currentStep.

	self assert: editor scenario steps size equals: 1.
	self assert: editor currentStep identicalTo: editor scenario steps first.
	self assert: editor currentAction identicalTo: type.
	editor actions removeButton click.
	self assert: editor currentStep actions isEmpty.
	self assert: editor currentAction isNil
]

{ #category : 'tests' }
ReplayEditorTest >> testRemovingAnActionSelectsTheNextOne [

	| first second third editor |
	first := ReplayClick new.
	second := ReplayType new.
	third := ReplayDelay new.
	editor := ReplayEditor on: (self scenarioWithSteps: { { first. second. third } }).
	editor actions selectItem: second.
	editor removeAction: second.
	self assert: editor currentAction identicalTo: third.
	editor removeAction: third.
	self assert: editor currentAction identicalTo: first.
	self assert: editor actions items asArray equals: { first }
]

{ #category : 'tests' }
ReplayEditorTest >> testSettingsEditsRefreshTheActionLabel [

	| type editor |
	type := ReplayType new text: 'a'; yourself.
	editor := ReplayEditor on: (self scenarioWithSteps: { { type } }).
	editor open.
	type text: 'abc'.
	editor actionChanged: type.

	self assert: editor currentAction identicalTo: type.
	self assert: editor actions items asArray equals: { type }
]

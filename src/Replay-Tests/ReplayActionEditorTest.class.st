"
Tests for the action editors (ReplayActionEditor and its subclasses), one test per family: each builds, registers its fields under 'Action <field>', edits its action, and notifies the scenario editor exactly once per change.
"
Class {
	#name : 'ReplayActionEditorTest',
	#superclass : 'ReplayTestCase',
	#instVars : [
		'editor'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayActionEditorTest >> assert: aBlock notifies: anAction [
	"Evaluate aBlock, an edit, which must notify the editor once, for anAction"

	| before |
	before := editor changedActions size.
	aBlock value.
	self assert: editor changedActions size equals: before + 1.
	self assert: editor changedActions last identicalTo: anAction
]

{ #category : 'support' }
ReplayActionEditorTest >> edit: anAction [
	"Show the editor of anAction, in a scenario that has it"

	| step scenario |
	step := ReplayStep new.
	step addAction: anAction.
	scenario := ReplayScenario new.
	scenario addStep: step.
	editor := ReplayEditorSpy on: scenario.
	^ editor editAction: anAction
]

{ #category : 'support' }
ReplayActionEditorTest >> field: aName [

	^ editor replayPresenterAt: aName ifAbsent: [ self fail: aName , ' is not registered' ]
]

{ #category : 'support' }
ReplayActionEditorTest >> fieldNames [

	^ (editor actionEditor instVarNamed: #fields) keys asSet
]

{ #category : 'tests' }
ReplayActionEditorTest >> testActionWithoutSettingsShowsANotice [

	self edit: ReplayCloseUI new.

	self assert: self fieldNames isEmpty.
	self assert: editor actionEditor class equals: ReplayActionEditor.
	self assert: (editor actionEditor layout children first isKindOf: SpBoxLayout)
]

{ #category : 'tests' }
ReplayActionEditorTest >> testAnnotateEditor [

	| action |
	action := ReplayAnnotate new.
	self edit: action.

	self assert: self fieldNames equals: #( 'Action target name' 'Action placement' 'Action text' ) asSet.
	self assert: [ (self field: 'Action placement') selectItem: (ReplayAnnotate placementChoices detect: [ :each | each key = #below ]) ] notifies: action.
	self assert: action placement equals: #below.
	self assert: [ (self field: 'Action text') text: 'Note' ] notifies: action.
	self assert: action text equals: 'Note'
]

{ #category : 'tests' }
ReplayActionEditorTest >> testBrowseEditors [

	| action |
	action := ReplayBrowseClass new.
	self edit: action.
	self assert: (self fieldNames includes: 'Action class').
	self assert: [ (self field: 'Action class') selectItem: ReplayStep ] notifies: action.
	self assert: action targetClass equals: ReplayStep.
	self assert: editor actionEditor settingsViewName equals: 'Select class'.

	action := ReplayBrowsePackage new.
	self edit: action.
	self assert: [ (self field: 'Action package') selectItem: ReplayStep package ] notifies: action.
	self assert: action targetPackage equals: ReplayStep package.

	action := ReplayBrowseMethod new.
	self edit: action.
	self assert: (self fieldNames includesAll: #( 'Action method browser' 'Action method' 'Action extent width' ))
]

{ #category : 'tests' }
ReplayActionEditorTest >> testClickEditor [

	| action |
	action := ReplayClick new.
	self edit: action.

	self
		assert: self fieldNames
		equals: #( 'Action target name' 'Action target world' 'Action phase' 'Action left button' 'Action right button' 'Action middle button' 'Action shift' 'Action control' 'Action alt option' 'Action command' 'Action x' 'Action y' 'Action count' ) asSet.
	self assert: [ (self field: 'Action phase') selectItem: (ReplayClick mousePhaseChoices detect: [ :each | each key = #down ]) ] notifies: action.
	self assert: action mousePhase equals: #down.
	self assert: [ (self field: 'Action right button') state: true ] notifies: action.
	self assert: action buttons equals: (MouseEvent redButton bitOr: MouseEvent yellowButton).
	self assert: [ (self field: 'Action x') number: 5 ] notifies: action.
	self assert: [ (self field: 'Action y') number: 7 ] notifies: action.
	self assert: action position equals: 5 @ 7.
	self assert: [ (self field: 'Action count') number: 2 ] notifies: action.
	self assert: action clickCount equals: 2
]

{ #category : 'tests' }
ReplayActionEditorTest >> testDelayEditor [

	| action |
	action := ReplayDelay new.
	self edit: action.

	self assert: self fieldNames equals: #( 'Action seconds' ) asSet.
	self assert: [ (self field: 'Action seconds') number: 2.5 ] notifies: action.
	self assert: action seconds equals: 2.5
]

{ #category : 'tests' }
ReplayActionEditorTest >> testDeleteTextEditor [

	| action |
	action := ReplayDeleteText new.
	self edit: action.

	self assert: self fieldNames equals: #( 'Action target name' 'Action target world' 'Action direction' 'Action count' ) asSet.
	self assert: [ (self field: 'Action direction') selectItem: ReplayDeleteText directionChoices last ] notifies: action.
	self assert: action direction equals: #forward.
	self assert: [ (self field: 'Action count') number: 3 ] notifies: action.
	self assert: action count equals: 3
]

{ #category : 'tests' }
ReplayActionEditorTest >> testDragEditsXThenYKeepsBothEdits [

	| action |
	action := ReplayDrag new.
	self edit: action.

	self assert: [ (self field: 'Action start x') number: 3 ] notifies: action.
	self assert: [ (self field: 'Action start y') number: 4 ] notifies: action.
	self assert: [ (self field: 'Action end x') number: 30 ] notifies: action.
	self assert: [ (self field: 'Action end y') number: 40 ] notifies: action.

	self assert: action startPosition equals: 3 @ 4.
	self assert: action endPosition equals: 30 @ 40
]

{ #category : 'tests' }
ReplayActionEditorTest >> testDragEditor [

	| action |
	action := ReplayDrag new.
	self edit: action.

	self
		assert: self fieldNames
		equals: #( 'Action target name' 'Action target world' 'Action left button' 'Action right button' 'Action middle button' 'Action shift' 'Action control' 'Action alt option' 'Action command' 'Action start x' 'Action start y' 'Action end x' 'Action end y' 'Action steps' ) asSet.
	self assert: [ (self field: 'Action steps') number: 4 ] notifies: action.
	self assert: action steps equals: 4.
	self assert: [ (self field: 'Action left button') state: false ] notifies: action.
	self assert: action buttons equals: 0
]

{ #category : 'tests' }
ReplayActionEditorTest >> testInformEditor [

	| action |
	action := ReplayInform new.
	self edit: action.

	self assert: self fieldNames equals: #( 'Action text' ) asSet.
	self assert: [ (self field: 'Action text') text: 'Hello' ] notifies: action.
	self assert: action text equals: 'Hello'
]

{ #category : 'tests' }
ReplayActionEditorTest >> testModifierCheckBoxesNotifyTheEditor [
	"Pointer actions show their new modifiers in the action list too"

	{ ReplayClick new. ReplayDrag new. ReplayScroll new. ReplayPressKey new } do: [ :action |
		self edit: action.
		self assert: [ (self field: 'Action shift') state: true ] notifies: action.
		self assert: [ (self field: 'Action command') state: true ] notifies: action.
		self assert: action modifiers equals: (ReplayKeyModifiers shift bitOr: ReplayKeyModifiers command) ]
]

{ #category : 'tests' }
ReplayActionEditorTest >> testNavigateEditor [

	| action |
	action := ReplayNavigate new.
	self edit: action.
	self assert: action isDefault.

	self assert: (self fieldNames includesAll: #( 'Action skip' 'Action accept label' 'Action cancel label' 'Action text' 'Action extent width' 'Action clear placement' )).
	self assert: [ (self field: 'Action skip') state: false ] notifies: action.
	self deny: action skip.
	self assert: [ (self field: 'Action accept label') text: 'Go' ] notifies: action.
	self assert: action acceptLabel equals: 'Go'.
	self assert: [ (self field: 'Action extent width') number: 500 ] notifies: action.
	self assert: action placement extent x equals: 500.
	self assert: [ (self field: 'Action clear placement') click ] notifies: action.
	self assert: action placement isNil
]

{ #category : 'tests' }
ReplayActionEditorTest >> testOpenPresenterEditor [

	| action |
	action := ReplayOpenPresenter new.
	self edit: action.

	self assert: [ (self field: 'Action script') text: 'SpPresenter new' ] notifies: action.
	self assert: action script equals: 'SpPresenter new'.
	self assert: [ (self field: 'Action position x') number: 10 ] notifies: action.
	self assert: [ (self field: 'Action position y') number: 20 ] notifies: action.
	self assert: action placement position equals: 10 @ 20
]

{ #category : 'tests' }
ReplayActionEditorTest >> testPlacementEditsACopy [
	"A placement is a value: editing it sets a new one"

	| action placement |
	placement := ReplayPlacement position: 1 @ 2.
	action := ReplayOpenPresenter new placement: placement; yourself.
	self edit: action.

	(self field: 'Action extent width') number: 300.

	self assert: placement equals: (ReplayPlacement position: 1 @ 2).
	self assert: action placement equals: (ReplayPlacement position: 1 @ 2 extent: 300 @ 400)
]

{ #category : 'tests' }
ReplayActionEditorTest >> testPressKeyEditor [

	| action |
	action := ReplayPressKey new.
	self edit: action.

	self
		assert: self fieldNames
		equals: #( 'Action target name' 'Action target world' 'Action key' 'Action shift' 'Action control' 'Action alt option' 'Action command' 'Action count' ) asSet.
	self assert: [ (self field: 'Action key') selectItem: (ReplayPressKey keyChoices detect: [ :each | each key = #right ]) ] notifies: action.
	self assert: action keySelector equals: #right.
	self assert: [ (self field: 'Action count') number: 3 ] notifies: action.
	self assert: action repeatCount equals: 3
]

{ #category : 'tests' }
ReplayActionEditorTest >> testScriptEditors [

	{ ReplayScript new. ReplayPresenterScript new. ReplayAttachUI new } do: [ :action |
		self edit: action.
		self assert: self fieldNames equals: #( 'Action script' ) asSet.
		self assert: [ (self field: 'Action script') text: '1 + 2' ] notifies: action.
		self assert: action script equals: '1 + 2' ]
]

{ #category : 'tests' }
ReplayActionEditorTest >> testScrollEditor [

	| action |
	action := ReplayScroll new.
	self edit: action.

	self
		assert: self fieldNames
		equals: #( 'Action target name' 'Action target world' 'Action direction' 'Action count' 'Action shift' 'Action control' 'Action alt option' 'Action command' 'Action x' 'Action y' ) asSet.
	self assert: [ (self field: 'Action direction') selectItem: ReplayScroll directionChoices first ] notifies: action.
	self assert: action direction equals: #up.
	self assert: [ (self field: 'Action count') number: 4 ] notifies: action.
	self assert: action count equals: 4.
	self assert: [ (self field: 'Action y') number: 9 ] notifies: action.
	self assert: action position equals: 0 @ 9
]

{ #category : 'tests' }
ReplayActionEditorTest >> testSelectTextEditor [

	| action |
	action := ReplaySelectText new.
	self edit: action.

	self assert: self fieldNames equals: #( 'Action target name' 'Action target world' 'Action start index' 'Action stop index' ) asSet.
	self assert: [ (self field: 'Action start index') number: 2 ] notifies: action.
	self assert: [ (self field: 'Action stop index') number: 5 ] notifies: action.
	self assert: action selectionInterval equals: (2 to: 5)
]

{ #category : 'tests' }
ReplayActionEditorTest >> testShortcutEditor [

	| action binding |
	action := ReplayShortcut keyBinding: (ReplayKeyBinding character: $k modifiers: 0).
	self edit: action.

	self assert: [ (self field: 'Action clear keys button') click ] notifies: action.
	self assert: action keyBinding chords isEmpty.

	binding := ReplayKeyBinding character: $j modifiers: ReplayKeyModifiers control.
	self assert: [ editor actionEditor keyBindingPresenter keyBinding: binding ] notifies: action.
	self assert: action keyBinding equals: binding
]

{ #category : 'tests' }
ReplayActionEditorTest >> testTargetNameIsCommittedOnAccept [
	"Typing a name does not wipe a recorded path: accepting it does"

	| action path |
	path := ReplayUIReference morphicPath: #( 1 2 ).
	action := ReplayFocus target: path.
	self edit: action.

	(self field: 'Action target name') text: 'Field'.
	self assert: action target equals: path.

	self assert: [ editor actionEditor acceptTargetName ] notifies: action.
	self assert: action target equals: (ReplayUIReference named: 'Field').

	(self field: 'Action target name') text: ''.
	self assert: [ editor actionEditor acceptTargetName ] notifies: action.
	self assert: action target isWorld
]

{ #category : 'tests' }
ReplayActionEditorTest >> testTargetWorldButton [

	| action |
	action := ReplayType target: (ReplayUIReference named: 'Field').
	self edit: action.
	self assert: (self field: 'Action target name') text equals: 'Field'.

	self assert: [ (self field: 'Action target world') click ] notifies: action.

	self assert: action target isWorld.
	self assert: (self field: 'Action target name') text isEmpty
]

{ #category : 'tests' }
ReplayActionEditorTest >> testTypeEditor [

	| action |
	action := ReplayType new.
	self edit: action.

	self assert: self fieldNames equals: #( 'Action target name' 'Action target world' 'Action text' ) asSet.
	self assert: [ (self field: 'Action text') text: 'abc' ] notifies: action.
	self assert: action text equals: 'abc'
]

{ #category : 'tests' }
ReplayActionEditorTest >> testViewsRegisterTheirOwnNames [
	"The names of the settings are forgotten while the UI view is shown"

	| action switcher |
	action := ReplayType new.
	self edit: action.
	switcher := editor actionEditor viewSwitcher.

	switcher switcher children second state: true.
	self assert: (editor replayPresenterAt: 'Action text' ifAbsent: [ #missing ]) equals: #missing.
	switcher switcher children first state: true.
	self assert: (editor replayPresenterAt: 'Action text' ifAbsent: [ nil ]) isNotNil
]

"
I test the recording of the scenario editor (ReplayEditor): what it records, how the recorded actions reach the current step, and the recording key binding toggled by the ReplayRecordingToggleListener shared by all editors.

My editors work with a hand of their own, which is not the hand of the World: the listeners they install stay off the real hand, and I press keys for them with press:on:.
"
Class {
	#name : 'ReplayEditorRecordingTest',
	#superclass : 'ReplayTestCase',
	#instVars : [
		'hand',
		'targetFocus'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayEditorRecordingTest >> openEditor [

	| editor |
	editor := ReplayEditor new
		          hand: hand;
		          yourself.
	editor open.
	^ editor
]

{ #category : 'support' }
ReplayEditorRecordingTest >> openTarget [
	"A window to record, with a morph that takes the keyboard focus"

	| root |
	root := Morph new extent: 200 @ 100.
	root addMorph: (targetFocus := Morph new bounds: (20 @ 10 extent: 50 @ 30)).
	^ root openInWindowLabeled: 'Replay recording target'
]

{ #category : 'support' }
ReplayEditorRecordingTest >> recordingKeyBinding [

	^ ReplayEditor recordingKeyBinding
]

{ #category : 'running' }
ReplayEditorRecordingTest >> setUp [

	super setUp.
	hand := HandMorph new
]

{ #category : 'running' }
ReplayEditorRecordingTest >> tearDown [

	[ super tearDown ] ensure: [ ReplayRecordingToggleListener listeners removeKey: hand ifAbsent: [  ] ]
]

{ #category : 'support' }
ReplayEditorRecordingTest >> toggleListeners [
	"The recording toggle listeners on my hand"

	^ (hand eventListeners ifNil: [ #(  ) ]) select: [ :each | each isKindOf: ReplayRecordingToggleListener ]
]

{ #category : 'tests' }
ReplayEditorRecordingTest >> testAppendsRecordedActionsToCurrentStep [

	| editor click type |
	editor := ReplayEditor new.
	click := ReplayClick new.
	type := ReplayType new text: 'abc'; yourself.
	editor addRecordedActions: { click. type }.

	self assert: editor currentStep actions asArray equals: { click. type }.
	self assert: editor actionList items asArray equals: { click. type }.
	self assert: editor currentAction identicalTo: type
]

{ #category : 'tests' }
ReplayEditorRecordingTest >> testClosingTheWindowStopsRecordingAndListening [

	| editor |
	self openTarget.
	editor := self openEditor.
	editor startRecording.
	editor recorder recordAction: ReplayClick new.
	editor window close.

	self deny: editor isRecording.
	self assert: (editor scenario steps first actions collect: [ :action | action class ]) asArray
		equals: { ReplayAttachActiveWindow. ReplayClick }.
	self assert: self toggleListeners isEmpty.
	self assert: hand eventListeners isEmptyOrNil
]

{ #category : 'tests' }
ReplayEditorRecordingTest >> testOneListenerForAllEditors [

	| first second |
	first := self openEditor.
	second := self openEditor.

	self assert: self toggleListeners size equals: 1.
	self assert: self toggleListeners first editors asArray equals: { first. second }.
	first window close.
	self assert: self toggleListeners size equals: 1.
	second window close.
	self assert: self toggleListeners isEmpty.
	self assert: (ReplayRecordingToggleListener onHand: hand) isNil
]

{ #category : 'tests' }
ReplayEditorRecordingTest >> testRecordButtonRecordsTheWindowUsedLastNeverTheEditor [

	| target editor recorded |
	target := self openTarget.
	editor := self openEditor.
	"The editor window is in front, and has the keyboard focus"
	hand keyboardFocus: editor windowMorph submorphs first.
	editor startRecording.

	self assert: editor recorder manager managedUI identicalTo: target.
	self assert: editor recorder manager overlay isNil.
	self assert: (editor recordingStatusText includesSubstring: 'Replay recording target').
	editor recorder recordAction: ReplayClick new.
	recorded := editor stopRecording.
	self assert: recorded first class equals: ReplayAttachActiveWindow
]

{ #category : 'tests' }
ReplayEditorRecordingTest >> testRecordingTheWorldBeginsWithAttachWorldAndIgnoresTheEditor [

	| editor recorded |
	editor := self openEditor.
	editor startRecordingOn: self currentWorld.

	self assert: editor recorder manager managedUI identicalTo: self currentWorld.
	self assert: editor recorder manager overlay isNil.
	self assert: (editor recorder ignoresMorph: editor windowMorph).
	self assert: (editor recordingStatusText includesSubstring: 'Recording the World').
	editor recorder recordAction: ReplayClick new.
	recorded := editor stopRecording.
	self assert: recorded first class equals: ReplayAttachWorld.
	self assert: editor currentStep actions first class equals: ReplayAttachWorld
]

{ #category : 'tests' }
ReplayEditorRecordingTest >> testShortcutRecordsTheFocusedWindowWithoutRecordingItself [

	| target editor |
	target := self openTarget.
	editor := self openEditor.
	hand keyboardFocus: targetFocus.

	self press: self recordingKeyBinding on: hand.
	self assert: editor isRecording.
	self assert: editor recorder manager managedUI identicalTo: target.
	self press: (ReplayKeyBinding character: $a modifiers: 0) on: hand.
	self press: self recordingKeyBinding on: hand.

	self deny: editor isRecording.
	self assert: (editor currentStep actions collect: [ :action | action class ]) asArray
		equals: { ReplayAttachActiveWindow. ReplayType }.
	self assert: editor currentStep actions last text equals: 'a'
]

{ #category : 'tests' }
ReplayEditorRecordingTest >> testShortcutStartsOneEditorAndStopsTheRecordingOne [

	| first second |
	self openTarget.
	first := self openEditor.
	second := self openEditor.

	"Without focus in an editor, the frontmost one records"
	self press: self recordingKeyBinding on: hand.
	self assert: second isRecording.
	self deny: first isRecording.

	"The recording editor stops, whatever the focus"
	hand keyboardFocus: first windowMorph submorphs first.
	self press: self recordingKeyBinding on: hand.
	self deny: second isRecording.
	self deny: first isRecording.

	"The editor of the focused window records"
	self press: self recordingKeyBinding on: hand.
	self assert: first isRecording.
	self deny: second isRecording
]

{ #category : 'tests' }
ReplayEditorRecordingTest >> testToggleListenerIgnoresMouseEventsAndOtherKeys [

	| editor |
	self openTarget.
	editor := self openEditor.
	self
		dispatch: (MouseButtonEvent new
				 setType: #mouseDown
				 position: 10 @ 10
				 which: MouseEvent redButton
				 buttons: MouseEvent redButton
				 hand: hand
				 stamp: Time millisecondClockValue)
		toListenersOf: hand.
	self press: (ReplayKeyBinding character: $r modifiers: 0) on: hand.
	self press: (ReplayKeyBinding character: $t modifiers: ReplayKeyModifiers command) on: hand.

	self deny: editor isRecording
]

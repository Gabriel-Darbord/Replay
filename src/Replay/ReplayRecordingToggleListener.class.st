"
I toggle scenario recording when the recording key binding of ReplayEditor (Cmd + R) is pressed, wherever the keyboard focus is.

There is one of me per hand, shared by every editor shown on that hand: editors register: when their window opens and unregister: when it closes, and I am on the hand while at least one editor is registered. On the recording key binding, I stop the editor that is recording; when none is, I start the editor of the focused window, or else the editor whose window is the frontmost (the most recently used).
"
Class {
	#name : 'ReplayRecordingToggleListener',
	#superclass : 'Object',
	#instVars : [
		'hand',
		'editors'
	],
	#classInstVars : [
		'listeners'
	],
	#category : 'Replay-Recording',
	#package : 'Replay',
	#tag : 'Recording'
}

{ #category : 'accessing' }
ReplayRecordingToggleListener class >> listeners [
	"My instances, by the hand they listen to"

	^ listeners ifNil: [ listeners := IdentityDictionary new ]
]

{ #category : 'accessing' }
ReplayRecordingToggleListener class >> onHand: aHandMorph [
	"The listener installed on aHandMorph, or nil"

	^ self listeners at: aHandMorph ifAbsent: [ nil ]
]

{ #category : 'registering' }
ReplayRecordingToggleListener class >> register: aReplayEditor [
	"Toggle the recording of aReplayEditor from its hand"

	(self listeners at: aReplayEditor hand ifAbsentPut: [ self new setHand: aReplayEditor hand ]) add: aReplayEditor
]

{ #category : 'registering' }
ReplayRecordingToggleListener class >> unregister: aReplayEditor [
	"Uninstall the listeners left without editor"

	self listeners copy keysAndValuesDo: [ :aHand :listener |
		listener remove: aReplayEditor.
		listener editors ifEmpty: [
			listener uninstall.
			self listeners removeKey: aHand ] ]
]

{ #category : 'registering' }
ReplayRecordingToggleListener >> add: aReplayEditor [

	editors ifEmpty: [ hand addEventListener: self ].
	(editors includes: aReplayEditor) ifFalse: [ editors add: aReplayEditor ]
]

{ #category : 'accessing' }
ReplayRecordingToggleListener >> editorToStart [
	"The editor of the focused window, or else the one whose window is the frontmost"

	| focusWindow shown |
	focusWindow := hand keyboardFocus ifNotNil: [ :focus | focus ownerThatIsA: SystemWindow ].
	shown := editors select: [ :editor | editor windowMorph isNotNil ].
	shown ifEmpty: [ ^ nil ].
	focusWindow ifNotNil: [
		shown
			detect: [ :editor | editor windowMorph == focusWindow ]
			ifFound: [ :editor | ^ editor ] ].
	^ shown detectMin: [ :editor | self stackingIndexOf: editor windowMorph ]
]

{ #category : 'accessing' }
ReplayRecordingToggleListener >> editors [

	^ editors
]

{ #category : 'event handling' }
ReplayRecordingToggleListener >> handleListenEvent: anEvent [

	anEvent isKeyboard ifFalse: [ ^ self ].
	anEvent isKeyDown ifFalse: [ ^ self ].
	(ReplayKeyBinding fromKeyboardEvent: anEvent) = ReplayEditor recordingKeyBinding ifFalse: [ ^ self ].
	self toggleRecording
]

{ #category : 'accessing' }
ReplayRecordingToggleListener >> hand [

	^ hand
]

{ #category : 'initialization' }
ReplayRecordingToggleListener >> initialize [

	super initialize.
	editors := OrderedCollection new
]

{ #category : 'registering' }
ReplayRecordingToggleListener >> remove: aReplayEditor [

	editors remove: aReplayEditor ifAbsent: [  ]
]

{ #category : 'initialization' }
ReplayRecordingToggleListener >> setHand: aHandMorph [

	hand := aHandMorph
]

{ #category : 'accessing' }
ReplayRecordingToggleListener >> stackingIndexOf: aWindow [
	"The frontmost window of the world comes first"

	^ aWindow owner
		  ifNil: [ Float infinity ]
		  ifNotNil: [ :world | world submorphs indexOf: aWindow ifAbsent: [ Float infinity ] ]
]

{ #category : 'event handling' }
ReplayRecordingToggleListener >> toggleRecording [

	editors
		detect: [ :editor | editor isRecording ]
		ifFound: [ :editor | ^ editor stopRecording ].
	self editorToStart ifNotNil: [ :editor | editor startRecording ]
]

{ #category : 'registering' }
ReplayRecordingToggleListener >> uninstall [

	hand removeEventListener: self
]

"
I press a named keyboard key (see ReplayKeyChord class>>namedKeys), optionally repeated and with modifiers (a ReplayKeyModifiers mask).

Like a real keyboard, each press sends a key down event, a keystroke event when the key types text (Space without shortcut modifier), and a key up event. Morphic and Rubric act on the key down of the keys that type no text: a keystroke for them would insert a control character.
"
Class {
	#name : 'ReplayPressKey',
	#superclass : 'ReplayKeyboardEvent',
	#instVars : [
		'keySelector',
		'repeatCount',
		'modifiers'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayPressKey class >> displayName [

	^ 'Press key'
]

{ #category : 'accessing' }
ReplayPressKey class >> keyChoices [

	^ ReplayKeyChord keyChoices
]

{ #category : 'accessing' }
ReplayPressKey >> chord [
	"The key I press, with my modifiers"

	^ (ReplayKeyChord namedKey: self keySelector) withModifiers: self modifiers
]

{ #category : 'initialization' }
ReplayPressKey >> initialize [

	super initialize.
	keySelector := #left.
	repeatCount := 1
]

{ #category : 'accessing' }
ReplayPressKey >> keyLabel [

	^ self class keyChoices
		detect: [ :association | association key = self keySelector ]
		ifFound: [ :association | association value ]
		ifNone: [ self keySelector asString ]
]

{ #category : 'editing' }
ReplayPressKey >> keyPresenterOn: editor [

	| dropList choices |
	choices := self class keyChoices.
	(dropList := editor newDropList)
		items: choices;
		display: [ :association | association value ];
		whenSelectedItemChangedDo: [ :association |
			association ifNotNil: [
				self keySelector: association key.
				editor actionChanged: self ] ].
	dropList selectItem: (choices
		detect: [ :association | association key = self keySelector ]
		ifNone: [ choices first ]).
	editor registerReplayPresenter: dropList named: 'Action key'.
	editor registerReplayPresenter: dropList named: 'Press key selector'.

	^ SpBoxLayout newTopToBottom
		add: 'Key:' expand: false;
		add: dropList expand: false;
		yourself
]

{ #category : 'accessing' }
ReplayPressKey >> keySelector [

	^ keySelector ifNil: [ keySelector := #left ]
]

{ #category : 'accessing' }
ReplayPressKey >> keySelector: aSymbol [

	keySelector := aSymbol
]

{ #category : 'editing' }
ReplayPressKey >> modifierPresenterOn: editor [

	| presenter |
	presenter := editor instantiate: ReplayKeyModifiersPresenter.
	presenter
		modifiers: self modifiers;
		whenChangedDo: [ :newModifiers |
			self modifiers: newModifiers.
			editor actionChanged: self ].
	presenter registerReplayPresentersOn: editor named: 'Action'.
	presenter registerReplayPresentersOn: editor named: self class displayName.
	^ SpBoxLayout newTopToBottom
		add: 'Modifiers:' expand: false;
		add: presenter;
		yourself
]

{ #category : 'accessing' }
ReplayPressKey >> modifiers [

	^ modifiers ifNil: [ 0 ]
]

{ #category : 'accessing' }
ReplayPressKey >> modifiers: anInteger [

	modifiers := anInteger
]

{ #category : 'running' }
ReplayPressKey >> pressKeyOn: ui [

	| chord |
	chord := self chord.
	self repeatCount timesRepeat: [
		(chord keyboardEventOfType: #keyDown) sentTo: ui.
		chord typesText ifTrue: [ (chord keyboardEventOfType: #keystroke) sentTo: ui ].
		(chord keyboardEventOfType: #keyUp) sentTo: ui ]
]

{ #category : 'printing' }
ReplayPressKey >> printOn: stream [

	super printOn: stream.
	stream
		nextPutAll: ': ';
		nextPutAll: self keyLabel.
	self modifiers = 0 ifFalse: [
		stream
			nextPutAll: ' modifiers=';
			print: self modifiers ].
	self repeatCount = 1 ifFalse: [
		stream
			nextPutAll: ' x';
			print: self repeatCount ]
]

{ #category : 'accessing' }
ReplayPressKey >> repeatCount [

	^ repeatCount ifNil: [ repeatCount := 1 ]
]

{ #category : 'accessing' }
ReplayPressKey >> repeatCount: anInteger [

	repeatCount := 1 max: anInteger asInteger
]

{ #category : 'editing' }
ReplayPressKey >> repeatCountPresenterOn: editor [

	| countPresenter |
	(countPresenter := editor newNumberInput)
		minimum: 1;
		numberType: Integer;
		number: self repeatCount;
		whenNumberChangedDo: [ :aNumber |
			self repeatCount: aNumber.
			editor actionChanged: self ].
	editor registerReplayPresenter: countPresenter named: 'Action repeat count'.
	editor registerReplayPresenter: countPresenter named: 'Press key repeat count'.

	^ SpBoxLayout newTopToBottom
		add: 'Repeat count:' expand: false;
		add: countPresenter expand: false;
		yourself
]

{ #category : 'running' }
ReplayPressKey >> runOn: runner onUI: ui [

	self pressKeyOn: ui
]

{ #category : 'running' }
ReplayPressKey >> runOn: runner resolvedUI: resolvedUI [

	resolvedUI runPressKey: self
]

{ #category : 'editing' }
ReplayPressKey >> settingsPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newTopToBottom
				spacing: 10;
				add: (self targetPresenterOn: editor) expand: false;
				add: (self keyPresenterOn: editor) expand: false;
				add: (self modifierPresenterOn: editor) expand: false;
				add: (self repeatCountPresenterOn: editor) expand: false;
				yourself);
		yourself
]

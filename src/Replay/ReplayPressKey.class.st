Class {
	#name : 'ReplayPressKey',
	#superclass : 'ReplayKeyboardEvent',
	#traits : 'TReplayActionWithFlags',
	#classTraits : 'TReplayActionWithFlags classTrait',
	#instVars : [
		'keySelector',
		'repeatCount',
		'flags'
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

	^ {
		#left -> 'Left'.
		#right -> 'Right'.
		#up -> 'Up'.
		#down -> 'Down'.
		#home -> 'Home'.
		#end -> 'End'.
		#pageUp -> 'Page Up'.
		#pageDown -> 'Page Down'.
		#backspace -> 'Backspace'.
		#delete -> 'Delete'.
		#enter -> 'Enter'.
		#escape -> 'Escape'.
		#tab -> 'Tab'.
		#space -> 'Space' }
]

{ #category : 'accessing' }
ReplayPressKey >> flags [

	^ flags ifNil: [ flags := 0 ]
]

{ #category : 'accessing' }
ReplayPressKey >> flags: anInteger [

	flags := anInteger
]

{ #category : 'initialization' }
ReplayPressKey >> initialize [

	super initialize.
	keySelector := #left.
	repeatCount := 1.
	flags := 0
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
				editor actions rebuildLayout ] ].
	dropList selectItem: (choices
		detect: [ :association | association key = self keySelector ]
		ifNone: [ choices first ]).

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

{ #category : 'accessing' }
ReplayPressKey >> keyboardKey [

	^ KeyboardKey perform: self keySelector
]

{ #category : 'editing' }
ReplayPressKey >> modifierPresenterOn: editor [

	^ SpBoxLayout newTopToBottom
		add: 'Modifiers:' expand: false;
		add: (self flagsPresenterOn: editor namesAndValues: #(
			Shift 8
			Control 16
			'Alt/Option' 32
			Command 64));
		yourself
]

{ #category : 'running' }
ReplayPressKey >> pressKeyOn: ui [

	self repeatCount timesRepeat: [
		(self keyDownKey: self keyboardKey buttons: self flags) sentTo: ui.
		(self keyUpKey: self keyboardKey buttons: self flags) sentTo: ui ]
]

{ #category : 'printing' }
ReplayPressKey >> printOn: stream [

	super printOn: stream.
	stream
		nextPutAll: ': ';
		nextPutAll: self keyLabel.
	self flags = 0 ifFalse: [
		stream
			nextPutAll: ' modifiers=';
			print: self flags ].
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
			editor actions rebuildLayout ].

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

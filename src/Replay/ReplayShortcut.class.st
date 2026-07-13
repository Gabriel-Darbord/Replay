"
I send a keyboard shortcut chord to a resolved UI target and can adopt shortcuts from Pharo keymaps.
"
Class {
	#name : 'ReplayShortcut',
	#superclass : 'ReplayKeyboardEvent',
	#traits : 'TReplayActionWithFlags',
	#classTraits : 'TReplayActionWithFlags classTrait',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayShortcut class >> displayName [

	^ 'Shortcut'
]

{ #category : 'instance creation' }
ReplayShortcut class >> fromKeymap: aKMKeymap [

	^ self new
		beForKeymap: aKMKeymap;
		yourself
]

{ #category : 'instance creation' }
ReplayShortcut class >> fromShortcut: aShortcut [

	^ self new
		beForShortcut: aShortcut;
		yourself
]

{ #category : 'converting' }
ReplayShortcut >> asKMShortcut [

	| combinations |
	self text isEmpty ifTrue: [ ^ KMNoShortcut new ].
	combinations := OrderedCollection new.
	self text do: [ :character |
		combinations add: (self keyCombinationForCharacter: character) ].
	^ combinations allButFirst
		inject: combinations first
		into: [ :shortcut :next | shortcut , next ]
]

{ #category : 'editing' }
ReplayShortcut >> beForKeymap: aKMKeymap [
	"Adopt the characters and modifiers of the keymap to replay it."

	self text: ''.
	self flags: 0.
	aKMKeymap shortcut configureReplayShortcut: self
]

{ #category : 'editing' }
ReplayShortcut >> beForShortcut: aShortcut [
	"Adopt the characters and modifiers from a Keymapping shortcut object."

	self text: ''.
	self flags: 0.
	aShortcut configureReplayShortcut: self
]

{ #category : 'converting' }
ReplayShortcut >> keyCombinationForCharacter: aCharacter [

	| combination |
	combination := aCharacter asLowercase.
	(self flags bitAnd: 64) ~= 0 ifTrue: [ combination := combination command ].
	(self flags bitAnd: 16) ~= 0 ifTrue: [ combination := combination control ].
	(self flags bitAnd: 32) ~= 0 ifTrue: [ combination := combination alt ].
	(self flags bitAnd: 8) ~= 0 ifTrue: [ combination := combination shift ].
	^ combination
]

{ #category : 'testing' }
ReplayShortcut >> matchesKeymap: aKMKeymap [

	^ self sameShortcutAs: (self class fromKeymap: aKMKeymap)
]

{ #category : 'editing' }
ReplayShortcut >> modifierPresenterOn: editor [
	"Flags for the keyboard modifier, a combination of the shift, control, alt and command keys being pressed."

	^ SpBoxLayout newTopToBottom
		  add: 'Which modifiers to activate:';
		  add: (self
				   flagsPresenterOn: editor
				   namesAndValues:
					   #( Shift 8 Control 16 'Alt/Option' 32 Command 64 ));
		  yourself
]

{ #category : 'testing' }
ReplayShortcut >> normalizedText [

	^ self text asLowercase
]

{ #category : 'running' }
ReplayShortcut >> runOn: runner onUI: ui [

	self shortcutOn: ui
]

{ #category : 'running' }
ReplayShortcut >> runOn: runner resolvedUI: resolvedUI [

	resolvedUI runShortcut: self
]

{ #category : 'testing' }
ReplayShortcut >> sameShortcutAs: aReplayShortcut [

	^ self flags = aReplayShortcut flags
		and: [ self normalizedText = aReplayShortcut normalizedText ]
]

{ #category : 'editing' }
ReplayShortcut >> settingsPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newTopToBottom
				spacing: 10;
				add: (self targetPresenterOn: editor) expand: false;
				add: (self modifierPresenterOn: editor) expand: false;
				add: (self textPresenterOn: editor labeled: 'Insert characters to use part shortcut:') expand: false;
				add: (self shortcutDescriptionPresenterOn: editor);
				yourself);
		yourself
]

{ #category : 'editing' }
ReplayShortcut >> shortcutDescriptionPresenterOn: editor [
	"Probably worth its own class"

	| presenter descriptionPresenter |
	presenter := editor newPresenter.

	"Presenter describing all existing shortcuts"
	(descriptionPresenter := ReplayShortcutDescriptionPresenter new)
		owner: presenter;
		categories: KMRepository default categories keys.

	text isEmptyOrNil ifFalse: [ "Select the corresponding shortcut in the presenter"
		| shortcut match |
		shortcut := self class new.
		descriptionPresenter categoryDropList items
			detect: [ :category |
				category allEntries keymaps
					detect: [ :keymap |
						shortcut beForKeymap: keymap.
						self flags = shortcut flags and: [ self text = shortcut text ] ]
					ifFound: [ :keymap |
						match := keymap.
						true ]
					ifNone: [ false ] ]
			ifFound: [ :category |
				descriptionPresenter categoryDropList selectItem: category.
				descriptionPresenter shortcutList
					selectItem: match
					scrollToSelection: true ] ].

	"Adopt a shortcut when it is selected"
	descriptionPresenter shortcutList whenSelectedDo: [ :keymap |
		self beForKeymap: keymap.
		editor actionEditor: (self editionPresenterOn: editor) ].

	presenter layout: (SpBoxLayout newTopToBottom
			 add: 'Select a shortcut in the list to use it:' expand: false;
			 add: descriptionPresenter;
			 yourself).
	^ presenter
]

{ #category : 'running' }
ReplayShortcut >> shortcutOn: ui [

	self text do: [ :character |
		(self keyDown: character buttons: self flags) sentTo: ui ]

	"What listens to keyUp? Doesn't seem required for shortcuts"
	"self text do: [ :character |
		(self keyUp: character buttons: self flags) sentTo: ui ]"
]

"
Trigger a shortcut using a key combination.
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

{ #category : 'editing' }
ReplayShortcut >> beForKeymap: aKMKeymap [
	"Adopt the characters and modifiers of the keymap to replay it."

	self text: ''.
	self flags: 0.
	aKMKeymap shortcut configureReplayShortcut: self
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

{ #category : 'editing' }
ReplayShortcut >> pathPresenterOn: editor [

	| layout pathStatePresenter targetWorldButton |
	layout := SpBoxLayout newLeftToRight.
	pathStatePresenter := self pathStatePresenterOn: editor.
	(targetWorldButton := editor newButton)
		icon: (self iconNamed: #edit);
		label: 'Target World';
		action: [
			path ifNotNil: [
					| newPresenter |
					path := nil.
					layout
						replace: pathStatePresenter
						with: (newPresenter := self pathStatePresenterOn: editor).
					editor actionEditor view rebuildLayout.
					pathStatePresenter := newPresenter ] ].

	^ layout
		  vAlignCenter;
		  spacing: 10;
		  add: targetWorldButton expand: false;
		  add: pathStatePresenter;
		  yourself
]

{ #category : 'editing' }
ReplayShortcut >> pathStatePresenterOn: editor [

	^ editor newPresenter
		  layout: (SpBoxLayout newLeftToRight
				   spacing: 10;
				   add:
					   (self iconNamed:
							    (path ifNil: [ #smallInfo ] ifNotNil: [ #smallOk ]))
				   expand: false;
				   add: (path
						    ifNil: [ 'Targeting current World.' ]
						    ifNotNil: [ 'Targeting managed UI.' ])
				   expand: false;
				   yourself);
		  yourself
]

{ #category : 'running' }
ReplayShortcut >> runOn: runner onUI: ui [

	self shortcutOn: ui
]

{ #category : 'running' }
ReplayShortcut >> runWithoutPathOn: runner [
	"Targets the current World by default.
	Has control of runner continuation."

	self shortcutOn: self currentWorld.

	"Await UI process before continuing"
	self currentWorld defer: [ runner nextAction ]
]

{ #category : 'editing' }
ReplayShortcut >> settingsPresenterOn: editor [

	^ editor newPresenter
		  layout: (SpBoxLayout newTopToBottom
				   spacing: 10;
				   add: (self pathPresenterOn: editor) expand: false;
				   add: (self modifierPresenterOn: editor) expand: false;
				   add: (self
						    textPresenterOn: editor
						    labeled:
							    'Insert the characters to use as part of the shortcut:')
				   expand: false;
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

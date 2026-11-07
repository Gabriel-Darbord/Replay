"
I replay a key binding (a ReplayKeyBinding) on a resolved UI target: I send a key down event for each of its chords, with the modifiers of the chord, as Keymapping dispatches shortcuts on key down.

My settings edit the binding with a ReplayKeyBindingPresenter, or adopt the binding of a keymap listed by a ReplayShortcutDescriptionPresenter.
"
Class {
	#name : 'ReplayShortcut',
	#superclass : 'ReplayKeyboardEvent',
	#instVars : [
		'keyBinding'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayShortcut class >> displayName [

	^ 'Shortcut'
]

{ #category : 'instance creation' }
ReplayShortcut class >> keyBinding: aReplayKeyBinding [

	^ self new
		  keyBinding: aReplayKeyBinding;
		  yourself
]

{ #category : 'accessing' }
ReplayShortcut >> keyBinding [

	^ keyBinding ifNil: [ keyBinding := ReplayKeyBinding new ]
]

{ #category : 'accessing' }
ReplayShortcut >> keyBinding: aReplayKeyBinding [

	keyBinding := aReplayKeyBinding
]

{ #category : 'editing' }
ReplayShortcut >> keyBindingPresenterOn: editor [

	| presenter |
	presenter := ReplayKeyBindingPresenter on: self keyBinding whenChangedDo: [ :binding |
		             self keyBinding: binding.
		             editor actionChanged: self ].
	presenter registerReplayPresentersOn: editor named: 'Action shortcut'.
	presenter registerReplayPresentersOn: editor named: self class displayName.
	^ presenter
]

{ #category : 'printing' }
ReplayShortcut >> printOn: stream [

	super printOn: stream.
	self printDetail: self keyBinding displayString on: stream
]

{ #category : 'running' }
ReplayShortcut >> runOn: runner onUI: ui [

	self shortcutOn: ui
]

{ #category : 'running' }
ReplayShortcut >> runOn: runner resolvedUI: resolvedUI [

	resolvedUI runShortcut: self
]

{ #category : 'editing' }
ReplayShortcut >> settingsPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newTopToBottom
				spacing: 10;
				add: (self targetPresenterOn: editor) expand: false;
				add: (self keyBindingPresenterOn: editor) expand: false;
				add: (self shortcutDescriptionPresenterOn: editor);
				yourself);
		yourself
]

{ #category : 'editing' }
ReplayShortcut >> shortcutDescriptionPresenterOn: editor [

	| presenter descriptionPresenter |
	presenter := editor newPresenter.
	(descriptionPresenter := ReplayShortcutDescriptionPresenter new)
		owner: presenter;
		categories: KMRepository default categories keys;
		selectKeymapOf: self keyBinding.

	"Adopt the binding of a keymap when it is selected"
	descriptionPresenter shortcutList whenSelectedDo: [ :keymap |
		(ReplayKeyBinding fromKeymap: keymap) ifNotNil: [ :binding |
			self keyBinding: binding.
			editor buildActionEditor: [ self editionPresenterOn: editor ] ] ].

	presenter layout: (SpBoxLayout newTopToBottom
			 add: 'Select a shortcut in the list to use it:' expand: false;
			 add: descriptionPresenter;
			 yourself).
	^ presenter
]

{ #category : 'running' }
ReplayShortcut >> shortcutOn: ui [
	"Keymapping dispatches on key down, nothing needs the key up"

	self keyBinding chords do: [ :chord |
		chord keyboardKey ifNotNil: [ (chord keyboardEventOfType: #keyDown) sentTo: ui ] ]
]

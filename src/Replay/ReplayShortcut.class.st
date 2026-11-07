"
I replay a key binding (a ReplayKeyBinding) on a resolved UI target: I send a key down event for each of its chords, with the modifiers of the chord, as Keymapping dispatches shortcuts on key down.

My editor (ReplayShortcutEditor) edits the binding with a ReplayKeyBindingPresenter, or adopts the binding of a keymap listed by a ReplayShortcutDescriptionPresenter.
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

{ #category : 'editing' }
ReplayShortcut class >> editorClass [

	^ ReplayShortcutEditor
]

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

{ #category : 'printing' }
ReplayShortcut >> printOn: stream [

	super printOn: stream.
	self printDetail: self keyBinding displayString on: stream
]

{ #category : 'running' }
ReplayShortcut >> runOnMorph: aMorph [

	self shortcutOn: aMorph
]

{ #category : 'running' }
ReplayShortcut >> shortcutOn: ui [
	"Keymapping dispatches on key down, nothing needs the key up"

	self keyBinding chords do: [ :chord |
		chord keyboardKey ifNotNil: [ (chord keyboardEventOfType: #keyDown) sentTo: ui ] ]
]

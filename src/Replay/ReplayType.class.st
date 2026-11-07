"
I type configured text into a resolved UI target by sending keystroke events for each character.
"
Class {
	#name : 'ReplayType',
	#superclass : 'ReplayKeyboardEvent',
	#traits : 'TReplayActionWithText',
	#classTraits : 'TReplayActionWithText classTrait',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'editing' }
ReplayType class >> editorClass [

	^ ReplayTypeEditor
]

{ #category : 'accessing' }
ReplayType class >> displayName [

	^ 'Type'
]

{ #category : 'running' }
ReplayType >> runOnMorph: aMorph [

	self typeOn: aMorph
]

{ #category : 'running' }
ReplayType >> typeOn: ui [

	"Like the text input of a real keyboard: keystrokes without key down and key up"

	self text do: [ :character |
		(ReplayKeyChord keyboardEventOfType: #keystroke key: nil character: character modifiers: 0) sentTo: ui
		"1 milliSeconds wait" "<- typewriter-style, letter by letter" ]
]

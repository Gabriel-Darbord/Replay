"
Type some text using the keyboard.
"
Class {
	#name : 'ReplayType',
	#superclass : 'ReplayKeyboardEvent',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayType class >> displayName [

	^ 'Type'
]

{ #category : 'running' }
ReplayType >> runOn: runner onUI: ui [

	self typeOn: ui
]

{ #category : 'editing' }
ReplayType >> settingsPresenterOn: editor [

	^ editor newPresenter
		  layout: (SpBoxLayout newTopToBottom
				   spacing: 10;
				   add: (self pathPresenterOn: editor) expand: false;
				   add:
					   (self
						    textPresenterOn: editor
						    labeled: 'Write the text to type:');
				   yourself);
		  yourself
]

{ #category : 'running' }
ReplayType >> typeOn: ui [

	self text do: [ :character |
		(self keystroke: character) sentTo: ui
		"1 milliSeconds wait" "<- typewriter-style, letter by letter" ]
]

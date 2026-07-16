"
I listen to hand events while a Replay editor window is open and toggle scenario recording from the editor shortcut, even when the focus is in another window.
"
Class {
	#name : 'ReplayRecordingToggleListener',
	#superclass : 'Object',
	#instVars : [
		'editor'
	],
	#category : 'Replay-Recording',
	#package : 'Replay',
	#tag : 'Recording'
}

{ #category : 'instance creation' }
ReplayRecordingToggleListener class >> on: aReplayEditor [

	^ self new
		editor: aReplayEditor;
		yourself
]

{ #category : 'accessing' }
ReplayRecordingToggleListener >> editor [

	^ editor
]

{ #category : 'accessing' }
ReplayRecordingToggleListener >> editor: aReplayEditor [

	editor := aReplayEditor
]

{ #category : 'event handling' }
ReplayRecordingToggleListener >> handleListenEvent: anEvent [

	editor ifNil: [ ^ self ].
	(editor recordingShortcutMatchesEvent: anEvent) ifFalse: [ ^ self ].
	editor toggleRecordingFromShortcutEvent: anEvent
]

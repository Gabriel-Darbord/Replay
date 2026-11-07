"
I show an informational UIManager notification as a scenario action. Editor previews do not show it.
"
Class {
	#name : 'ReplayInform',
	#superclass : 'ReplayAction',
	#traits : 'TReplayActionWithText',
	#classTraits : 'TReplayActionWithText classTrait',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'editing' }
ReplayInform class >> editorClass [

	^ ReplayInformEditor
]

{ #category : 'accessing' }
ReplayInform class >> displayName [

	^ 'Inform'
]

{ #category : 'running' }
ReplayInform >> previewOn: aReplayUIBuilder [
	"Notifications are not part of the previewed UI."
]

{ #category : 'running' }
ReplayInform >> runOn: runner [

	UIManager default inform: (Microdown asRichText: self text)
]

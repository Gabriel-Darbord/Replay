"
I execute configured Smalltalk script with the Replay runner as receiver.

My script may change any state of the image, so I do nothing when the editor rebuilds a UI preview.
"
Class {
	#name : 'ReplayScript',
	#superclass : 'ReplayAction',
	#traits : 'TReplayActionWithScript',
	#classTraits : 'TReplayActionWithScript classTrait',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'editing' }
ReplayScript class >> editorClass [

	^ ReplayScriptEditor
]

{ #category : 'accessing' }
ReplayScript class >> displayName [

	^ 'Script'
]

{ #category : 'running' }
ReplayScript >> previewOn: aReplayUIBuilder [
	"The script can change global state: do not run it each time the editor shows a preview."
]

{ #category : 'running' }
ReplayScript >> runOn: runner [

	self evaluateScriptOn: runner
]

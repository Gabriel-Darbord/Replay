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

{ #category : 'accessing' }
ReplayScript class >> displayName [

	^ 'Script'
]

{ #category : 'editing' }
ReplayScript >> editionPresenterOn: editor [

	^ editor newPresenter
		layout: (SpBoxLayout newTopToBottom
				spacing: 10;
				add: (self scriptPresenterOn: editor labeled: self scriptLabel);
				add: (self
						debugButtonPresenterOn: editor
						labeled: 'Debug script'
						action: [ self debugScriptInEditor: editor ])
				expand: false;
				yourself);
		yourself
]

{ #category : 'running' }
ReplayScript >> previewOn: aReplayUIBuilder [
	"The script can change global state: do not run it each time the editor shows a preview."
]

{ #category : 'running' }
ReplayScript >> runOn: runner [

	self evaluateScriptOn: runner
]

{ #category : 'editing' }
ReplayScript >> scriptLabel [

	^ 'Script evaluated with the Replay runner as self:'
]

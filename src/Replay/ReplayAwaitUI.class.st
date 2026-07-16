"
I let the active backend process one UI cycle before Replay continues. Use me after actions that schedule layout or rendering work.
"
Class {
	#name : 'ReplayAwaitUI',
	#superclass : 'ReplayAction',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayAwaitUI class >> displayName [

	^ 'Await UI'
]

{ #category : 'running' }
ReplayAwaitUI >> runOn: runner [

	runner settleUI
]

"
I let Morphic/Spec process pending UI layout and deferred work before the next Replay action runs.
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

"
I attach a replay runner to the Morphic World without adding an overlay or taking ownership of any UI. I am useful as the first action of scenarios recorded at world scope.
"
Class {
	#name : 'ReplayAttachWorld',
	#superclass : 'ReplayAction',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayAttachWorld class >> displayName [

	^ 'Attach World'
]

{ #category : 'testing' }
ReplayAttachWorld >> isUIOpener [

	^ true
]

{ #category : 'running' }
ReplayAttachWorld >> runOn: runner [

	runner manager: (ReplayUIManager new observe: World)
]

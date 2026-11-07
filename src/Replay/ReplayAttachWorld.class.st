"
I attach a replay runner to the Morphic World without adding an overlay or taking ownership of any UI. I am useful as the first action of scenarios recorded at world scope.
"
Class {
	#name : 'ReplayAttachWorld',
	#superclass : 'ReplayAttach',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayAttachWorld class >> displayName [

	^ 'Attach World'
]

{ #category : 'managing UI' }
ReplayAttachWorld >> uiManagerOn: runner [

	^ ReplayUIManager new observe: self currentWorld
]

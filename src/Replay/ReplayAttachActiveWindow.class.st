"
I attach a replay runner to the currently active Morphic window without adding an overlay. I resolve the active window at run time: the window of the keyboard focus, or else the frontmost window, falling back to the World when there is no window.

The windows of Replay tools (see ReplayToolPresenter) are skipped: they edit, record and run scenarios, and are not their subject. The scenario editor records the same window I attach to, so that a scenario recorded from the editor also replays when run from it.
"
Class {
	#name : 'ReplayAttachActiveWindow',
	#superclass : 'ReplayAttach',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'resolving' }
ReplayAttachActiveWindow class >> activeWindowMorph [

	^ self activeWindowMorphFromHand: self currentWorld activeHand
]

{ #category : 'resolving' }
ReplayAttachActiveWindow class >> activeWindowMorphFromHand: aHandMorph [
	"The window of the keyboard focus of aHandMorph, or else the frontmost window, or else the World. Replay tool windows are skipped."

	(aHandMorph ifNotNil: [ aHandMorph keyboardFocus ]) ifNotNil: [ :focus |
		(self windowMorphFor: focus) ifNotNil: [ :window |
			(ReplayToolPresenter isToolWindow: window) ifFalse: [ ^ window ] ] ].
	^ self frontmostWindow ifNil: [ self currentWorld ]
]

{ #category : 'accessing' }
ReplayAttachActiveWindow class >> displayName [

	^ 'Attach Active Window'
]

{ #category : 'resolving' }
ReplayAttachActiveWindow class >> frontmostWindow [
	"The frontmost window of the World that is not a Replay tool, or nil"

	^ self currentWorld submorphs
		  detect: [ :morph | (morph isKindOf: SystemWindow) and: [ (ReplayToolPresenter isToolWindow: morph) not ] ]
		  ifNone: [ nil ]
]

{ #category : 'resolving' }
ReplayAttachActiveWindow class >> windowMorphFor: aMorph [

	^ aMorph ownerChain
		detect: [ :each | each isKindOf: SystemWindow ]
		ifNone: [ nil ]
]

{ #category : 'managing UI' }
ReplayAttachActiveWindow >> uiManagerOn: runner [

	^ ReplayUIManager new observe: self class activeWindowMorph
]

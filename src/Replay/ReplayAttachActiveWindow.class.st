"
I attach a replay runner to the currently active Morphic window without adding an overlay. I resolve the active window at run time, falling back to the World when no window can be found.
"
Class {
	#name : 'ReplayAttachActiveWindow',
	#superclass : 'ReplayAttach',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'resolving' }
ReplayAttachActiveWindow class >> activeSystemWindow [

	^ self currentWorld submorphs
		detect: [ :morph | (morph isKindOf: SystemWindow) and: [ morph isActive ] ]
		ifNone: [ nil ]
]

{ #category : 'resolving' }
ReplayAttachActiveWindow class >> activeWindowMorph [

	^ self activeWindowMorphFromHand: self currentWorld activeHand
]

{ #category : 'resolving' }
ReplayAttachActiveWindow class >> activeWindowMorphFromHand: aHandMorph [

	| focus window |
	focus := aHandMorph ifNotNil: [ aHandMorph keyboardFocus ].
	focus ifNotNil: [
		window := self windowMorphFor: focus.
		window ifNotNil: [ ^ window ] ].
	^ self activeSystemWindow ifNil: [ self currentWorld ]
]

{ #category : 'accessing' }
ReplayAttachActiveWindow class >> displayName [

	^ 'Attach Active Window'
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

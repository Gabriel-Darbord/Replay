"
I attach a replay runner to the currently active Morphic window without adding an overlay. I resolve the active window at run time, falling back to the World when no window can be found.
"
Class {
	#name : 'ReplayAttachActiveWindow',
	#superclass : 'ReplayAction',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'resolving' }
ReplayAttachActiveWindow class >> activeSystemWindow [

	| systemWindowClass |
	systemWindowClass := self systemWindowClass.
	systemWindowClass ifNil: [ ^ nil ].
	^ World submorphs
		detect: [ :morph | (morph isKindOf: systemWindowClass) and: [ morph isActive ] ]
		ifNone: [ nil ]
]

{ #category : 'resolving' }
ReplayAttachActiveWindow class >> activeWindowMorph [

	^ self activeWindowMorphFromHand: World activeHand
]

{ #category : 'resolving' }
ReplayAttachActiveWindow class >> activeWindowMorphFromHand: aHandMorph [

	| focus window |
	focus := aHandMorph ifNotNil: [ aHandMorph keyboardFocus ].
	focus ifNotNil: [
		window := self windowMorphFor: focus.
		window ifNotNil: [ ^ window ] ].
	^ self activeSystemWindow ifNil: [ World ]
]

{ #category : 'accessing' }
ReplayAttachActiveWindow class >> displayName [

	^ 'Attach Active Window'
]

{ #category : 'resolving' }
ReplayAttachActiveWindow class >> systemWindowClass [

	^ Smalltalk globals at: #SystemWindow ifAbsent: [ nil ]
]

{ #category : 'resolving' }
ReplayAttachActiveWindow class >> windowMorphFor: aMorph [

	| systemWindowClass |
	systemWindowClass := self systemWindowClass.
	systemWindowClass ifNil: [ ^ nil ].
	^ aMorph ownerChain
		detect: [ :each | each isKindOf: systemWindowClass ]
		ifNone: [ nil ]
]

{ #category : 'testing' }
ReplayAttachActiveWindow >> isUIOpener [

	^ true
]

{ #category : 'running' }
ReplayAttachActiveWindow >> runOn: runner [

	runner manager: (ReplayUIManager new observe: self class activeWindowMorph)
]

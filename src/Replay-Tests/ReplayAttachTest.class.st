"
Tests for actions attaching the runner to existing UI.
"
Class {
	#name : 'ReplayAttachTest',
	#superclass : 'TestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'tests' }
ReplayAttachTest >> testAttachActiveWindowObservesActiveWindowOrWorld [

	| runner manager |
	runner := ReplayRunner new.

	ReplayAttachActiveWindow new runOn: runner.

	manager := runner manager.
	self deny: manager ownsUI.
	self assert: manager overlay isNil.
	self assert: manager managedUI identicalTo: ReplayAttachActiveWindow activeWindowMorph
]

{ #category : 'tests' }
ReplayAttachTest >> testAttachReplacesAndClosesThePreviousManager [

	| runner root previous |
	runner := ReplayRunner new.
	root := Morph new.
	previous := ReplayUIManager new manage: (Morph new extent: 100 @ 50).
	root addMorph: previous ui.
	runner manager: previous.

	ReplayAttachWorld new runOn: runner.

	self assert: previous ui owner isNil.
	self assert: runner manager managedUI identicalTo: self currentWorld
]

{ #category : 'tests' }
ReplayAttachTest >> testAttachUIOverlayIsRemovedWhenRunnerStops [

	| root target runner |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (10 @ 10 corner: 80 @ 40).
	root addMorph: target.
	runner := ReplayRunner new focus: target.

	(ReplayAttachUI new script: 'self focus') runOn: runner.
	self assert: root submorphs size equals: 2.
	runner stop.

	self assert: root submorphs asArray equals: { target }
]

{ #category : 'tests' }
ReplayAttachTest >> testAttachWorldObservesWorld [

	| runner |
	runner := ReplayRunner new.

	ReplayAttachWorld new runOn: runner.

	self deny: runner manager ownsUI.
	self assert: runner manager managedUI identicalTo: self currentWorld.
	self assert: runner manager overlay isNil
]

{ #category : 'tests' }
ReplayAttachTest >> testAttachersAreUIOpeners [

	| openers |
	openers := ReplayAction actionsThatOpenUI.

	self assert: (openers includesAll: {
			 ReplayAttachUI.
			 ReplayAttachWorld.
			 ReplayAttachActiveWindow }).
	self deny: (openers includes: ReplayAttach)
]

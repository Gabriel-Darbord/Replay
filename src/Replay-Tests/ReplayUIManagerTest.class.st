"
Tests for ReplayUIManager UI ownership and its default backend.
"
Class {
	#name : 'ReplayUIManagerTest',
	#superclass : 'TestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'tests' }
ReplayUIManagerTest >> testOwnedUIBlocksUserInteraction [

	| attached owner target |
	self assert: (ReplayUIManager new manage: Morph new) blocksUserInteraction.
	owner := Morph new.
	target := Morph new.
	owner addMorph: target.
	attached := ReplayUIManager new attachTo: target.
	self deny: attached blocksUserInteraction
]

{ #category : 'tests' }
ReplayUIManagerTest >> testWithoutUIUsesDefaultBackend [

	| empty |
	empty := ReplayUIManager new.

	self assert: empty backend class equals: ReplayUIBackend.
	self assert: empty managedUI isNil.
	self assert: empty managedPresenter isNil
]

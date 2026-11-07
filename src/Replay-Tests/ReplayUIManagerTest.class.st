"
Tests for ReplayUIManager edition wrappers and UI ownership.
"
Class {
	#name : 'ReplayUIManagerTest',
	#superclass : 'TestCase',
	#instVars : [
		'manager',
		'root'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayUIManagerTest >> childIndexesOf: aWrapper [

	^ (aWrapper submorphs collect: [ :each | each index ]) asArray
]

{ #category : 'running' }
ReplayUIManagerTest >> setUp [
	"A managed morph with three children, each with two children."

	super setUp.
	root := Morph new extent: 300 @ 100.
	1 to: 3 do: [ :index |
		| child |
		child := Morph new bounds: (index * 90 @ 10 extent: 80 @ 80).
		child addMorph: (Morph new bounds: (child topLeft extent: 10 @ 10)).
		child addMorphBack: (Morph new bounds: (child topLeft + 20 extent: 10 @ 10)).
		root addMorphBack: child ].
	manager := ReplayUIManager new manage: root
]

{ #category : 'tests' }
ReplayUIManagerTest >> testExposeChildrenAfterExposeParentRestoresOneWrapperPerChild [

	| rootWrapper |
	rootWrapper := manager wrapMorph: root atDepth: 1.
	manager overlay addMorph: rootWrapper.

	manager exposeParentMorph: rootWrapper submorphs second.
	self assert: (self childIndexesOf: rootWrapper) equals: #( 1 3 ).
	manager exposeChildMorphs: rootWrapper.
	self assert: (self childIndexesOf: rootWrapper) equals: #( 1 2 3 ).
	manager exposeChildMorphs: rootWrapper.
	self assert: (self childIndexesOf: rootWrapper) equals: #( 1 2 3 ).
	self assert: (self childIndexesOf: rootWrapper submorphs second) equals: #( 1 2 )
]

{ #category : 'tests' }
ReplayUIManagerTest >> testExposeChildrenWrapsUnwrappedChildren [

	| rootWrapper |
	rootWrapper := manager wrapMorph: root atDepth: manager maxWrapDepth.
	self assert: rootWrapper submorphs isEmpty.

	manager exposeChildMorphs: rootWrapper.

	self assert: (self childIndexesOf: rootWrapper) equals: #( 1 2 3 ).
	self
		assert: (rootWrapper submorphs collect: [ :each | each wrappedMorph ]) asArray
		equals: root submorphs asArray
]

{ #category : 'tests' }
ReplayUIManagerTest >> testExposeParentRemovesTheWrapperAndItsWrappers [

	| rootWrapper wrapper |
	rootWrapper := manager wrapMorph: root atDepth: 1.
	wrapper := rootWrapper submorphs first.

	manager exposeParentMorph: wrapper.

	self assert: wrapper owner isNil.
	self assert: wrapper submorphs size equals: 2.
	self assert: (self childIndexesOf: rootWrapper) equals: #( 2 3 )
]

{ #category : 'tests' }
ReplayUIManagerTest >> testExposeParentKeepsTheRootWrapper [

	| rootWrapper |
	rootWrapper := manager wrapMorph: root atDepth: 1.
	manager overlay addMorph: rootWrapper.

	manager exposeParentMorph: rootWrapper.

	self assert: rootWrapper owner identicalTo: manager overlay
]

{ #category : 'tests' }
ReplayUIManagerTest >> testOwnedUIBlocksUserInteraction [

	| attached owner target |
	self assert: manager blocksUserInteraction.
	owner := Morph new.
	target := Morph new.
	owner addMorph: target.
	attached := ReplayUIManager new attachTo: target.
	self deny: attached blocksUserInteraction
]

{ #category : 'tests' }
ReplayUIManagerTest >> testWrappersFollowChildOrder [

	| rootWrapper |
	rootWrapper := manager wrapMorph: root atDepth: 1.

	self assert: (self childIndexesOf: rootWrapper) equals: #( 1 2 3 ).
	self
		assert: (rootWrapper submorphs collect: [ :each | each wrappedMorph ]) asArray
		equals: root submorphs asArray
]

{ #category : 'tests' }
ReplayUIManagerTest >> testWithoutUIUsesDefaultBackend [

	| empty |
	empty := ReplayUIManager new.

	self assert: empty backend class equals: ReplayUIBackend.
	self assert: empty managedUI isNil.
	self assert: empty managedPresenter isNil
]

"
Tests for resolving Morphic references, and for the retries of resolvers, without opening scenario windows.
"
Class {
	#name : 'ReplayMorphicResolverTest',
	#superclass : 'ReplayTestCase',
	#instVars : [
		'root',
		'backend',
		'resolver'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayMorphicResolverTest >> resolvePath: anArray [
	"Answer the element resolved for the Morphic path anArray, the error when it is missing, or nil while it is pending"

	| result |
	resolver
		resolve: (ReplayUIReference morphicPath: anArray)
		thenDo: [ :element | result := element ]
		onMissing: [ :error | result := error ].
	^ result
]

{ #category : 'running' }
ReplayMorphicResolverTest >> setUp [

	super setUp.
	root := Morph new.
	backend := ReplayRecordingBackend new managedUI: root.
	resolver := ReplayMorphicResolver on: backend
]

{ #category : 'tests' }
ReplayMorphicResolverTest >> testAnnotateDefersOverlayUntilAfterTargetResolution [

	| runner manager target action resolved |
	root extent: 200 @ 100.
	target := Morph new bounds: (10 @ 10 corner: 60 @ 40).
	root addMorph: target.
	manager := ReplayUIManager new manage: root.
	runner := ReplayRunner new manager: manager.
	action := ReplayAnnotate target: (ReplayUIReference morphicPath: #( 1 )).
	action text: 'target'.

	[
		manager openLabeled: 'Replay annotation test'.
		self currentWorld doOneCycle.
		action resolveTargetWith: manager thenDo: [ :element | resolved := element ] onMissing: [ :error | error signal ].
		self assert: resolved morph identicalTo: target.
		action runOn: runner resolvedUI: resolved.
		self assert: manager overlay submorphs isEmpty.
		self currentWorld doOneCycle.
		self assert: manager overlay submorphs size equals: 1 ]
		ensure: [ manager close ]
]

{ #category : 'tests' }
ReplayMorphicResolverTest >> testAnnotateHighlightWrapsResolvedTargetBounds [

	| runner manager target action annotation expected |
	root extent: 200 @ 100.
	target := Morph new bounds: (10 @ 10 corner: 60 @ 40).
	root addMorph: target.
	manager := ReplayUIManager new manage: root.
	runner := ReplayRunner new manager: manager.
	action := ReplayAnnotate target: (ReplayUIReference morphicPath: #( 1 )).
	action text: 'target'.

	[
		manager openLabeled: 'Replay annotation bounds test'.
		self currentWorld doOneCycle.
		action
			resolveTargetWith: manager
			thenDo: [ :element | action runOn: runner resolvedUI: element ]
			onMissing: [ :error | error signal ].
		self currentWorld doOneCycle.
		annotation := manager overlay submorphs first.
		expected := Rectangle
			origin: target bounds origin - 5
			corner: target bounds corner + 5.
		self assert: annotation bounds equals: expected ]
		ensure: [ manager close ]
]

{ #category : 'tests' }
ReplayMorphicResolverTest >> testEmptyPathResolvesTheSurface [

	self assert: (self resolvePath: #(  )) morph identicalTo: root.
	self assert: backend deferredBlockCount equals: 0
]

{ #category : 'tests' }
ReplayMorphicResolverTest >> testExistingPathResolvesWithoutDeferring [

	| child resolved |
	child := Morph new.
	root addMorph: child.

	resolved := self resolvePath: #( 1 ).

	self assert: resolved morph identicalTo: child.
	self assert: resolved nativeElement identicalTo: child.
	self assert: backend deferredBlockCount equals: 0
]

{ #category : 'tests' }
ReplayMorphicResolverTest >> testMissingPathReportsAvailableChildrenAfterTimeout [

	| child error availableChildren |
	child := Morph new.
	root addMorph: child.
	resolver timeout: Duration zero.

	error := self resolvePath: #( 2 ).

	self assert: error class equals: ReplayMissingUIError.
	self assert: (error messageText includesSubstring: 'Could not resolve UI target at path #(2)').
	self assert: (error messageText includesSubstring: 'Path index 2 at position 1 is outside 1 submorph(s)').
	self assert: (error subject at: #path) equals: #( 2 ).
	self assert: (error subject at: #reference) equals: (ReplayUIReference morphicPath: #( 2 )).
	availableChildren := error subject at: #availableChildren.
	self assert: availableChildren size equals: 1.
	self assert: (availableChildren first at: #class) equals: child class name
]

{ #category : 'tests' }
ReplayMorphicResolverTest >> testMissingPathReportsMorphWithoutSubmorphs [

	| error |
	resolver timeout: Duration zero.

	error := self resolvePath: #( 1 ).

	self assert: (error messageText includesSubstring: 'has no submorphs at path position 1')
]

{ #category : 'tests' }
ReplayMorphicResolverTest >> testNestedPathResolves [

	| child target |
	child := Morph new.
	target := Morph new.
	root addMorph: child.
	child addMorph: target.

	self assert: (self resolvePath: #( 1 1 )) morph identicalTo: target
]

{ #category : 'tests' }
ReplayMorphicResolverTest >> testPathWaitsWhileAMorphIsStillLoading [

	| loading child result |
	loading := ReplayLoadingMorph new loading: true.
	child := Morph new.
	loading addMorph: child.
	root addMorph: loading.

	resolver
		resolve: (ReplayUIReference morphicPath: #( 1 1 ))
		thenDo: [ :element | result := element ]
		onMissing: [ :error | self fail: error messageText ].

	self assert: result isNil.
	self assert: backend deferredBlockCount equals: 1.
	loading loading: false.
	backend runDeferredBlocks.
	self assert: result morph identicalTo: child.
	self assert: backend deferredBlockCount equals: 0
]

{ #category : 'tests' }
ReplayMorphicResolverTest >> testPathWaitsForALateChild [

	| child result |
	child := Morph new.
	resolver
		resolve: (ReplayUIReference morphicPath: #( 1 ))
		thenDo: [ :element | result := element ]
		onMissing: [ :error | self fail: error messageText ].

	self assert: result isNil.
	self assert: backend deferredBlockCount equals: 1.
	root addMorph: child.
	backend runDeferredBlocks.
	self assert: result morph identicalTo: child.
	self assert: backend deferredBlockCount equals: 0
]

{ #category : 'tests' }
ReplayMorphicResolverTest >> testUnsupportedReferenceIsReportedAtOnce [

	| error |
	resolver
		resolve: (ReplayUIReference named: 'Field')
		thenDo: [ :element | self fail ]
		onMissing: [ :missing | error := missing ].

	self assert: error class equals: ReplayMissingUIError.
	self assert: (error messageText includesSubstring: 'cannot resolve').
	self assert: backend deferredBlockCount equals: 0
]

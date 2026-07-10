"
Tests for resolving Replay UI paths without opening scenario windows.
"
Class {
	#name : 'ReplayUIPathResolverTest',
	#superclass : 'TestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'tests' }
ReplayUIPathResolverTest >> testAnnotateDefersOverlayUntilAfterTargetResolution [

	| runner manager root target action |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (10 @ 10 corner: 60 @ 40).
	root addMorph: target.
	manager := ReplayUIManager new manage: root.
	runner := ReplayRunner new manager: manager.
	action := ReplayAnnotate fromUIPath: #( 1 ).
	action text: 'target'.

	[
		manager openLabeled: 'Replay annotation test'.
		World doOneCycle.
		action runOn: runner onUI: target.
		self assert: manager overlay submorphs isEmpty.
		World doOneCycle.
		self assert: manager overlay submorphs size equals: 1 ]
		ensure: [ manager close ]
]

{ #category : 'tests' }
ReplayUIPathResolverTest >> testAnnotateHighlightWrapsResolvedTargetBounds [

	| runner manager root target action annotation expected |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (10 @ 10 corner: 60 @ 40).
	root addMorph: target.
	manager := ReplayUIManager new manage: root.
	runner := ReplayRunner new manager: manager.
	action := ReplayAnnotate fromUIPath: #( 1 ).
	action text: 'target'.

	[
		manager openLabeled: 'Replay annotation bounds test'.
		World doOneCycle.
		action runOn: runner onUI: target.
		World doOneCycle.
		annotation := manager overlay submorphs first.
		expected := Rectangle
			origin: target bounds origin - 5
			corner: target bounds corner + 5.
		self assert: annotation bounds equals: expected ]
		ensure: [ manager close ]
]

{ #category : 'tests' }
ReplayUIPathResolverTest >> testAttemptResolveReportsMissingAfterMaximumAttempts [

	| root child resolver capturedError availableChildren |
	root := Morph new.
	child := Morph new.
	root addMorph: child.
	resolver := ReplayUIPathResolver new
		            root: root;
		            path: #( 2 );
		            maxAttempts: 1;
		            whenFound: [ :m | self fail: 'Unexpected target found' ];
		            whenMissing: [ :error | capturedError := error ];
		            yourself.
	resolver attemptResolve.
	self assert: capturedError class equals: ReplayMissingUIError.
	self assert: (capturedError messageText includesSubstring: 'Could not resolve UI target').
	self assert: (capturedError tag at: #path) equals: #( 2 ).
	availableChildren := capturedError tag at: #availableChildren.
	self assert: availableChildren size equals: 1.
	self assert: ((availableChildren first at: #class) = child class name)
]

{ #category : 'tests' }
ReplayUIPathResolverTest >> testMorphicResolverResolvesExistingPathWithoutDeferring [

	| root child resolver resolved |
	root := Morph new.
	child := Morph new.
	root addMorph: child.
	resolver := ReplayUIPathResolver new
		root: root;
		path: #( 1 );
		whenFound: [ :morph | resolved := morph ];
		whenMissing: [ :error | error signal ];
		yourself.

	resolver resolve.
	self assert: resolved equals: child.
	self assert: resolver attemptCount equals: 1
]

{ #category : 'tests' }
ReplayUIPathResolverTest >> testMorphicResolverWaitsOnlyUntilNextCycleForLateChild [

	| root child resolved resolver |
	root := Morph new.
	child := Morph new.
	resolver := ReplayUIPathResolver new
		root: root;
		path: #( 1 );
		whenFound: [ :morph | resolved := morph ];
		whenMissing: [ :error | error signal ];
		yourself.

	resolver resolve.
	self assert: resolved isNil.
	self assert: resolver attemptCount equals: 1.
	root addMorph: child.
	World doOneCycle.
	self assert: resolved equals: child.
	self assert: resolver attemptCount equals: 2
]

{ #category : 'tests' }
ReplayUIPathResolverTest >> testResolvedTargetFindsNestedMorph [

	| root child target resolver |
	root := Morph new.
	child := Morph new.
	target := Morph new.
	root addMorph: child.
	child addMorph: target.
	resolver := ReplayUIPathResolver new
		            root: root;
		            path: #( 1 1 );
		            yourself.
	self assert: resolver resolvedTarget == target
]

{ #category : 'tests' }
ReplayUIPathResolverTest >> testResolvedTargetReportsMissingChildren [

	| root resolver |
	root := Morph new.
	resolver := ReplayUIPathResolver new
		            root: root;
		            path: #( 1 );
		            yourself.
	self assert: resolver resolvedTarget isNil.
	self assert: (resolver lastFailure includesSubstring: 'has no submorphs')
]

{ #category : 'tests' }
ReplayUIPathResolverTest >> testResolvedTargetReportsOutOfRangeIndex [

	| root resolver |
	root := Morph new.
	root addMorph: Morph new.
	resolver := ReplayUIPathResolver new
		            root: root;
		            path: #( 2 );
		            yourself.
	self assert: resolver resolvedTarget isNil.
	self assert: (resolver lastFailure includesSubstring: 'Path index 2')
]

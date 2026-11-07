"
Tests for ReplayUIEditSession: the wrappers of the managed UI of an editor preview, which follow the order of the morphs they wrap, expose children and parents, highlight under the hand, and reference their morph.
"
Class {
	#name : 'ReplayUIEditSessionTest',
	#superclass : 'TestCase',
	#instVars : [
		'manager',
		'session',
		'root'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayUIEditSessionTest >> childIndexesOf: aWrapper [

	^ aWrapper submorphs collect: [ :each | each index ] as: Array
]

{ #category : 'running' }
ReplayUIEditSessionTest >> setUp [
	"A managed morph with three children, each with two children."

	super setUp.
	root := Morph new extent: 300 @ 100.
	1 to: 3 do: [ :index |
		| child |
		child := Morph new bounds: (index * 90 @ 10 extent: 80 @ 80).
		child addMorph: (Morph new bounds: (child topLeft extent: 10 @ 10)).
		child addMorphBack: (Morph new bounds: (child topLeft + 20 extent: 10 @ 10)).
		root addMorphBack: child ].
	manager := ReplayUIManager new manage: root.
	session := ReplayUIEditSession on: manager editor: nil
]

{ #category : 'tests' }
ReplayUIEditSessionTest >> testExposeChildrenAfterExposeParentRestoresOneWrapperPerChild [

	| rootWrapper |
	rootWrapper := session wrapMorph: root atDepth: 1.
	manager overlay addMorph: rootWrapper.

	session exposeParentMorph: rootWrapper submorphs second.
	self assert: (self childIndexesOf: rootWrapper) equals: #( 1 3 ).
	session exposeChildMorphs: rootWrapper.
	self assert: (self childIndexesOf: rootWrapper) equals: #( 1 2 3 ).
	session exposeChildMorphs: rootWrapper.
	self assert: (self childIndexesOf: rootWrapper) equals: #( 1 2 3 ).
	self assert: (self childIndexesOf: rootWrapper submorphs second) equals: #( 1 2 )
]

{ #category : 'tests' }
ReplayUIEditSessionTest >> testExposeChildrenWrapsUnwrappedChildren [

	| rootWrapper |
	rootWrapper := session wrapMorph: root atDepth: session maxWrapDepth.
	self assert: rootWrapper submorphs isEmpty.

	session exposeChildMorphs: rootWrapper.

	self assert: (self childIndexesOf: rootWrapper) equals: #( 1 2 3 ).
	self
		assert: (rootWrapper submorphs collect: [ :each | each wrappedMorph ] as: Array)
		equals: root submorphs asArray
]

{ #category : 'tests' }
ReplayUIEditSessionTest >> testExposeParentRemovesTheWrapperAndItsWrappers [

	| rootWrapper wrapper |
	rootWrapper := session wrapMorph: root atDepth: 1.
	wrapper := rootWrapper submorphs first.

	session exposeParentMorph: wrapper.

	self assert: wrapper owner isNil.
	self assert: wrapper submorphs size equals: 2.
	self assert: (self childIndexesOf: rootWrapper) equals: #( 2 3 )
]

{ #category : 'tests' }
ReplayUIEditSessionTest >> testExposeParentKeepsTheRootWrapper [

	| rootWrapper |
	rootWrapper := session wrapMorph: root atDepth: 1.
	manager overlay addMorph: rootWrapper.

	session exposeParentMorph: rootWrapper.

	self assert: rootWrapper owner identicalTo: manager overlay
]

{ #category : 'tests' }
ReplayUIEditSessionTest >> testWrappersFollowChildOrder [

	| rootWrapper |
	rootWrapper := session wrapMorph: root atDepth: 1.

	self assert: (self childIndexesOf: rootWrapper) equals: #( 1 2 3 ).
	self
		assert: (rootWrapper submorphs collect: [ :each | each wrappedMorph ] as: Array)
		equals: root submorphs asArray
]

{ #category : 'support' }
ReplayUIEditSessionTest >> enter: aWrapper from: aPoint [
	"Send aWrapper the mouse enter of a hand moving from aPoint to its center"

	| hand |
	hand := HandMorph new
		        privateOwner: self currentWorld;
		        yourself.
	aWrapper onMouseEnter: (MouseMoveEvent new
			 setType: #mouseEnter
			 startPoint: aPoint
			 endPoint: aWrapper center
			 trail: { aPoint. aWrapper center }
			 buttons: 0
			 hand: hand
			 stamp: Time millisecondClockValue)
]

{ #category : 'support' }
ReplayUIEditSessionTest >> openWrappedDuring: aBlock [
	"Open the managed UI, wrap it for edition, and evaluate aBlock with the root wrapper"

	[
		| rootWrapper |
		manager openLabeled: 'Replay wrapper test'.
		self currentWorld doOneCycle.
		rootWrapper := session wrapMorph: root atDepth: 1.
		manager overlay addMorph: rootWrapper.
		aBlock value: rootWrapper ] ensure: [ manager close ]
]

{ #category : 'tests' }
ReplayUIEditSessionTest >> testWrapperDoesNotTakeHighlightFromAnotherWrapper [
	"The wrapper the hand comes from passes the highlight on its mouse leave"

	self openWrappedDuring: [ :rootWrapper |
		| first second |
		first := rootWrapper submorphs first.
		second := rootWrapper submorphs second.
		self enter: first from: second center.
		self assert: first color isTransparent ]
]

{ #category : 'tests' }
ReplayUIEditSessionTest >> testWrapperHighlightsWhenEnteredFromItsOwner [

	self openWrappedDuring: [ :rootWrapper |
		| child |
		child := rootWrapper submorphs first.
		rootWrapper highlight.
		self enter: child from: rootWrapper topLeft + (5 @ 5).
		self deny: child color isTransparent.
		self assert: rootWrapper color isTransparent ]
]

{ #category : 'tests' }
ReplayUIEditSessionTest >> testWrapperHighlightsWhenEnteredFromOutside [

	self openWrappedDuring: [ :rootWrapper |
		| child |
		child := rootWrapper submorphs first.
		self enter: child from: rootWrapper topLeft - (20 @ 20).
		self deny: child color isTransparent ]
]

{ #category : 'tests' }
ReplayUIEditSessionTest >> testWrapperReferencesItsWrappedMorph [

	| rootWrapper wrapper resolved |
	rootWrapper := session wrapMorph: root atDepth: 1.
	wrapper := rootWrapper submorphs second submorphs first.

	self assert: wrapper reference equals: (ReplayUIReference morphicPath: #( 2 1 )).
	self assert: rootWrapper reference equals: (ReplayUIReference morphicPath: #(  )).
	manager resolver resolve: wrapper reference thenDo: [ :element | resolved := element ].
	self assert: resolved morph identicalTo: wrapper wrappedMorph.
	self assert: wrapper wrappedMorph identicalTo: (root submorphs second submorphs first)
]

{ #category : 'support' }
ReplayUIEditSessionTest >> leftClickOn: aWrapper [

	session
		onClick: (MouseButtonEvent new
				 setType: #mouseUp
				 position: aWrapper center
				 which: MouseEvent redButton
				 buttons: 0
				 hand: (HandMorph new
						  privateOwner: self currentWorld;
						  yourself)
				 stamp: Time millisecondClockValue)
		onWrapper: aWrapper
]

{ #category : 'tests' }
ReplayUIEditSessionTest >> testAddActionMenuTargetsTheWrappedMorph [

	| editor rootWrapper wrapper menu clickItem |
	editor := ReplayEditor new.
	session := ReplayUIEditSession on: manager editor: editor.
	rootWrapper := session wrapMorph: root atDepth: 1.
	wrapper := rootWrapper submorphs second.
	menu := session newAddActionMenuFor: wrapper.
	clickItem := menu menuGroups first menuItems detect: [ :item | item name = ReplayClick displayName ].

	clickItem performMenuActionWith: nil.

	self assert: editor currentAction class equals: ReplayClick.
	self assert: editor currentAction target equals: wrapper reference
]

{ #category : 'tests' }
ReplayUIEditSessionTest >> testLeftClickEvaluatesTheClickBlock [

	| rootWrapper clicked |
	rootWrapper := session wrapMorph: root atDepth: 1.
	session clickBlock: [ :event :wrapper | clicked := wrapper ].

	self leftClickOn: rootWrapper submorphs first.

	self assert: clicked identicalTo: rootWrapper submorphs first
]

{ #category : 'tests' }
ReplayUIEditSessionTest >> testWrapForEditionWrapsTheManagedMorphInTheOverlay [

	| rootWrapper |
	manager := ReplayUIManager new manage: root usingBackend: ReplayRecordingBackend new.
	session := ReplayUIEditSession on: manager editor: nil.
	session wrapForEdition.
	self assert: manager overlay submorphs isEmpty.

	manager backend runDeferredBlocks.

	rootWrapper := manager overlay submorphs first.
	self assert: rootWrapper wrappedMorph identicalTo: root.
	self assert: (self childIndexesOf: rootWrapper) equals: #( 1 2 3 )
]

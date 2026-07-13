"
I own the active Replay UI session: managed UI, backend, overlays, interaction policy, and recording wrappers.
"
Class {
	#name : 'ReplayUIManager',
	#superclass : 'Object',
	#instVars : [
		'root',
		'overlay',
		'managed',
		'managedPresenter',
		'backend',
		'editor',
		'clickBlock',
		'ownsUI',
		'interactionPolicy'
	],
	#category : 'Replay-Core',
	#package : 'Replay',
	#tag : 'Core'
}

{ #category : 'utilities' }
ReplayUIManager class >> buildMorphFromSpec: aSpecPresenter [
	"Build the Morphic content for a Spec presenter without embedding a nested Spec window."

	| presenter |
	aSpecPresenter isWindowPresenter
		ifTrue: [ presenter := aSpecPresenter ]
		ifFalse: [
			presenter := aSpecPresenter asWindow.
			presenter extent: aSpecPresenter extent ].
	presenter extent ifNil: [ presenter extent: presenter initialExtent ].
	^ SpBindings value: presenter application adapterBindings during: [
		| adapter widget container |
		adapter := presenter defaultLayout
			buildAdapterFor: presenter
			bindings: SpBindings value.
		presenter adapter: adapter.
		adapter widget extent: presenter extent.
		widget := presenter presenter buildWithLayout: presenter presenter layout.
		presenter presenter adapter applyStyle.
		container := adapter newContainerMorph.
		container
			layoutFrame: widget layoutFrame;
			extent: presenter extent.
		container addMorphBack: widget.
		widget
			hResizing: #spaceFill;
			vResizing: #spaceFill.
		adapter model hasStatusBar ifTrue: [ adapter addStatusBarTo: container ].
		adapter add: container toWindow: adapter widget.
		presenter updateTitle.
		container delete.
		container
			hResizing: #spaceFill;
			vResizing: #spaceFill;
			extent: presenter extent;
			layoutChanged;
			doLayoutIn: container bounds.
		container fullBounds.
		container ]
]

{ #category : 'managing UI' }
ReplayUIManager >> addOverlay: ui [

	overlay ifNotNil: [
		overlay addMorph: ui.
		self layoutAnnotations ]
]

{ #category : 'interaction policy' }
ReplayUIManager >> allowUserInteraction [

	self interactionPolicy: #passThrough
]

{ #category : 'annotation layout' }
ReplayUIManager >> annotationLabelMargin [

	^ 20
]

{ #category : 'annotation layout' }
ReplayUIManager >> annotationLayoutBounds [

	| world |
	overlay ifNil: [ ^ 0 @ 0 corner: 0 @ 0 ].
	world := overlay world.
	world ifNil: [ ^ overlay bounds ].
	^ world visibleClearArea
]

{ #category : 'annotation layout' }
ReplayUIManager >> annotationTargetBounds [

	^ self annotationsWithLabels collect: [ :annotation |
		annotation targetBoundsInWorld ]
]

{ #category : 'annotation layout' }
ReplayUIManager >> annotationsWithLabels [

	overlay ifNil: [ ^ #() ].
	^ overlay submorphs select: [ :each |
		(each isKindOf: ReplayAnnotation) and: [ each hasLabel ] ]
]

{ #category : 'managing UI' }
ReplayUIManager >> attachTo: aMorph [
	"Attach Replay to an existing Morph without taking ownership of its window."

	^ self attachTo: aMorph usingBackend: (ReplayMorphicBackend on: aMorph)
]

{ #category : 'managing UI' }
ReplayUIManager >> attachTo: aMorph usingBackend: aReplayUIBackend [
	"Attach Replay to a Morph that already belongs to another UI."

	| owner |
	owner := aMorph owner ifNil: [
		ReplayError new
			messageText: 'Cannot attach Replay Morph without an owner.';
			tag: aMorph;
			signal ].
	ownsUI := false.
	self allowUserInteraction.
	backend := aReplayUIBackend.
	managed := aMorph.
	root := owner.
	overlay := self newAttachedOverlay.
	overlay bounds: managed bounds.
	root addMorphFront: overlay.
	self syncManagedLayout.
	^ self
]

{ #category : 'managing UI' }
ReplayUIManager >> attachToPresenter: aSpecPresenter [
	"Attach Replay to an already rendered Spec presenter."

	| adapter morph |
	adapter := aSpecPresenter adapter ifNil: [
		ReplayError new
			messageText: 'Cannot attach Replay to a Spec presenter without an adapter.';
			tag: aSpecPresenter;
			signal ].
	morph := adapter widget ifNil: [
		ReplayError new
			messageText: 'Cannot attach Replay to a Spec presenter without a rendered widget.';
			tag: aSpecPresenter;
			signal ].
	^ self attachTo: morph usingBackend: (ReplaySpecBackend presenter: aSpecPresenter morph: morph)
]

{ #category : 'annotation layout' }
ReplayUIManager >> automaticLabelCandidatesFor: anAnnotation [

	| target extent margin centeredX centeredY |
	target := anAnnotation targetBoundsInWorld.
	extent := anAnnotation label extent.
	margin := self annotationLabelMargin.
	centeredX := target center x - (extent x / 2).
	centeredY := target center y - (extent y / 2).
	^ {
		(target right + margin @ centeredY extent: extent).
		(target left - extent x - margin @ centeredY extent: extent).
		(centeredX @ (target bottom + margin) extent: extent).
		(centeredX @ (target top - extent y - margin) extent: extent).
		(target right + margin @ (target bottom + margin) extent: extent).
		(target right + margin @ (target top - extent y - margin) extent: extent).
		(target left - extent x - margin @ (target bottom + margin) extent: extent).
		(target left - extent x - margin @ (target top - extent y - margin) extent: extent) }
]

{ #category : 'accessing' }
ReplayUIManager >> backend [

	^ backend
]

{ #category : 'accessing' }
ReplayUIManager >> backend: aReplayUIBackend [

	backend := aReplayUIBackend
]

{ #category : 'annotation layout' }
ReplayUIManager >> bestLabelBoundsFor: anAnnotation avoiding: placedBounds [

	| layoutBounds targetBounds bestBounds bestScore candidates |
	layoutBounds := self annotationLayoutBounds.
	targetBounds := anAnnotation targetBoundsInWorld.
	candidates := self labelCandidatesFor: anAnnotation.
	candidates withIndexDo: [ :rawBounds :index |
		| candidateBounds score |
		candidateBounds := self clampRectangle: rawBounds within: layoutBounds.
		score := self
			scoreLabelBounds: candidateBounds
			rawBounds: rawBounds
			target: targetBounds
			avoiding: placedBounds
			preference: index.
		(bestScore isNil or: [ score < bestScore ]) ifTrue: [
			bestScore := score.
			bestBounds := candidateBounds ] ].
	^ bestBounds
]

{ #category : 'interaction policy' }
ReplayUIManager >> blockUserInteraction [

	self interactionPolicy: #blocked
]

{ #category : 'testing' }
ReplayUIManager >> blocksUserInteraction [

	^ self interactionPolicy = #blocked
]

{ #category : 'annotation layout' }
ReplayUIManager >> clampRectangle: aRectangle within: containerBounds [

	| x y |
	containerBounds width >= aRectangle width
		ifTrue: [ x := (aRectangle left max: containerBounds left) min: containerBounds right - aRectangle width ]
		ifFalse: [ x := containerBounds left ].
	containerBounds height >= aRectangle height
		ifTrue: [ y := (aRectangle top max: containerBounds top) min: containerBounds bottom - aRectangle height ]
		ifFalse: [ y := containerBounds top ].
	^ x @ y extent: aRectangle extent
]

{ #category : 'managing UI' }
ReplayUIManager >> clearOverlay [

	overlay ifNotNil: [ overlay removeAllMorphs ]
]

{ #category : 'accessing' }
ReplayUIManager >> clickBlock: aBlock [
	"Event handler for left click with no key press.
	Can take 3 arguments: manager, event, wrapper morph."

	clickBlock := aBlock
]

{ #category : 'managing UI' }
ReplayUIManager >> close [

	self ownsUI
		ifTrue: [
			root ifNil: [ ^ self ].
			root window
				ifNotNil: [ :window | window close ]
				ifNil: [ root delete ] ]
		ifFalse: [
			overlay ifNotNil: [ overlay delete ].
			overlay := nil ]
]

{ #category : 'managing UI' }
ReplayUIManager >> defer: aBlock [

	backend
		ifNil: [ ReplayUIBackend new defer: aBlock ]
		ifNotNil: [ backend defer: aBlock ]
]

{ #category : 'annotation layout' }
ReplayUIManager >> distanceFrom: firstPoint to: secondPoint [

	^ (firstPoint x - secondPoint x) abs + (firstPoint y - secondPoint y) abs
]

{ #category : 'accessing' }
ReplayUIManager >> editor: aReplayEditor [

	editor := aReplayEditor
]

{ #category : 'managing UI' }
ReplayUIManager >> exposeChildMorphs: wrapper [
	"Create wrapper for submorphs.
	We compare with existing wrappers to only have one wrapper per child."

	| children wrappers wrapIndex |
	children := wrapper wrappedMorph submorphs.
	wrappers := wrapper submorphs.
	wrappers size = children size ifTrue: [ ^ self ].

	wrapIndex := 1.
	children withIndexDo: [ :child :index |
		((wrappers size between: 1 and: wrapIndex) and: [
			 (wrapper submorphs at: wrapIndex) index = index ])
			ifTrue: [ "Wrapper already exists" wrapIndex := wrapIndex + 1 ]
			ifFalse: [ "Wrap the child"
				wrapper addMorph:
					((self wrapMorph: child atDepth: 1) index: index)
				"asElementNumber: index" ] ]
]

{ #category : 'managing UI' }
ReplayUIManager >> exposeParentMorph: wrapper [
	"Remove the morph and all its submorphs.
	We make sure not to remove the root wrapper to keep the interactivity."

	(wrapper class == ReplayWrapperMorph and: [
		 wrapper owner class == ReplayWrapperMorph ]) ifFalse: [ ^ self ].
	wrapper owner highlight.
	wrapper allMorphsDo: [ :m | m delete ]
]

{ #category : 'managing UI' }
ReplayUIManager >> hideOverlay [
	"Elements are behind their predecessors, so the overlay is hidden by making it the last element"

	root submorphs first == managed ifTrue: [ ^ self ].
	root addMorphFront: managed
]

{ #category : 'annotation layout' }
ReplayUIManager >> initialAnnotationAvoidBounds [

	^ self annotationTargetBounds asOrderedCollection
]

{ #category : 'managing UI' }
ReplayUIManager >> installBlockingHandlersOn: aMorph [

	#( mouseDown mouseMove mouseStillDown mouseUp mouseEnter mouseLeave mouseEnterDragging mouseLeaveDragging doubleClick ) do: [ :event |
		aMorph on: event send: #yourself to: aMorph ]
]

{ #category : 'accessing' }
ReplayUIManager >> interactionPolicy [

	^ interactionPolicy ifNil: [ self ownsUI ifTrue: [ #blocked ] ifFalse: [ #passThrough ] ]
]

{ #category : 'accessing' }
ReplayUIManager >> interactionPolicy: aSymbol [

	interactionPolicy := aSymbol asSymbol
]

{ #category : 'annotation layout' }
ReplayUIManager >> labelBoundsFor: anAnnotation placement: placementSymbol [

	| target extent margin centeredX centeredY |
	target := anAnnotation targetBoundsInWorld.
	extent := anAnnotation label extent.
	margin := self annotationLabelMargin.
	centeredX := target center x - (extent x / 2).
	centeredY := target center y - (extent y / 2).
	placementSymbol = #right ifTrue: [ ^ target right + margin @ centeredY extent: extent ].
	placementSymbol = #left ifTrue: [ ^ target left - extent x - margin @ centeredY extent: extent ].
	placementSymbol = #below ifTrue: [ ^ centeredX @ (target bottom + margin) extent: extent ].
	placementSymbol = #above ifTrue: [ ^ centeredX @ (target top - extent y - margin) extent: extent ].
	placementSymbol = #belowRight ifTrue: [ ^ target right + margin @ (target bottom + margin) extent: extent ].
	placementSymbol = #aboveRight ifTrue: [ ^ target right + margin @ (target top - extent y - margin) extent: extent ].
	placementSymbol = #belowLeft ifTrue: [ ^ target left - extent x - margin @ (target bottom + margin) extent: extent ].
	placementSymbol = #aboveLeft ifTrue: [ ^ target left - extent x - margin @ (target top - extent y - margin) extent: extent ].
	^ (self automaticLabelCandidatesFor: anAnnotation) first
]

{ #category : 'annotation layout' }
ReplayUIManager >> labelCandidatesFor: anAnnotation [

	| preferred fallbackCandidates |
	anAnnotation placement = #automatic ifTrue: [
		^ self automaticLabelCandidatesFor: anAnnotation ].
	preferred := self labelBoundsFor: anAnnotation placement: anAnnotation placement.
	fallbackCandidates := self automaticLabelCandidatesFor: anAnnotation.
	^ { preferred } , (fallbackCandidates reject: [ :candidate |
		candidate origin = preferred origin and: [ candidate extent = preferred extent ] ])
]

{ #category : 'annotation layout' }
ReplayUIManager >> layoutAnnotations [

	| placedBounds |
	placedBounds := self initialAnnotationAvoidBounds.
	self annotationsWithLabels do: [ :annotation |
		| bestBounds |
		annotation ensureLabelInWorld.
		annotation label isInWorld ifTrue: [
			bestBounds := self bestLabelBoundsFor: annotation avoiding: placedBounds.
			annotation placeLabelAt: bestBounds origin.
			annotation step.
			placedBounds add: annotation label bounds ] ]
]

{ #category : 'managing UI' }
ReplayUIManager >> manage: aMorph [
	"Set a Morphic UI to be managed."

	^ self
		  manage: aMorph
		  usingBackend: (ReplayMorphicBackend on: aMorph)
]

{ #category : 'managing UI' }
ReplayUIManager >> manage: aMorph usingBackend: aReplayUIBackend [
	"Set UI backend to manage morph in full-window layout."

	ownsUI := true.
	self blockUserInteraction.
	backend := aReplayUIBackend.
	root := ReplayRootMorph new
		manager: self;
		color: Smalltalk ui theme windowColor;
		changeProportionalLayout;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		yourself.
	managed := aMorph.
	overlay := self newOverlay.
	root addMorph: managed fullFrame: LayoutFrame identity.
	root addMorph: overlay fullFrame: LayoutFrame identity.
	self blocksUserInteraction ifTrue: [ self installBlockingHandlersOn: overlay ].
	^ self
]

{ #category : 'managing UI' }
ReplayUIManager >> managePresenter: aSpecPresenter [
	"Manage a Spec presenter rendered as Morphic UI."

	| morph |
	morph := self class buildMorphFromSpec: aSpecPresenter.
	^ self
		  manage: morph
		  usingBackend: (ReplaySpecBackend presenter: aSpecPresenter morph: morph)
]

{ #category : 'accessing' }
ReplayUIManager >> managedPresenter [

	^ backend
		  ifNil: [ managedPresenter ]
		  ifNotNil: [ backend managedPresenter ]
]

{ #category : 'accessing' }
ReplayUIManager >> managedPresenter: aPresenter [
	"Compatibility hook for tests and scripts that inject a presenter directly."

	managedPresenter := aPresenter.
	backend := ReplaySpecBackend presenter: aPresenter morph: managed
]

{ #category : 'accessing' }
ReplayUIManager >> managedUI [

	^ backend
		  ifNil: [ managed ]
		  ifNotNil: [ backend managedUI ]
]

{ #category : 'accessing' }
ReplayUIManager >> managerOfUI [

	^ self managedUI
]

{ #category : 'accessing' }
ReplayUIManager >> maxWrapDepth [
	"How deep to wrap morphs on a single pass"

	^ 6 "6 plays nicely with Calypso?"
]

{ #category : 'managing UI' }
ReplayUIManager >> newAttachedOverlay [
	"Create an overlay for an existing UI owner. It must not participate in the owner's layout."

	^ self newOverlay
		hResizing: #rigid;
		vResizing: #rigid;
		disableTableLayout: true;
		yourself
]

{ #category : 'managing UI' }
ReplayUIManager >> newOverlay [

	^ Morph new
		beTransparent;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		yourself
]

{ #category : 'event handling' }
ReplayUIManager >> onClick: event onWrapper: morph [

	event yellowButtonChanged ifTrue: [ "right click"
		editor newMenu
			addItem: [ :item |
				item
					name: 'Add action (Click)';
					subMenu: (morph menuPresenterOn: editor) ];
			addItem: [ :item |
				item
					name: 'Expose children (Ctrl/Cmd+Click)';
					action: [ self exposeChildMorphs: morph ] ];
			addItem: [ :item |
				item
					name: 'Expose parent (Shift+Click)';
					action: [ self exposeParentMorph: morph ] ];
			addItem: [ :item |
				item
					name: 'Inspect (Alt/Opt+Click)';
					action: [ morph wrappedMorph inspect ] ];
			openWithSpecAtPointer ].

	event redButtonChanged ifFalse: [ ^ self ]. "left click"

	(event commandKeyPressed or: [ event controlKeyPressed ]) ifTrue: [
		^ self exposeChildMorphs: morph ].
	event shiftPressed ifTrue: [ ^ self exposeParentMorph: morph ].
	(event optionKeyPressed or: [ event altKeyPressed ]) ifTrue: [
		^ morph wrappedMorph inspect ].

	"regular click, execute the configured block if any, or open a menu with possible new actions"
	clickBlock ifNil: [
		^ (morph menuPresenterOn: editor) openWithSpecAtPointer ].
	clickBlock cull: event cull: morph
]

{ #category : 'instance creation' }
ReplayUIManager >> openLabeled: title [
	"Open managed UI using its natural extent and default Morphic placement."

	^ self
		openLabeled: title
		extent: nil
		bounds: nil
]

{ #category : 'instance creation' }
ReplayUIManager >> openLabeled: title extent: requestedExtent bounds: requestedBounds [
	"Open managed UI optionally controlling content extent or exact window bounds."

	| targetExtent window frameDelta contentExtent |
	targetExtent := requestedExtent ifNil: [
		requestedBounds
			ifNil: [ managed ifNil: [ root extent ] ifNotNil: [ managed extent ] ]
			ifNotNil: [ requestedBounds extent ] ].
	root extent: targetExtent.
	root openInWindowLabeled: title.
	window := root window.
	window ifNotNil: [
		frameDelta := window extent - root extent.
		requestedBounds
			ifNotNil: [
				window bounds: requestedBounds.
				contentExtent := (requestedBounds extent x - frameDelta x max: 1)
					@ (requestedBounds extent y - frameDelta y max: 1).
				root extent: contentExtent ]
			ifNil: [
				window extent: targetExtent + frameDelta.
				root extent: targetExtent ] ].
	self defer: [ self syncManagedLayout ]
]

{ #category : 'accessing' }
ReplayUIManager >> overlay [
	"The element that serves as a full overlay over the managed element.
	It also serves as a canvas for adding ui on top."

	^ overlay
]

{ #category : 'accessing' }
ReplayUIManager >> ownsUI [

	^ ownsUI ifNil: [ true ]
]

{ #category : 'resolving' }
ReplayUIManager >> resolve: aReference forAction: anAction thenDo: foundBlock onMissing: missingBlock [

	^ backend
		resolve: aReference
		forAction: anAction
		thenDo: foundBlock
		onMissing: missingBlock
]

{ #category : 'resolving' }
ReplayUIManager >> resolve: aReference thenDo: foundBlock [

	^ self
		resolve: aReference
		thenDo: foundBlock
		onMissing: [ :error | error signal ]
]

{ #category : 'resolving' }
ReplayUIManager >> resolve: aReference thenDo: foundBlock onMissing: missingBlock [

	^ self resolver
		resolve: aReference
		thenDo: foundBlock
		onMissing: missingBlock
]

{ #category : 'accessing' }
ReplayUIManager >> resolver [

	^ backend resolver
]

{ #category : 'annotation layout' }
ReplayUIManager >> scoreLabelBounds: candidateBounds rawBounds: rawBounds target: targetBounds avoiding: placedBounds preference: preferenceIndex [

	| score |
	score := preferenceIndex * 1000.
	score := score + ((self distanceFrom: rawBounds origin to: candidateBounds origin) * 100).
	(candidateBounds intersects: targetBounds) ifTrue: [ score := score + 100000 ].
	placedBounds do: [ :each |
		(candidateBounds intersects: each) ifTrue: [ score := score + 50000 ] ].
	score := score + (self distanceFrom: candidateBounds center to: targetBounds center).
	^ score
]

{ #category : 'managing UI' }
ReplayUIManager >> settleUI [

	backend
		ifNil: [ ReplayUIBackend new settleUI ]
		ifNotNil: [ backend settleUI ].
	self syncManagedLayout.
	self layoutAnnotations
]

{ #category : 'accessing' }
ReplayUIManager >> surfaceMorph [

	^ backend
		ifNil: [ managed ]
		ifNotNil: [ backend surfaceMorph ]
]

{ #category : 'managing UI' }
ReplayUIManager >> syncManagedLayout [
	"Keep managed content and overlay aligned."

	| targetExtent |
	(root isNil or: [ managed isNil or: [ overlay isNil ] ]) ifTrue: [ ^ self ].
	self ownsUI ifFalse: [
		overlay bounds: managed bounds.
		overlay layoutChanged.
		^ self ].
	targetExtent := root extent.
	targetExtent isZero ifTrue: [ ^ self ].
	managed extent: targetExtent.
	overlay extent: targetExtent.
	root layoutChanged.
	root doLayoutIn: root bounds.
	managed layoutChanged.
	managed doLayoutIn: managed bounds.
	managed fullBounds.
	overlay layoutChanged.
	overlay doLayoutIn: overlay bounds
]

{ #category : 'accessing' }
ReplayUIManager >> ui [
	"The root morph contains the managed morph and the overlay"

	^ root
]

{ #category : 'managing UI' }
ReplayUIManager >> wrapForEdition [
	"Called after managed UI initialized. Wrap all child elements to make them interactive in edition. Wait next UI cycle to ensure elements are in World."

	self defer: [ overlay addMorph: (self wrapMorph: managed atDepth: 1) ]
]

{ #category : 'managing UI' }
ReplayUIManager >> wrapMorph: morph atDepth: depth [

	| wrapper |
	(wrapper := ReplayWrapperMorph new)
		wrappedMorph: morph;
		bounds: (morph boundsIn: managed);
		setBalloonText: morph className;
		on: #mouseEnter send: #onMouseEnter: to: wrapper;
		on: #mouseLeave send: #onMouseLeave: to: wrapper;
		on: #mouseUp send: #onClick:onWrapper: to: self.

	depth >= self maxWrapDepth ifTrue: [ ^ wrapper ].

	morph submorphs withIndexDo: [ :child :index |
		wrapper addMorph:
			((self wrapMorph: child atDepth: depth + 1) index: index) ].
	^ wrapper
]

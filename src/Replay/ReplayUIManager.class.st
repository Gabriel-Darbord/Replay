"
I own the active Replay UI session: the managed UI, its backend, which resolves targets and runs actions, and the overlay where Replay draws annotations over the UI.

I either own the UI (`manage:`, `managePresenter:`), and then open it in a window (`openLabeled:placement:`), close that window when closed and block user interaction with the overlay; or I attach an overlay to existing UI (`attachTo:`) or only observe it (`observe:`), and then closing only removes what I added and user interaction goes through.

The labels of the annotations in my overlay are placed by a ReplayAnnotationLayout. Editor previews make my UI interactive with a ReplayUIEditSession.
"
Class {
	#name : 'ReplayUIManager',
	#superclass : 'Object',
	#instVars : [
		'root',
		'overlay',
		'managed',
		'backend',
		'ownsUI'
	],
	#category : 'Replay-Core',
	#package : 'Replay',
	#tag : 'Core'
}

{ #category : 'instance creation' }
ReplayUIManager class >> backendObserving: aMorph [
	"A backend for aMorph observed as it is: the Spec backend of the presenter of a Spec window, so that its subpresenters resolve by name, or else the Morphic backend"

	| model |
	aMorph isSystemWindow ifFalse: [ ^ ReplayMorphicBackend on: aMorph ].
	model := aMorph model.
	(model isPresenter and: [ model isWindowPresenter and: [ model presenter isNotNil ] ])
		ifFalse: [ ^ ReplayMorphicBackend on: aMorph ].
	^ ReplaySpecBackend presenter: model presenter morph: aMorph
]

{ #category : 'managing UI' }
ReplayUIManager >> addOverlay: ui [

	overlay ifNotNil: [
		overlay addMorph: ui.
		self layoutAnnotations ]
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
			subject: aMorph;
			signal ].
	ownsUI := false.
	backend := aReplayUIBackend.
	managed := aMorph.
	root := owner.
	overlay := self newAttachedOverlay.
	overlay bounds: managed bounds.
	root addMorphFront: overlay.
	self syncManagedLayout
]

{ #category : 'managing UI' }
ReplayUIManager >> attachToPresenter: aSpecPresenter [
	"Attach Replay to an already rendered Spec presenter."

	| adapter morph |
	adapter := aSpecPresenter adapter ifNil: [
		ReplayError new
			messageText: 'Cannot attach Replay to a Spec presenter without an adapter.';
			subject: aSpecPresenter;
			signal ].
	morph := adapter widget ifNil: [
		ReplayError new
			messageText: 'Cannot attach Replay to a Spec presenter without a rendered widget.';
			subject: aSpecPresenter;
			signal ].
	^ self attachTo: morph usingBackend: (ReplaySpecBackend presenter: aSpecPresenter morph: morph)
]

{ #category : 'accessing' }
ReplayUIManager >> backend [
	"Answer the UI backend, or a default one when no UI is managed."

	^ backend ifNil: [ ReplayUIBackend new ]
]

{ #category : 'accessing' }
ReplayUIManager >> backend: aReplayUIBackend [

	backend := aReplayUIBackend
]

{ #category : 'testing' }
ReplayUIManager >> blocksUserInteraction [
	"Owned UI is only driven by the scenario, the overlay blocks user interaction. Attached or observed UI lets the user interact."

	^ self ownsUI
]

{ #category : 'managing UI' }
ReplayUIManager >> clearOverlay [

	overlay ifNotNil: [ overlay removeAllMorphs ]
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

	self backend defer: aBlock
]

{ #category : 'managing UI' }
ReplayUIManager >> installBlockingHandlersOn: aMorph [

	#( mouseDown mouseMove mouseStillDown mouseUp mouseEnter mouseLeave mouseEnterDragging mouseLeaveDragging doubleClick ) do: [ :event |
		aMorph on: event send: #yourself to: aMorph ]
]

{ #category : 'annotations' }
ReplayUIManager >> layoutAnnotations [
	"Place the labels of the annotations of my overlay"

	overlay ifNotNil: [ (ReplayAnnotationLayout on: overlay) layoutAnnotations ]
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
	self installBlockingHandlersOn: overlay
]

{ #category : 'managing UI' }
ReplayUIManager >> managePresenter: aSpecPresenter [
	"Manage a Spec presenter rendered as Morphic UI."

	| morph |
	morph := ReplaySpecBackend buildMorphFromSpec: aSpecPresenter.
	^ self
		  manage: morph
		  usingBackend: (ReplaySpecBackend presenter: aSpecPresenter morph: morph)
]

{ #category : 'accessing' }
ReplayUIManager >> managedMorph [
	"The morph of the managed UI, that my overlay covers"

	^ managed
]

{ #category : 'accessing' }
ReplayUIManager >> managedPresenter [

	^ self backend managedPresenter
]

{ #category : 'accessing' }
ReplayUIManager >> managedUI [

	^ self backend managedUI
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

	^ ReplayOverlayMorph new
]

{ #category : 'managing UI' }
ReplayUIManager >> observe: aMorph [
	"Observe an existing Morph without adding an overlay. This is for passive event recording where user interaction must continue normally."
	^ self observe: aMorph usingBackend: (self class backendObserving: aMorph)
]

{ #category : 'managing UI' }
ReplayUIManager >> observe: aMorph usingBackend: aReplayUIBackend [
	"Observe an existing UI without creating an overlay or taking ownership. Root morphs such as World can be observed directly."
	ownsUI := false.
	backend := aReplayUIBackend.
	managed := aMorph.
	root := aMorph owner ifNil: [ aMorph ].
	overlay := nil
]

{ #category : 'instance creation' }
ReplayUIManager >> openLabeled: title [
	"Open managed UI using its natural extent and default Morphic placement."

	^ self openLabeled: title placement: nil
]

{ #category : 'instance creation' }
ReplayUIManager >> openLabeled: title placement: aReplayPlacement [
	"Open managed UI in a window. The placement, if any, requests the window position,
	the content extent, or the exact window bounds."

	| requestedBounds targetExtent window frameDelta contentExtent |
	requestedBounds := aReplayPlacement ifNotNil: [ aReplayPlacement bounds ].
	targetExtent := requestedBounds
		ifNil: [
			(aReplayPlacement ifNotNil: [ aReplayPlacement extent ]) ifNil: [
				managed ifNil: [ root extent ] ifNotNil: [ managed extent ] ] ]
		ifNotNil: [ requestedBounds extent ].
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
				root extent: targetExtent.
				aReplayPlacement ifNotNil: [
					aReplayPlacement position ifNotNil: [ :point |
						window position: point ] ] ] ].
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
ReplayUIManager >> resolve: aReference forAction: anAction readyWhen: readyBlock thenDo: foundBlock onMissing: missingBlock [

	^ self backend
		  resolve: aReference
		  forAction: anAction
		  readyWhen: readyBlock
		  thenDo: foundBlock
		  onMissing: missingBlock
]

{ #category : 'resolving' }
ReplayUIManager >> resolve: aReference forAction: anAction thenDo: foundBlock onMissing: missingBlock [

	^ self backend
		resolve: aReference
		forAction: anAction
		thenDo: foundBlock
		onMissing: missingBlock
]

{ #category : 'accessing' }
ReplayUIManager >> resolver [

	^ self backend resolver
]

{ #category : 'managing UI' }
ReplayUIManager >> settleUI [

	self backend settleUI.
	self syncManagedLayout.
	self layoutAnnotations
]

{ #category : 'accessing' }
ReplayUIManager >> surfaceMorph [

	^ self backend surfaceMorph
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

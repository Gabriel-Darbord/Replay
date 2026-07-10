"
I am responsible for managing a UI.
To accomplish this, I create a root element that contains the UI and an overlay to display elements on top of it.
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
		'clickBlock'
	],
	#category : 'Replay',
	#package : 'Replay'
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

	overlay addMorph: ui
]

{ #category : 'accessing' }
ReplayUIManager >> backend [

	^ backend
]

{ #category : 'accessing' }
ReplayUIManager >> backend: aReplayUIBackend [

	backend := aReplayUIBackend
]

{ #category : 'managing UI' }
ReplayUIManager >> clearOverlay [

	overlay removeAllMorphs
]

{ #category : 'accessing' }
ReplayUIManager >> clickBlock: aBlock [
	"Event handler for left click with no key press.
	Can take 3 arguments: manager, event, wrapper morph."

	clickBlock := aBlock
]

{ #category : 'managing UI' }
ReplayUIManager >> close [

	root window
		ifNotNil: [ :window | window close ]
		ifNil: [ root delete ]
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

{ #category : 'managing UI' }
ReplayUIManager >> manage: aMorph [
	"Set a Morphic UI to be managed."

	^ self
		  manage: aMorph
		  usingBackend: (ReplayMorphicBackend on: aMorph)
]

{ #category : 'managing UI' }
ReplayUIManager >> manage: aMorph usingBackend: aReplayUIBackend [
	"Set the UI backend and manage the morph in a full-window layout."

	backend := aReplayUIBackend.
	root := ReplayRootMorph new
		manager: self;
		color: Smalltalk ui theme windowColor;
		changeProportionalLayout;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		yourself.
	managed := aMorph.
	overlay := Morph new
		beTransparent;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		yourself.
	root addMorph: managed fullFrame: LayoutFrame identity.
	root addMorph: overlay fullFrame: LayoutFrame identity.
	"Prevent direct interaction with the managed UI by catching all events."
	#( mouseDown mouseMove mouseStillDown mouseUp mouseEnter mouseLeave mouseEnterDragging mouseLeaveDragging doubleClick ) do: [ :event |
		overlay on: event send: #yourself to: overlay ].
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
	"Open managed UI and optionally control content extent and exact window bounds."

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

	self currentWorld defer: [ self syncManagedLayout ]
]

{ #category : 'accessing' }
ReplayUIManager >> overlay [
	"The element that serves as a full overlay over the managed element.
	It also serves as a canvas for adding ui on top."

	^ overlay
]

{ #category : 'managing UI' }
ReplayUIManager >> syncManagedLayout [
	"Keep managed content and overlay aligned with the root extent."

	| targetExtent |
	(root isNil or: [ managed isNil or: [ overlay isNil ] ]) ifTrue: [
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
	overlay doLayoutIn: overlay bounds.
	^ self
]

{ #category : 'accessing' }
ReplayUIManager >> ui [
	"The root morph contains the managed morph and the overlay"

	^ root
]

{ #category : 'managing UI' }
ReplayUIManager >> wrapForEdition [
	"Called after the managed UI has been initialized.
	Wraps all child elements to make them interactive for edition.
	Wait for the next UI cycle to ensure the elements are in the World."

	self currentWorld defer: [
		overlay addMorph: (self wrapMorph: managed atDepth: 1) ]
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

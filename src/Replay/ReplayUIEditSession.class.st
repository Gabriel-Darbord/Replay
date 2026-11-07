"
I make the UI of an editor preview, managed by a ReplayUIManager, interactive for editing a scenario. I wrap the morphs of the managed UI with ReplayWrapperMorph in the overlay of the manager, nesting wrappers like the morphs they wrap, down to maxWrapDepth on a single pass.

Clicking a wrapper:
- left click: evaluates my click block, which the action editor sets to choose a target, or else shows a menu that adds an action targeting the wrapped morph to the scenario editor;
- Ctrl/Cmd + click: exposes the children of the wrapped morph;
- Shift + click: removes the wrapper to expose its parent;
- Alt/Option + click: inspects the wrapped morph;
- right click: a menu with all of the above.

I only live as long as the preview: the manager keeps owning the UI.
"
Class {
	#name : 'ReplayUIEditSession',
	#superclass : 'Object',
	#instVars : [
		'manager',
		'editor',
		'clickBlock'
	],
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'instance creation' }
ReplayUIEditSession class >> on: aReplayUIManager editor: aReplayEditor [
	"aReplayEditor receives the actions added from the menus of the wrappers. It can be nil when no menu is used."

	^ self new
		  setManager: aReplayUIManager editor: aReplayEditor;
		  yourself
]

{ #category : 'wrapping' }
ReplayUIEditSession >> addWrapper: childWrapper to: wrapper [
	"Insert the child wrapper before the first wrapper of a later child, so wrappers stack like the children they wrap."

	wrapper submorphs
		detect: [ :each | each index > childWrapper index ]
		ifFound: [ :next | wrapper addMorph: childWrapper inFrontOf: next ]
		ifNone: [ wrapper addMorphBack: childWrapper ]
]

{ #category : 'accessing' }
ReplayUIEditSession >> clickBlock: aBlock [
	"Evaluated on a left click on a wrapper, without modifier key, with the event and the wrapper (it can take fewer arguments)"

	clickBlock := aBlock
]

{ #category : 'wrapping' }
ReplayUIEditSession >> exposeChildMorphs: wrapper [
	"Create wrappers for the submorphs that have none, keeping one wrapper per child.
	Wrappers are kept in the same order as the children they wrap."

	| wrappedIndexes |
	wrappedIndexes := wrapper submorphs collect: [ :each | each index ] as: Set.
	wrapper wrappedMorph submorphs withIndexDo: [ :child :index |
		(wrappedIndexes includes: index) ifFalse: [
			self
				addWrapper: ((self wrapMorph: child atDepth: 1) index: index)
				to: wrapper ] ]
]

{ #category : 'wrapping' }
ReplayUIEditSession >> exposeParentMorph: wrapper [
	"Remove the wrapper with its own wrappers to expose the parent wrapper.
	The root wrapper is never removed, to keep the UI interactive."

	(wrapper class == ReplayWrapperMorph and: [
		 wrapper owner class == ReplayWrapperMorph ]) ifFalse: [ ^ self ].
	wrapper owner highlight.
	wrapper delete
]

{ #category : 'accessing' }
ReplayUIEditSession >> manager [

	^ manager
]

{ #category : 'accessing' }
ReplayUIEditSession >> maxWrapDepth [
	"How deep to wrap morphs on a single pass"

	^ 6 "6 plays nicely with Calypso?"
]

{ #category : 'menus' }
ReplayUIEditSession >> newAddActionMenuFor: wrapper [
	"A menu that adds an action targeting the morph of wrapper after the current action of my editor"

	| menu |
	menu := SpMenuPresenter new.
	ReplayAction actionsForMenu do: [ :actionClass |
		menu addItem: [ :item |
			item
				name: actionClass displayName;
				action: [
					editor
						addAction: (actionClass target: (self referenceFor: wrapper))
						after: editor currentAction ] ] ].
	^ menu
]

{ #category : 'accessing' }
ReplayUIEditSession >> referenceFor: aWrapperMorph [
	"A reference to the morph wrapped by aWrapperMorph: its semantic name when it has one, which survives layout changes, or else its Morphic path"

	^ (aWrapperMorph wrappedMorph ifNotNil: [ :morph | manager backend nameOfMorph: morph ])
		  ifNil: [ aWrapperMorph reference ]
		  ifNotNil: [ :name | ReplayUIReference named: name ]
]

{ #category : 'event handling' }
ReplayUIEditSession >> onClick: event onWrapper: wrapper [

	event yellowButtonChanged ifTrue: [ "right click"
		SpMenuPresenter new
			addItem: [ :item |
				item
					name: 'Add action (Click)';
					subMenu: (self newAddActionMenuFor: wrapper) ];
			addItem: [ :item |
				item
					name: 'Expose children (Ctrl/Cmd+Click)';
					action: [ self exposeChildMorphs: wrapper ] ];
			addItem: [ :item |
				item
					name: 'Expose parent (Shift+Click)';
					action: [ self exposeParentMorph: wrapper ] ];
			addItem: [ :item |
				item
					name: 'Inspect (Alt/Opt+Click)';
					action: [ wrapper wrappedMorph inspect ] ];
			openWithSpecAtPointer ].

	event redButtonChanged ifFalse: [ ^ self ]. "left click"

	(event commandKeyPressed or: [ event controlKeyPressed ]) ifTrue: [
		^ self exposeChildMorphs: wrapper ].
	event shiftPressed ifTrue: [ ^ self exposeParentMorph: wrapper ].
	(event optionKeyPressed or: [ event altKeyPressed ]) ifTrue: [
		^ wrapper wrappedMorph inspect ].

	"Regular click: evaluate the click block if any, or open a menu that adds an action"
	clickBlock ifNil: [
		^ (self newAddActionMenuFor: wrapper) openWithSpecAtPointer ].
	clickBlock cull: event cull: wrapper
]

{ #category : 'initialization' }
ReplayUIEditSession >> setManager: aReplayUIManager editor: aReplayEditor [

	manager := aReplayUIManager.
	editor := aReplayEditor
]

{ #category : 'wrapping' }
ReplayUIEditSession >> wrapForEdition [
	"Wrap the managed UI once it is initialized: wait for the next UI cycle, so that its morphs are in the World."

	manager defer: [ manager overlay addMorph: (self wrapMorph: manager managedMorph atDepth: 1) ]
]

{ #category : 'wrapping' }
ReplayUIEditSession >> wrapMorph: morph atDepth: depth [

	| wrapper |
	(wrapper := ReplayWrapperMorph new)
		wrappedMorph: morph;
		bounds: (morph boundsIn: manager managedMorph);
		setBalloonText: morph className;
		on: #mouseEnter send: #onMouseEnter: to: wrapper;
		on: #mouseLeave send: #onMouseLeave: to: wrapper;
		on: #mouseUp send: #onClick:onWrapper: to: self.

	depth >= self maxWrapDepth ifTrue: [ ^ wrapper ].

	morph submorphs withIndexDo: [ :child :index |
		self
			addWrapper: ((self wrapMorph: child atDepth: depth + 1) index: index)
			to: wrapper ].
	^ wrapper
]

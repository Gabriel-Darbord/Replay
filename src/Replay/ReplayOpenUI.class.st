"
I am responsible for opening a UI.
"
Class {
	#name : 'ReplayOpenUI',
	#superclass : 'ReplayUIAction',
	#instVars : [
		'extent',
		'bounds'
	],
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'testing' }
ReplayOpenUI class >> isAbstract [

	^ self == ReplayOpenUI
]

{ #category : 'accessing' }
ReplayOpenUI >> bounds [
	"Answer the requested window bounds, or nil to let Morphic place the window."

	^ bounds
]

{ #category : 'accessing' }
ReplayOpenUI >> bounds: aRectangle [
	"Set the requested window bounds. Nil lets Morphic place the window."

	bounds := aRectangle
]

{ #category : 'editing' }
ReplayOpenUI >> boundsBottom: aNumber [

	| current |
	current := self boundsForEditing.
	self bounds: (current topLeft corner: current right @ aNumber asNumber)
]

{ #category : 'editing' }
ReplayOpenUI >> boundsForEditing [

	^ self bounds ifNil: [ 100 @ 100 extent: self extentForEditing ]
]

{ #category : 'editing' }
ReplayOpenUI >> boundsLeft: aNumber [

	| current |
	current := self boundsForEditing.
	self bounds: (aNumber asNumber @ current top corner: current bottomRight)
]

{ #category : 'editing' }
ReplayOpenUI >> boundsPresenterOn: editor [

	| current |
	current := self boundsForEditing.
	^ SpBoxLayout newTopToBottom
		add: 'Bounds:' expand: false;
		add: (SpBoxLayout newLeftToRight
				spacing: 8;
				add: 'Left' expand: false;
				add: (self numberPresenterOn: editor named: 'bounds left' value: current left update: [ :number |
						self boundsLeft: number ]);
				add: 'Top' expand: false;
				add: (self numberPresenterOn: editor named: 'bounds top' value: current top update: [ :number |
						self boundsTop: number ]);
				yourself)
		expand: false;
		add: (SpBoxLayout newLeftToRight
				spacing: 8;
				add: 'Right' expand: false;
				add: (self numberPresenterOn: editor named: 'bounds right' value: current right update: [ :number |
						self boundsRight: number ]);
				add: 'Bottom' expand: false;
				add: (self numberPresenterOn: editor named: 'bounds bottom' value: current bottom update: [ :number |
						self boundsBottom: number ]);
				yourself)
		expand: false;
		yourself
]

{ #category : 'editing' }
ReplayOpenUI >> boundsRight: aNumber [

	| current |
	current := self boundsForEditing.
	self bounds: (current topLeft corner: aNumber asNumber @ current bottom)
]

{ #category : 'editing' }
ReplayOpenUI >> boundsTop: aNumber [

	| current |
	current := self boundsForEditing.
	self bounds: (current left @ aNumber asNumber corner: current bottomRight)
]

{ #category : 'editing' }
ReplayOpenUI >> clearPlacement [
	"Forget explicit size and placement requests."

	extent := nil.
	bounds := nil
]

{ #category : 'editing' }
ReplayOpenUI >> defaultExtent [

	^ 800 @ 600
]

{ #category : 'accessing' }
ReplayOpenUI >> extent [
	"Answer the requested managed UI extent, or nil to keep the UI's natural extent."

	^ extent
]

{ #category : 'accessing' }
ReplayOpenUI >> extent: aPoint [
	"Set the requested managed UI extent. Nil keeps the UI's natural extent."

	extent := aPoint
]

{ #category : 'editing' }
ReplayOpenUI >> extentForEditing [

	^ self extent ifNil: [ self defaultExtent ]
]

{ #category : 'editing' }
ReplayOpenUI >> extentHeight: aNumber [

	| current |
	current := self extentForEditing.
	self extent: current x @ aNumber asNumber
]

{ #category : 'editing' }
ReplayOpenUI >> extentPresenterOn: editor [

	| current |
	current := self extentForEditing.
	^ SpBoxLayout newTopToBottom
		add: 'Extent:' expand: false;
		add: (SpBoxLayout newLeftToRight
				spacing: 8;
				add: 'Width' expand: false;
				add: (self numberPresenterOn: editor named: 'extent width' value: current x update: [ :number |
						self extentWidth: number ]);
				add: 'Height' expand: false;
				add: (self numberPresenterOn: editor named: 'extent height' value: current y update: [ :number |
						self extentHeight: number ]);
				yourself)
		expand: false;
		yourself
]

{ #category : 'editing' }
ReplayOpenUI >> extentWidth: aNumber [

	| current |
	current := self extentForEditing.
	self extent: aNumber asNumber @ current y
]

{ #category : 'testing' }
ReplayOpenUI >> isUIOpener [

	^ true
]

{ #category : 'editing' }
ReplayOpenUI >> numberPresenterOn: editor named: targetName value: value update: updateBlock [

	| input |
	(input := editor newNumberInput)
		numberType: Float;
		number: value;
		whenNumberChangedDo: [ :number |
			updateBlock value: number.
			editor actions rebuildLayout ].
	editor registerReplayPresenter: input named: 'Action ' , targetName.
	editor registerReplayPresenter: input named: self class displayName , ' ' , targetName.
	^ input
]

{ #category : 'editing' }
ReplayOpenUI >> placementPresenterOn: editor [

	| clearButton |
	clearButton := editor newButton
		label: 'Clear placement';
		action: [
			self clearPlacement.
			editor actions rebuildLayout ];
		yourself.
	editor registerReplayPresenter: clearButton named: 'Action clear placement'.
	editor registerReplayPresenter: clearButton named: self class displayName , ' clear placement'.
	^ SpBoxLayout newTopToBottom
		spacing: 10;
		add: (self extentPresenterOn: editor) expand: false;
		add: (self boundsPresenterOn: editor) expand: false;
		add: clearButton expand: false;
		yourself
]

{ #category : 'running' }
ReplayOpenUI >> runOn: runner [

	| manager |
	manager := self uiManagerOn: runner.
	runner manager: manager.
	manager
		openLabeled: runner scenario title
		extent: self extent
		bounds: self bounds
]

{ #category : 'editing' }
ReplayOpenUI >> uiEditionPresenterOn: editor [

	| manager |
	manager := (self uiManagerOn: ReplayRunner new) editor: editor.
	manager wrapForEdition.
	^ editor newMorph morph: manager ui
]

{ #category : 'running' }
ReplayOpenUI >> uiManagerOn: runner [

	^ ReplayUIManager new manage: (self uiOn: runner)
]

{ #category : 'managing UI' }
ReplayOpenUI >> uiOn: runner [
	"Return the configured UI as a Morph"

	self subclassResponsibility
]

{ #category : 'accessing' }
ReplayOpenUI >> uiViewName [

	^ 'Add UI interaction'
]

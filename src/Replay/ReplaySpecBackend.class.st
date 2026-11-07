"
I adapt Replay UI management and target resolution for Spec presenters rendered through Morphic: my presenter is the managed presenter, which exposes semantic names, and my morph, its rendered widget, is the managed UI. The native element of targets resolved by name is their presenter.

buildMorphFromSpec: renders a Spec presenter as the Morphic content of a window, without the window, so that a ReplayUIManager can manage it.
"
Class {
	#name : 'ReplaySpecBackend',
	#superclass : 'ReplayUIBackend',
	#instVars : [
		'presenter',
		'morph'
	],
	#category : 'Replay-Backends',
	#package : 'Replay',
	#tag : 'Backends'
}

{ #category : 'building' }
ReplaySpecBackend class >> buildMorphFromSpec: aSpecPresenter [
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

{ #category : 'instance creation' }
ReplaySpecBackend class >> presenter: aSpecPresenter morph: aMorph [

	^ self new
		  presenter: aSpecPresenter;
		  morph: aMorph;
		  yourself
]

{ #category : 'accessing' }
ReplaySpecBackend >> managedPresenter [

	^ presenter
]

{ #category : 'accessing' }
ReplaySpecBackend >> managedUI [

	^ morph
]

{ #category : 'accessing' }
ReplaySpecBackend >> morph [

	^ morph
]

{ #category : 'accessing' }
ReplaySpecBackend >> morph: aMorph [

	morph := aMorph
]

{ #category : 'accessing' }
ReplaySpecBackend >> presenter [

	^ presenter
]

{ #category : 'accessing' }
ReplaySpecBackend >> presenter: aSpecPresenter [

	presenter := aSpecPresenter
]

{ #category : 'resolving' }
ReplaySpecBackend >> presenterNamed: aString ifAbsent: absentBlock [

	presenter ifNil: [ ^ absentBlock value ].
	^ presenter replayPresenterAt: aString ifAbsent: absentBlock
]

{ #category : 'accessing' }
ReplaySpecBackend >> resolver [

	^ ReplaySpecResolver on: self
]

{ #category : 'accessing' }
ReplaySpecBackend >> semanticScriptReceiver [

	^ presenter
]

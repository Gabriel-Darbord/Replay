"
Headless tests for Replay UI backend selection.
"
Class {
	#name : 'ReplayUIBackendTest',
	#superclass : 'TestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'tests' }
ReplayUIBackendTest >> testClearAnnotationsActionEditionPresenterBuilds [

	| presenter |
	presenter := ReplayClearAnnotations new editionPresenterOn: ReplayEditor new.

	self assert: presenter notNil
]

{ #category : 'tests' }
ReplayUIBackendTest >> testClearAnnotationsActionRemovesOverlayMorphs [

	| manager runner marker |
	manager := ReplayUIManager new manage: (Morph new extent: 100 @ 50).
	runner := ReplayRunner new manager: manager.
	marker := Morph new extent: 10 @ 10.
	manager addOverlay: marker.

	self assert: manager overlay submorphs size equals: 1.
	ReplayClearAnnotations new runOn: runner.
	self assert: manager overlay submorphs isEmpty
]

{ #category : 'tests' }
ReplayUIBackendTest >> testManagedMorphAndOverlayResizeWithRootWindow [

	| manager morph resizedExtent window |
	morph := Morph new extent: 100 @ 50.
	manager := ReplayUIManager new manage: morph.
	resizedExtent := 300 @ 160.

	[
		manager openLabeled: 'Replay resize test'.
		World doOneCycle.
		window := manager managedUI owner owner.
		window extent: resizedExtent.
		World doOneCycle.
		self assert: manager managedUI extent equals: manager overlay extent.
		self assert: manager managedUI extent x > 250.
		self assert: manager managedUI extent y > 120 ]
		ensure: [ manager close ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testManagingMorphUsesMorphicBackend [

	| manager morph |
	morph := Morph new.
	manager := ReplayUIManager new manage: morph; yourself.
	self assert: manager backend class equals: ReplayMorphicBackend.
	self assert: manager backend managedUI equals: morph.
	self assert: manager managedUI equals: morph.
	self assert: manager managedPresenter isNil
]

{ #category : 'tests' }
ReplayUIBackendTest >> testManagingPresenterUsesSpecBackend [

	| manager presenter |
	presenter := ReplayEditor new.
	manager := ReplayUIManager new managePresenter: presenter; yourself.
	self assert: manager backend class equals: ReplaySpecBackend.
	self assert: manager backend managedPresenter equals: presenter.
	self assert: manager managedPresenter equals: presenter.
	self assert: manager managedUI isMorph
]

{ #category : 'tests' }
ReplayUIBackendTest >> testMorphicBackendHasNoSemanticScriptReceiverByDefault [

	| backend |
	backend := ReplayMorphicBackend on: Morph new.
	self assert: backend semanticScriptReceiver isNil
]

{ #category : 'tests' }
ReplayUIBackendTest >> testOpenLabeledAppliesRequestedContentExtent [

	| manager morph requestedExtent |
	morph := Morph new extent: 100 @ 50.
	requestedExtent := 420 @ 180.
	manager := ReplayUIManager new manage: morph.

	[
		manager
			openLabeled: 'Replay requested extent test'
			extent: requestedExtent
			bounds: nil.
		20 timesRepeat: [ World doOneCycle. (Delay forMilliseconds: 10) wait ].
		self assert: manager ui extent equals: requestedExtent.
		self assert: manager managedUI extent equals: requestedExtent.
		self assert: manager overlay extent equals: requestedExtent ]
		ensure: [ manager close ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testOpenLabeledAppliesRequestedWindowBounds [

	| manager morph requestedBounds window |
	morph := Morph new extent: 100 @ 50.
	requestedBounds := 80 @ 90 extent: 480 @ 260.
	manager := ReplayUIManager new manage: morph.

	[
		manager
			openLabeled: 'Replay requested bounds test'
			extent: nil
			bounds: requestedBounds.
		20 timesRepeat: [ World doOneCycle. (Delay forMilliseconds: 10) wait ].
		window := manager ui window.
		self assert: window bounds origin equals: requestedBounds origin.
		self assert: window bounds extent equals: requestedBounds extent.
		self assert: manager managedUI extent equals: manager overlay extent ]
		ensure: [ manager close ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testOpenLabeledPreservesManagedContentExtent [

	| manager morph targetExtent |
	targetExtent := 321.0 @ 123.0.
	morph := Morph new extent: targetExtent.
	manager := ReplayUIManager new manage: morph.

	[
		manager openLabeled: 'Replay preserved extent test'.
		20 timesRepeat: [ World doOneCycle. (Delay forMilliseconds: 10) wait ].
		self assert: manager ui extent equals: targetExtent.
		self assert: manager managedUI extent equals: targetExtent.
		self assert: manager overlay extent equals: targetExtent.
		self assert: manager ui window extent x >= targetExtent x.
		self assert: manager ui window extent y >= targetExtent y ]
		ensure: [ manager close ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecBackendUsesPresenterAsSemanticScriptReceiver [

	| presenter backend |
	presenter := ReplayEditor new.
	backend := ReplaySpecBackend presenter: presenter morph: Morph new.
	self assert: backend semanticScriptReceiver equals: presenter
]

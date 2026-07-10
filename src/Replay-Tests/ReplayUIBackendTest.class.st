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
ReplayUIBackendTest >> testClickActionDelegatesToResolvedUIBackend [

	| backend action resolved |
	backend := ReplayRecordingBackend new.
	action := ReplayClick new.
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'Button')
		nativeElement: Object new
		morph: Morph new.

	action runOn: ReplayRunner new resolvedUI: resolved.

	self assert: backend lastInteraction equals: #click.
	self assert: backend lastAction equals: action.
	self assert: backend lastResolvedUI equals: resolved
]

{ #category : 'tests' }
ReplayUIBackendTest >> testFocusActionDelegatesToResolvedUIBackend [

	| backend action resolved |
	backend := ReplayRecordingBackend new.
	action := ReplayFocus new.
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'Field')
		nativeElement: Object new
		morph: Morph new.

	action runOn: ReplayRunner new resolvedUI: resolved.

	self assert: backend lastInteraction equals: #focus.
	self assert: backend lastAction equals: action.
	self assert: backend lastResolvedUI equals: resolved
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
ReplayUIBackendTest >> testManagingMorphUsesMorphicResolver [

	| manager morph |
	morph := Morph new.
	manager := ReplayUIManager new manage: morph; yourself.

	self assert: manager resolver class equals: ReplayMorphicResolver.
	self assert: manager surfaceMorph equals: morph
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
ReplayUIBackendTest >> testManagingPresenterUsesSpecResolver [

	| manager presenter |
	presenter := ReplaySemanticPresenter new.
	manager := ReplayUIManager new managePresenter: presenter; yourself.

	self assert: manager resolver class equals: ReplaySpecResolver.
	self assert: manager backend root equals: presenter.
	self assert: manager surfaceMorph isMorph
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
ReplayUIBackendTest >> testPressKeyActionDelegatesToResolvedUIBackend [

	| backend action resolved |
	backend := ReplayRecordingBackend new.
	action := ReplayPressKey new.
	action keySelector: #right.
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'Field')
		nativeElement: Object new
		morph: Morph new.

	action runOn: ReplayRunner new resolvedUI: resolved.

	self assert: backend lastInteraction equals: #pressKey.
	self assert: backend lastAction equals: action.
	self assert: backend lastResolvedUI equals: resolved
]

{ #category : 'tests' }
ReplayUIBackendTest >> testPressKeyBuildsKeyboardKeyEvents [

	| action down up |
	action := ReplayPressKey new.
	action
		keySelector: #left;
		flags: 8.
	down := action keyDownKey: action keyboardKey buttons: action flags.
	up := action keyUpKey: action keyboardKey buttons: action flags.

	self assert: down isKeyDown.
	self assert: up isKeyUp.
	self assert: down keyValue equals: KeyboardKey left value.
	self assert: up keyValue equals: KeyboardKey left value.
	self assert: down buttons equals: 8.
	self assert: up buttons equals: 8
]

{ #category : 'tests' }
ReplayUIBackendTest >> testPressKeyChoicesResolveToKeyboardKeys [

	ReplayPressKey keyChoices do: [ :association |
		self assert: ((KeyboardKey perform: association key) isKindOf: KeyboardKey) ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testPressKeySettingsPresenterBuilds [

	| action presenter |
	action := ReplayPressKey new.
	action
		keySelector: #left;
		repeatCount: 3;
		flags: 8.
	presenter := action settingsPresenterOn: ReplayEditor new.

	self assert: presenter notNil
]

{ #category : 'tests' }
ReplayUIBackendTest >> testResolvedUIElementClickTargetRequiresMorph [

	| resolved |
	resolved := ReplayResolvedUIElement
		backend: ReplayUIBackend new
		reference: (ReplayUIReference named: 'Field')
		nativeElement: Object new
		morph: nil.

	self
		should: [ resolved clickTarget ]
		raise: ReplayMissingUIError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'click').
			self assert: error tag equals: resolved ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testResolvedUIElementFocusTargetFallsBackToMorph [

	| morph resolved |
	morph := Morph new.
	resolved := ReplayResolvedUIElement
		backend: ReplayUIBackend new
		reference: (ReplayUIReference named: 'Field')
		nativeElement: nil
		morph: morph.

	self assert: resolved focusTarget == morph
]

{ #category : 'tests' }
ReplayUIBackendTest >> testResolvedUIElementFocusTargetPrefersNativeElement [

	| native morph resolved |
	native := Morph new.
	morph := Morph new.
	resolved := ReplayResolvedUIElement
		backend: ReplayUIBackend new
		reference: (ReplayUIReference named: 'Field')
		nativeElement: native
		morph: morph.

	self assert: resolved focusTarget == native
]

{ #category : 'tests' }
ReplayUIBackendTest >> testResolvedUIElementKeyboardTargetUsesMorph [

	| native morph resolved |
	native := Object new.
	morph := Morph new.
	resolved := ReplayResolvedUIElement
		backend: ReplayUIBackend new
		reference: (ReplayUIReference named: 'Field')
		nativeElement: native
		morph: morph.

	self assert: resolved keyboardTarget == morph
]

{ #category : 'tests' }
ReplayUIBackendTest >> testShortcutActionDelegatesToResolvedUIBackend [

	| backend action resolved |
	backend := ReplayRecordingBackend new.
	action := ReplayShortcut new.
	action text: 's'.
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'Shortcut target')
		nativeElement: Object new
		morph: Morph new.

	action runOn: ReplayRunner new resolvedUI: resolved.

	self assert: backend lastInteraction equals: #shortcut.
	self assert: backend lastAction equals: action.
	self assert: backend lastResolvedUI equals: resolved
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecBackendKeepsNonLeftButtonClickOnMorphicFallback [

	| clicked button backend action resolved |
	clicked := false.
	button := SpButtonPresenter new.
	button action: [ clicked := true ].
	backend := ReplaySpecBackend presenter: button morph: nil.
	action := ReplayClick new.
	action flags: MouseEvent yellowButton.
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'Button')
		nativeElement: button
		morph: nil.

	self
		should: [ backend runClick: action on: resolved ]
		raise: ReplayMissingUIError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'click') ].
	self deny: clicked
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecBackendResolvesNamedPresenterSemantically [

	| presenter manager action runner |
	presenter := ReplaySemanticPresenter new.
	manager := ReplayUIManager new managePresenter: presenter.
	runner := ReplayRunner new manager: manager.
	action := ReplayFocus new targetNamed: 'Field'.

	[
		manager openLabeled: 'Replay semantic resolver test'.
		self shouldnt: [ action runOn: runner ] raise: Error ]
		ensure: [ manager close ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecBackendRunsNativeButtonClick [

	| clicked button backend action resolved |
	clicked := false.
	button := SpButtonPresenter new.
	button action: [ clicked := true ].
	backend := ReplaySpecBackend presenter: button morph: nil.
	action := ReplayClick new.
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'Button')
		nativeElement: button
		morph: nil.

	backend runClick: action on: resolved.

	self assert: clicked
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecBackendUsesPresenterAsSemanticScriptReceiver [

	| presenter backend |
	presenter := ReplayEditor new.
	backend := ReplaySpecBackend presenter: presenter morph: Morph new.
	self assert: backend semanticScriptReceiver equals: presenter
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecResolverDoesNotResolveNonNativeClickBeforeMorphExists [

	| presenter backend action resolver capturedError |
	presenter := ReplayButtonSemanticPresenter new.
	backend := ReplaySpecBackend presenter: presenter morph: nil.
	action := ReplayClick new.
	action flags: MouseEvent yellowButton.
	resolver := ReplaySpecResolver on: backend.
	resolver maxAttempts: 1.

	resolver
		resolve: (ReplayUIReference named: 'Button')
		forAction: action
		thenDo: [ :element | self fail: 'Unexpected native-only resolution' ]
		onMissing: [ :error | capturedError := error ].

	self assert: capturedError class equals: ReplayMissingUIError.
	self deny: presenter clicked
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecResolverKeepsSemanticPresenterAsNativeElement [

	| presenter manager resolved |
	presenter := ReplaySemanticPresenter new.
	manager := ReplayUIManager new managePresenter: presenter.

	manager
		resolve: (ReplayUIReference named: 'Field')
		thenDo: [ :element | resolved := element ].

	self assert: resolved nativeElement equals: presenter field.
	self assert: resolved morph isMorph
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecResolverReportsMissingSemanticNameImmediately [

	| presenter manager capturedError |
	presenter := ReplaySemanticPresenter new.
	manager := ReplayUIManager new managePresenter: presenter.

	manager
		resolve: (ReplayUIReference named: 'Missing')
		thenDo: [ :element | self fail ]
		onMissing: [ :error | capturedError := error ].

	self assert: capturedError class equals: ReplayMissingUIError
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecResolverResolvesNativeButtonClickBeforeMorphExists [

	| presenter backend action resolved |
	presenter := ReplayButtonSemanticPresenter new.
	backend := ReplaySpecBackend presenter: presenter morph: nil.
	action := ReplayClick new.

	backend
		resolve: (ReplayUIReference named: 'Button')
		forAction: action
		thenDo: [ :element | resolved := element ]
		onMissing: [ :error | error signal ].

	self assert: resolved notNil.
	self assert: resolved nativeElement equals: presenter button.
	self deny: resolved hasMorph.
	action runOn: ReplayRunner new resolvedUI: resolved.
	self assert: presenter clicked
]

{ #category : 'tests' }
ReplayUIBackendTest >> testTypeActionDelegatesToResolvedUIBackend [

	| backend action resolved |
	backend := ReplayRecordingBackend new.
	action := ReplayType new.
	action text: 'abc'.
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'Field')
		nativeElement: Object new
		morph: Morph new.

	action runOn: ReplayRunner new resolvedUI: resolved.

	self assert: backend lastInteraction equals: #type.
	self assert: backend lastAction equals: action.
	self assert: backend lastResolvedUI equals: resolved
]

{ #category : 'tests' }
ReplayUIBackendTest >> testTypeActionRequiresKeyboardTargetFromResolvedUI [

	| action resolved |
	action := ReplayType new.
	action text: 'a'.
	resolved := ReplayResolvedUIElement
		backend: ReplayUIBackend new
		reference: (ReplayUIReference named: 'Field')
		nativeElement: Object new
		morph: nil.

	self
		should: [ action runOn: ReplayRunner new resolvedUI: resolved ]
		raise: ReplayMissingUIError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'keyboard') ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testUIHandlerClearingSemanticNameReturnsToWorldTarget [

	| action reference |
	action := ReplayFocus new.
	action targetNamed: 'Field'.
	action targetName: '   '.
	reference := action uiReference.

	self assert: action reference isNil.
	self assert: reference isWorld.
	self deny: action hasSpecificTarget
]

{ #category : 'tests' }
ReplayUIBackendTest >> testUIHandlerPathClearsSemanticReference [

	| action reference |
	action := ReplayFocus new.
	action targetNamed: 'Field'.
	action path: #( 1 2 ).
	reference := action uiReference.

	self assert: action reference isNil.
	self assert: reference isMorphicPath.
	self assert: reference value equals: #( 1 2 ).
	self assert: action hasSpecificTarget
]

{ #category : 'tests' }
ReplayUIBackendTest >> testUIHandlerTargetNamedCreatesSemanticReference [

	| action reference |
	action := ReplayFocus new.
	action targetNamed: 'Field'.
	reference := action uiReference.

	self assert: reference isNamed.
	self assert: reference value equals: 'Field'.
	self assert: action path isNil.
	self assert: action hasSpecificTarget
]

{ #category : 'tests' }
ReplayUIBackendTest >> testUIHandlerTargetPresenterBuildsForSemanticTarget [

	| action presenter |
	action := ReplayFocus new.
	action targetNamed: 'Field'.
	presenter := action targetPresenterOn: ReplayEditor new.

	self assert: presenter notNil
]

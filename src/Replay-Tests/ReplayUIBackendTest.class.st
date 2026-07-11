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
ReplayUIBackendTest >> testAddingLabeledAnnotationToNonWorldOverlayDoesNotFail [

	| root target manager annotation |
	root := Morph new extent: 300 @ 200.
	target := Morph new bounds: (10 @ 10 extent: 80 @ 40).
	root addMorph: target.
	manager := ReplayUIManager new attachTo: target.
	annotation := ReplayAnnotation annotate: target bounds label: 'Detached annotation'.

	self shouldnt: [ manager addOverlay: annotation ] raise: Error.
	self deny: annotation label isInWorld.
	manager close
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAnnotateDefersOverlayThroughManagerBackend [

	| backend manager runner action resolved target |
	backend := ReplayRecordingBackend new.
	manager := ReplayUIManager new
		manage: (Morph new extent: 200 @ 100)
		usingBackend: backend.
	runner := ReplayRunner on: ReplayScenario new.
	runner manager: manager.
	target := Morph new bounds: (10 @ 10 extent: 80 @ 30).
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'Target')
		nativeElement: target
		morph: target.
	action := ReplayAnnotate new text: 'Deferred annotation'; yourself.

	action runOn: runner resolvedUI: resolved.

	self assert: backend deferredBlockCount equals: 1.
	self assert: manager overlay submorphs isEmpty.
	backend runDeferredBlocks.
	self assert: manager overlay submorphs size equals: 1
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAnnotatePlacementSettingsPresenterBuilds [

	| action presenter |
	action := ReplayAnnotate new placement: #below; text: 'Placed'; yourself.
	presenter := action settingsPresenterOn: ReplayEditor new.

	self assert: presenter notNil
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAnnotationAutomaticPlacementPrefersRightWhenItFits [

	| root manager annotation targetBounds |
	root := Morph new
		bounds: (100 @ 100 extent: 600 @ 300);
		yourself.
	root openInWorld.
	manager := ReplayUIManager new attachTo: root.
	targetBounds := 40 @ 80 extent: 80 @ 40.
	annotation := ReplayAnnotation annotate: targetBounds label: 'Automatic right placement'.

	[
		manager addOverlay: annotation.
		self assert: annotation label bounds left >= annotation targetBoundsInWorld right.
		self deny: (annotation label bounds intersects: annotation targetBoundsInWorld) ]

		ensure: [
			manager close.
			root delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAnnotationHonorsExplicitAbovePlacement [

	| root manager annotation targetBounds |
	root := Morph new
		bounds: (200 @ 200 extent: 500 @ 320);
		yourself.
	root openInWorld.
	manager := ReplayUIManager new attachTo: root.
	targetBounds := 160 @ 160 extent: 80 @ 40.
	annotation := ReplayAnnotation annotate: targetBounds label: 'Explicit above placement'.
	annotation placement: #above.

	[
		manager addOverlay: annotation.
		self assert: annotation label bounds bottom <= annotation targetBoundsInWorld top.
		self deny: (annotation label bounds intersects: annotation targetBoundsInWorld) ]

		ensure: [
			manager close.
			root delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAnnotationHonorsExplicitLeftPlacement [

	| root manager annotation targetBounds |
	root := Morph new bounds: (200 @ 100 extent: 500 @ 260); yourself.
	root openInWorld.
	manager := ReplayUIManager new attachTo: root.
	targetBounds := 220 @ 80 extent: 80 @ 40.
	annotation := ReplayAnnotation
		annotate: targetBounds
		label: 'Explicit left placement'.
	annotation placement: #left.

	[
		manager addOverlay: annotation.
		self assert: annotation label bounds right <= annotation targetBoundsInWorld left.
		self deny: (annotation label bounds intersects: annotation targetBoundsInWorld) ]

		ensure: [
			manager close.
			root delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAnnotationLabelStaysInsideVisibleWorldNearRightEdge [

	| worldBounds root manager annotation targetBounds |
	worldBounds := World visibleClearArea.
	root := Morph new
		bounds: ((worldBounds right - 180) @ (worldBounds top + 40) extent: 160 @ 120);
		yourself.
	root openInWorld.
	manager := ReplayUIManager new attachTo: root.
	targetBounds := 100 @ 20 extent: 50 @ 40.
	annotation := ReplayAnnotation annotate: targetBounds label: 'Right edge annotation'.

	[
		manager addOverlay: annotation.
		self assert: annotation label bounds right <= worldBounds right.
		self assert: annotation label bounds left >= worldBounds left.
		self deny: (annotation label bounds intersects: annotation targetBoundsInWorld) ]
		ensure: [
			manager close.
			root delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAnnotationLabelsAndLinesAreNotWorldTopmost [

	self deny: ReplayAnnotationLabel new wantsToBeTopmost.
	self deny: ReplayAnnotationLine new wantsToBeTopmost
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAnnotationLayoutAvoidsSiblingLabelOverlap [

	| root manager firstAnnotation secondAnnotation |
	root := Morph new
		bounds: (100 @ 100 extent: 400 @ 260);
		yourself.
	root openInWorld.
	manager := ReplayUIManager new attachTo: root.
	firstAnnotation := ReplayAnnotation
		annotate: (20 @ 20 extent: 90 @ 40)
		label: 'First annotation label'.
	secondAnnotation := ReplayAnnotation
		annotate: (20 @ 70 extent: 90 @ 40)
		label: 'Second annotation label'.

	[
		manager addOverlay: firstAnnotation.
		manager addOverlay: secondAnnotation.
		self deny: (firstAnnotation label bounds intersects: secondAnnotation label bounds).
		self deny: (firstAnnotation label bounds intersects: firstAnnotation targetBoundsInWorld).
		self deny: (secondAnnotation label bounds intersects: secondAnnotation targetBoundsInWorld) ]
		ensure: [
			manager close.
			root delete ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAttachToMorphWithoutOwnerFails [

	| target |
	target := Morph new extent: 100 @ 50.

	self
		should: [ ReplayUIManager new attachTo: target ]
		raise: ReplayError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'without an owner').
			self assert: error tag equals: target ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAttachToUnrenderedSpecPresenterFails [

	| presenter |
	presenter := ReplaySemanticPresenter new.

	self
		should: [ ReplayUIManager new attachToPresenter: presenter ]
		raise: ReplayError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'without an adapter').
			self assert: error tag equals: presenter ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAttachUIActionAttachesToScriptMorph [

	| root target runner action |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (10 @ 10 corner: 80 @ 40).
	root addMorph: target.
	runner := ReplayRunner new focus: target.
	action := ReplayAttachUI new.
	action script: 'self focus'.

	action runOn: runner.

	self assert: runner manager notNil.
	self deny: runner manager ownsUI.
	self assert: runner manager managedUI equals: target.
	self assert: runner manager overlay owner equals: root
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAttachUIActionRejectsUnexpectedScriptResult [

	| runner action |
	runner := ReplayRunner new.
	action := ReplayAttachUI new.
	action script: '42'.

	self
		should: [ action runOn: runner ]
		raise: ReplayScriptError
		withExceptionDo: [ :error |
			self assert: (error messageText includesSubstring: 'existing Morph or Spec presenter').
			self assert: error tag equals: 42 ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAttachedMorphManagerAllowsUserInteraction [

	| root target manager |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (10 @ 10 corner: 80 @ 40).
	root addMorph: target.
	manager := ReplayUIManager new attachTo: target.

	self assert: manager interactionPolicy equals: #passThrough.
	self deny: manager blocksUserInteraction
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAttachedMorphManagerDoesNotInstallBlockingOverlayHandlers [

	| root target manager |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (10 @ 10 corner: 80 @ 40).
	root addMorph: target.
	manager := ReplayUIManager new attachTo: target.

	self assert: manager overlay eventHandler isNil
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAttachedMorphManagerDoesNotOwnUI [

	| root target manager |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (10 @ 10 corner: 80 @ 40).
	root addMorph: target.
	manager := ReplayUIManager new attachTo: target.

	self deny: manager ownsUI.
	self assert: manager managedUI equals: target.
	self assert: manager overlay owner equals: root.
	self assert: manager overlay bounds equals: target bounds
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAttachedMorphManagerResolvesRelativeToManagedMorph [

	| root target child manager resolved |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (10 @ 10 corner: 80 @ 40).
	child := Morph new bounds: (1 @ 1 corner: 20 @ 20).
	target addMorph: child.
	root addMorph: target.
	manager := ReplayUIManager new attachTo: target.

	manager
		resolve: (ReplayUIReference morphicPath: #( 1 ))
		thenDo: [ :element | resolved := element ].

	self assert: resolved morph equals: child
]

{ #category : 'tests' }
ReplayUIBackendTest >> testAttachedOverlayDoesNotParticipateInOwnerTableLayout [

	| root target manager originalBounds overlay |
	root := Morph new
		extent: 200 @ 100;
		changeTableLayout;
		yourself.
	target := Morph new
		bounds: (0 @ 0 extent: 200 @ 100);
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		yourself.
	root addMorph: target.
	root doLayoutIn: root bounds.
	originalBounds := target bounds.
	manager := ReplayUIManager new attachTo: target.
	overlay := manager overlay.
	root doLayoutIn: root bounds.

	self assert: target bounds equals: originalBounds.
	self assert: overlay bounds equals: originalBounds.
	self assert: overlay disableTableLayout.
	self assert: overlay hResizing equals: #rigid.
	self assert: overlay vResizing equals: #rigid
]

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
ReplayUIBackendTest >> testCloseAttachedMorphManagerRemovesOnlyReplayOverlay [

	| root target manager overlay |
	root := Morph new extent: 200 @ 100.
	target := Morph new bounds: (10 @ 10 corner: 80 @ 40).
	root addMorph: target.
	manager := ReplayUIManager new attachTo: target.
	overlay := manager overlay.

	manager close.

	self assert: overlay owner isNil.
	self assert: target owner equals: root
]

{ #category : 'tests' }
ReplayUIBackendTest >> testCloseUIActionClearsRunnerManager [

	| runner manager |
	runner := ReplayRunner new.
	manager := ReplayUIManager new manage: (Morph new extent: 100 @ 50); yourself.
	runner manager: manager.

	ReplayCloseUI new runOn: runner.

	self assert: runner manager isNil
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
ReplayUIBackendTest >> testManagedMorphManagerBlocksUserInteraction [

	| manager |
	manager := ReplayUIManager new manage: (Morph new extent: 100 @ 50).

	self assert: manager interactionPolicy equals: #blocked.
	self assert: manager blocksUserInteraction
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
		20 timesRepeat: [ World doOneCycle ].
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
		20 timesRepeat: [ World doOneCycle ].
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
		20 timesRepeat: [ World doOneCycle ].
		self assert: manager ui extent equals: targetExtent.
		self assert: manager managedUI extent equals: targetExtent.
		self assert: manager overlay extent equals: targetExtent.
		self assert: manager ui window extent x >= targetExtent x.
		self assert: manager ui window extent y >= targetExtent y ]
		ensure: [ manager close ]
]

{ #category : 'tests' }
ReplayUIBackendTest >> testOwnedMorphManagerInstallsBlockingOverlayHandlers [

	| manager |
	manager := ReplayUIManager new manage: (Morph new extent: 100 @ 50).

	self assert: manager ownsUI.
	self assert: manager overlay eventHandler notNil
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
ReplayUIBackendTest >> testSelectTextActionDelegatesToResolvedUIBackend [

	| backend action resolved |
	backend := ReplayRecordingBackend new.
	action := ReplaySelectText new.
	action
		startIndex: 2;
		stopIndex: 5.
	resolved := ReplayResolvedUIElement
		backend: backend
		reference: (ReplayUIReference named: 'Field')
		nativeElement: ReplaySelectableTarget new
		morph: Morph new.

	action runOn: ReplayRunner new resolvedUI: resolved.

	self assert: backend lastInteraction equals: #selectText.
	self assert: backend lastAction equals: action.
	self assert: backend lastResolvedUI equals: resolved
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSelectTextBackendFallsBackToMorph [

	| action morph resolved |
	action := ReplaySelectText new
		startIndex: 3;
		stopIndex: 4;
		yourself.
	morph := ReplaySelectableTarget new.
	resolved := ReplayResolvedUIElement
		backend: ReplayUIBackend new
		reference: (ReplayUIReference named: 'Field')
		nativeElement: Object new
		morph: morph.

	action runOn: ReplayRunner new resolvedUI: resolved.

	self assert: morph selectionInterval equals: (3 to: 4)
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSelectTextBackendPrefersNativeElement [

	| action native morph resolved |
	action := ReplaySelectText new
		startIndex: 2;
		stopIndex: 5;
		yourself.
	native := ReplaySelectableTarget new.
	morph := ReplaySelectableTarget new.
	resolved := ReplayResolvedUIElement
		backend: ReplayUIBackend new
		reference: (ReplayUIReference named: 'Field')
		nativeElement: native
		morph: morph.

	action runOn: ReplayRunner new resolvedUI: resolved.

	self assert: native selectionInterval equals: (2 to: 5).
	self assert: morph selectionInterval isNil
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSelectTextNormalizesStopBeforeStart [

	| action |
	action := ReplaySelectText new
		startIndex: 4;
		stopIndex: 2;
		yourself.
	self assert: action selectionInterval equals: (4 to: 4)
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSelectTextRejectsUnsupportedTarget [

	| action |
	action := ReplaySelectText new.
	self
		should: [ action selectTextIn: Object new ]
		raise: ReplayError
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
ReplayUIBackendTest >> testSpecResolverResolvesNativeFocusBeforeMorphExists [

	| presenter backend action resolved |
	presenter := ReplaySemanticPresenter new.
	backend := ReplaySpecBackend presenter: presenter morph: nil.
	action := ReplayFocus new.

	backend
		resolve: (ReplayUIReference named: 'Field')
		forAction: action
		thenDo: [ :element | resolved := element ]
		onMissing: [ :error | error signal ].

	self assert: resolved notNil.
	self assert: resolved nativeElement equals: presenter field.
	self deny: resolved hasMorph
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecResolverResolvesNativeSelectTextBeforeMorphExists [

	| presenter backend action resolved |
	presenter := ReplaySemanticPresenter new.
	backend := ReplaySpecBackend presenter: presenter morph: nil.
	action := ReplaySelectText new
		startIndex: 1;
		stopIndex: 4;
		yourself.

	backend
		resolve: (ReplayUIReference named: 'Field')
		forAction: action
		thenDo: [ :element | resolved := element ]
		onMissing: [ :error | error signal ].

	self assert: resolved notNil.
	self assert: resolved nativeElement equals: presenter field.
	self deny: resolved hasMorph.
	action runOn: ReplayRunner new resolvedUI: resolved.
	self assert: presenter field selectionInterval equals: (1 to: 4)
]

{ #category : 'tests' }
ReplayUIBackendTest >> testSpecificTargetUIActionWithoutManagerRaisesMissingUI [

	| action |
	action := ReplayFocus new.
	action targetNamed: 'Field'.
	self
		should: [ action runOn: ReplayRunner new ]
		raise: ReplayMissingUIError
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

{ #category : 'tests' }
ReplayUIBackendTest >> testUIResolverMaxAttemptsIsAtLeastOne [

	| resolver |
	resolver := ReplaySpecResolver on: (ReplaySpecBackend presenter: ReplayEditor new morph: Morph new).
	resolver maxAttempts: 0.
	self assert: resolver maxAttempts equals: 1.
	resolver maxAttempts: -5.
	self assert: resolver maxAttempts equals: 1.
	resolver maxAttempts: 3.
	self assert: resolver maxAttempts equals: 3
]

{ #category : 'tests' }
ReplayUIBackendTest >> testUIResolverSchedulesRetryThroughBackend [

	| backend resolver ran |
	backend := ReplayRecordingBackend new.
	resolver := ReplayUIResolver on: backend.
	ran := false.

	resolver schedule: [ ran := true ].

	self deny: ran.
	self assert: backend deferredBlockCount equals: 1.
	backend runDeferredBlocks.
	self assert: ran
]

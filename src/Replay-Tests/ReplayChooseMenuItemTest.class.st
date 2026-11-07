"
Tests for ReplayChooseMenuItem: choosing items of menus open in the World, in submenus, after a right click, and waiting for the menu.
"
Class {
	#name : 'ReplayChooseMenuItemTest',
	#superclass : 'ReplayTestCase',
	#instVars : [
		'chosen',
		'menus'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayChooseMenuItemTest >> newMenu [
	"A menu with 'Hello', and 'Deep' in the submenu 'More'"

	| menu submenu |
	submenu := MenuMorph new.
	submenu add: 'Deep' target: [ chosen := #deep ] selector: #value.
	menu := MenuMorph new.
	menu add: 'Hello' target: [ chosen := #hello ] selector: #value.
	menu add: 'More' subMenu: submenu.
	^ menus add: menu
]

{ #category : 'support' }
ReplayChooseMenuItemTest >> runActions: actions [
	"Run actions, then a script that sets the focus of the runner to #done. Answer the runner."

	| scenario step runner |
	step := ReplayStep new.
	actions do: [ :action | step addAction: action ].
	step addAction: (ReplayScript new script: 'self focus: #done').
	scenario := ReplayScenario new.
	scenario addStep: step.
	runner := ReplayRunner on: scenario.
	runner run.
	^ runner
]

{ #category : 'running' }
ReplayChooseMenuItemTest >> setUp [

	super setUp.
	menus := OrderedCollection new
]

{ #category : 'running' }
ReplayChooseMenuItemTest >> tearDown [

	menus do: [ :menu | menu delete ].
	super tearDown
]

{ #category : 'tests' }
ReplayChooseMenuItemTest >> testAMissingItemSaysWhatTheMenuShows [

	| error |
	self newMenu openInWorld.
	error := [
	         (ReplayChooseMenuItem labels: #( 'Bye' )) menuItem.
	         nil ]
		         on: ReplayMissingUIError
		         do: [ :missing | missing ].
	self assert: error notNil.
	self assert: (error messageText includesSubstring: '''Hello'', ''More''')
]

{ #category : 'tests' }
ReplayChooseMenuItemTest >> testChoosesAnItemAndClosesTheMenu [

	| menu runner |
	menu := self newMenu.
	menu openInWorld.
	runner := self runActions: { (ReplayChooseMenuItem labels: #( 'Hello' )) }.
	self waitUntil: [ runner focus = #done ].
	self assert: chosen equals: #hello.
	self assert: menu world isNil
]

{ #category : 'tests' }
ReplayChooseMenuItemTest >> testChoosesAnItemInASubmenu [

	| runner |
	self newMenu openInWorld.
	runner := self runActions: { (ReplayChooseMenuItem new labelPath: 'More > Deep') }.
	self waitUntil: [ runner focus = #done ].
	self assert: chosen equals: #deep
]

{ #category : 'tests' }
ReplayChooseMenuItemTest >> testChoosesInTheContextMenuOfARightClick [

	| pane manager list scenario runner |
	pane := ReplayNamedPanePresenter new.
	pane items contextMenu: [
		SpMenuPresenter new
			addItem: [ :item |
				item
					name: 'Inspect';
					action: [ chosen := pane items selectedItem ] ];
			yourself ].
	manager := ReplayUIManager new managePresenter: pane.
	manager
		openLabeled: 'Context menu'
		placement: (ReplayPlacement bounds: (0 @ 0 extent: 240 @ 120)).
	[
		manager settleUI.
		list := pane items adapter widget.
		list fullDrawOn: (Form extent: list extent depth: 32) getCanvas.
		scenario := ReplayScenario new.
		scenario addStep: (ReplayStep new
				 addAction: (ReplayClick new
						  targetNamed: 'items';
						  position: 20 @ 10;
						  buttons: MouseEvent yellowButton;
						  yourself);
				 addAction: (ReplayChooseMenuItem labels: #( 'Inspect' ));
				 addAction: (ReplayScript new script: 'self focus: #done');
				 yourself).
		runner := ReplayRunner on: scenario.
		runner manager: manager.
		runner run.
		self waitUntil: [ runner focus = #done ].
		"The right click selected the row under it"
		self assert: chosen equals: #one ] ensure: [
		(self currentWorld submorphs select: [ :morph | morph isKindOf: MenuMorph ])
			do: [ :menu | menu delete ].
		manager close ]
]

{ #category : 'tests' }
ReplayChooseMenuItemTest >> testItWaitsForTheMenu [

	| runner |
	runner := self runActions: { (ReplayChooseMenuItem labels: #( 'Hello' )) }.
	self assert: chosen isNil.
	self newMenu openInWorld.
	self waitUntil: [ runner focus = #done ].
	self assert: chosen equals: #hello
]

{ #category : 'tests' }
ReplayChooseMenuItemTest >> testLabelsOfAnItemFollowSubmenus [

	| menu deep |
	menu := self newMenu.
	menu openInWorld.
	deep := (menu items detect: [ :item | item contents = 'More' ]) subMenu items first.
	self assert: (ReplayChooseMenuItem labelsOfItem: deep) equals: #( 'More' 'Deep' )
]

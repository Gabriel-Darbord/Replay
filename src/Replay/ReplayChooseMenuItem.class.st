"
I choose an item of the menu open in the World by its label, such as an item of the context menu that a right click opens (a Click with the right button). In submenus, my labels are the path to the item, such as 'Refactorings' then 'Rename'.

Menus open in the World, outside the managed UI, so I need no target: I act on the frontmost menu that is not a submenu. While it has no item with my labels, or there is no menu, I wait for it like for a missing target. Choosing the item closes the menu, as a click on it would.

Editor previews skip me: they open no menus.
"
Class {
	#name : 'ReplayChooseMenuItem',
	#superclass : 'ReplayAction',
	#traits : 'TReplayActionWithLabelPath',
	#classTraits : 'TReplayActionWithLabelPath classTrait',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayChooseMenuItem class >> displayName [

	^ 'Choose menu item'
]

{ #category : 'editing' }
ReplayChooseMenuItem class >> editorClass [

	^ ReplayChooseMenuItemEditor
]

{ #category : 'instance creation' }
ReplayChooseMenuItem class >> labels: aCollection [

	^ self new
		  labels: aCollection;
		  yourself
]

{ #category : 'accessing' }
ReplayChooseMenuItem class >> labelsOfItem: aMenuItemMorph [
	"The labels of the path to aMenuItemMorph through submenus, from the item of the outermost menu"

	| labels item |
	labels := OrderedCollection new.
	item := aMenuItemMorph.
	[ item isNil ] whileFalse: [
		labels addFirst: (self labelOfItem: item).
		item := self parentItemOf: item ].
	^ labels asArray
]

{ #category : 'accessing' }
ReplayChooseMenuItem class >> parentItemOf: aMenuItemMorph [
	"The item whose submenu holds aMenuItemMorph, or nil in an outermost menu.
	A submenu knows that item once it popped up from it, otherwise I look for it in the menus of the World."

	| menu |
	menu := aMenuItemMorph owner.
	(menu isNotNil and: [ menu isMenuMorph ]) ifFalse: [ ^ nil ].
	menu popUpOwner ifNotNil: [ :item | ^ item ].
	self currentWorld submorphs do: [ :morph |
		morph isMenuMorph ifTrue: [
			morph items
				detect: [ :each | each subMenu == menu ]
				ifFound: [ :each | ^ each ] ] ].
	^ nil
]

{ #category : 'accessing' }
ReplayChooseMenuItem class >> labelOfItem: aMenuItemMorph [

	^ aMenuItemMorph contents asString trimBoth
]

{ #category : 'running' }
ReplayChooseMenuItem >> choose: aMenuItemMorph [
	"Invoke the action of aMenuItemMorph, which closes its menus"

	aMenuItemMorph isEnabled ifFalse: [
		ReplayError new
			messageText: 'The menu item ' , self labelPath printString , ' is disabled.';
			subject: aMenuItemMorph;
			signal ].
	aMenuItemMorph invokeWithEvent: nil
]

{ #category : 'testing' }
ReplayChooseMenuItem >> controlsRunnerContinuation [

	^ true
]

{ #category : 'running' }
ReplayChooseMenuItem >> frontmostMenu [
	"The frontmost menu of the World that is not a submenu, or nil"

	^ self currentWorld submorphs
		  detect: [ :morph | morph isMenuMorph and: [ morph popUpOwner isNil ] ]
		  ifNone: [ nil ]
]

{ #category : 'running' }
ReplayChooseMenuItem >> menuItem [
	"The item at my labels from the frontmost menu. Signal a ReplayMissingUIError when there is none."

	| menu item |
	self ensureLabels.
	menu := self frontmostMenu ifNil: [
		        ReplayMissingUIError new
			        messageText: 'No menu is open to choose ' , self labelPath printString , ' in.';
			        subject: self;
			        signal ].
	self labels doWithIndex: [ :label :depth |
		item := menu items
			        detect: [ :each | (self class labelOfItem: each) = label ]
			        ifNone: [
				        self
					        missingLabel: label
					        in: 'the menu'
					        among: (menu items collect: [ :each | self class labelOfItem: each ]) ].
		depth < self labels size ifTrue: [
			menu := item subMenu ifNil: [
				        ReplayError new
					        messageText: 'The menu item ' , label printString , ' has no submenu.';
					        subject: item;
					        signal ] ] ].
	^ item
]

{ #category : 'running' }
ReplayChooseMenuItem >> previewOn: aReplayUIBuilder [
	"Previews open no menus."

	aReplayUIBuilder nextAction
]

{ #category : 'printing' }
ReplayChooseMenuItem >> printOn: stream [

	super printOn: stream.
	self printDetail: self labelPath on: stream
]

{ #category : 'running' }
ReplayChooseMenuItem >> runOn: runner [
	"Wait for the menu, choose the item, then let the UI process its action before continuing"

	| resolver |
	resolver := runner backend resolver.
	resolver
		retry: [ self menuItem ]
		for: (resolver timeoutFor: self)
		thenDo: [ :item |
			runner isStopped ifFalse: [
				runner protect: [ self choose: item ].
				runner defer: [ runner nextAction ] ] ]
		onMissing: [ :error |
			runner isStopped ifFalse: [ runner protect: [ error signal ] ] ]
]

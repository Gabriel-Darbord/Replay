"
I wrap another UI element to make it interactive for editing scenarios.
This allows scenario developers to manually select the elements with which they want to interact.
"
Class {
	#name : 'ReplayWrapperMorph',
	#superclass : 'Morph',
	#instVars : [
		'index',
		'wrappedMorph'
	],
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'accessing' }
ReplayWrapperMorph >> index: anInteger [

	index := anInteger
]

{ #category : 'initialization' }
ReplayWrapperMorph >> initialize [

	super initialize.
	self beTransparent.
	self highlightColor: (Color red alpha: 0.5)
]

{ #category : 'editing' }
ReplayWrapperMorph >> menuPresenterOn: editor [
	"Menu when clicking a wrapper that allows creating actions"

	| menu |
	menu := SpMenuPresenter new.
	ReplayAction actionsForMenu do: [ :action |
		menu addItem: [ :item |
			item
				name: action displayName;
				action: [
					editor
						addAction: (action fromUIPath: self path)
						after: editor model currentAction ] ] ].
	^ menu
]

{ #category : 'event handling' }
ReplayWrapperMorph >> onMouseEnter: event [
	"Apply highlight if coming from outside of the UI.
	Highlighting is then passed between wrappers on mouse leave."

	| comingFrom |
	comingFrom := event hand world morphsAt: (event isMove
			               ifTrue: [ event startPoint ]
			               ifFalse: [ event position ]).
	comingFrom class == self class ifFalse: [ self highlight ].
	"We cannot rely on `event wasHandled` to know if this is the only highlighted wrapper.
	So we have to remove the highlight from the whole owner chain."
	(owner isNotNil and: [ owner class == self class ]) ifTrue: [
		owner unhighlightAll ].
	event wasHandled: true
]

{ #category : 'event handling' }
ReplayWrapperMorph >> onMouseLeave: event [
	"Transfer highlight to another wrapper under the hand"

	| underHand |
	self beTransparent.
	underHand := (event hand world morphsAt: event position) first.
	underHand class == self class ifTrue: [ underHand highlight ].
	event wasHandled: true
]

{ #category : 'initialize' }
ReplayWrapperMorph >> outOfWorld: aWorld [

	wrappedMorph := nil.
	self submorphsDo: [ :m | m outOfWorld: aWorld ]
]

{ #category : 'accessing' }
ReplayWrapperMorph >> path [
	"Path from the root to self, each element is a child index"

	| path |
	path := OrderedCollection new.
	self pathOn: path.
	^ path asArray
]

{ #category : 'accessing' }
ReplayWrapperMorph >> pathOn: collection [
	"Start from the root, which is not part of the path"

	owner class == self class ifFalse: [ ^ self ].
	owner pathOn: collection.
	collection add: index
]

{ #category : 'drawing' }
ReplayWrapperMorph >> unhighlightAll [

	self beTransparent.
	(owner isNotNil and: [ owner class == self class ]) ifTrue: [
		owner unhighlightAll ]
]

{ #category : 'accessing' }
ReplayWrapperMorph >> wrappedMorph [

	^ wrappedMorph
]

{ #category : 'accessing' }
ReplayWrapperMorph >> wrappedMorph: aGUIElement [

	wrappedMorph := aGUIElement
]

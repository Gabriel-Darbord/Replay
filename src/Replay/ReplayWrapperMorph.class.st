"
I am a transparent overlay morph wrapped around a managed Morphic child while editing scenarios. Wrappers nest like the morphs they wrap: I keep the index of my wrapped morph among the submorphs of its owner, so the indexes of my wrapper owners give the path of my wrapped morph from the managed UI (see reference).

I highlight while the hand is over me, and my menu creates actions targeting my wrapped morph.
"
Class {
	#name : 'ReplayWrapperMorph',
	#superclass : 'Morph',
	#instVars : [
		'index',
		'wrappedMorph'
	],
	#category : 'Replay-Morphs',
	#package : 'Replay',
	#tag : 'Morphs'
}

{ #category : 'accessing' }
ReplayWrapperMorph >> index [
	"Answer the index of my wrapped morph among the submorphs of its owner."

	^ index
]

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
						addAction: (action target: self reference)
						after: editor currentAction ] ] ].
	^ menu
]

{ #category : 'event handling' }
ReplayWrapperMorph >> onMouseEnter: event [
	"Apply highlight if coming from outside of the UI, or from one of my wrapper owners, which do not leave.
	Otherwise, the highlight is passed between wrappers on mouse leave."

	| comingFrom |
	comingFrom := (event hand world morphsAt: (event isMove
			                ifTrue: [ event startPoint ]
			                ifFalse: [ event position ]))
		              detect: [ :each | each class == self class ]
		              ifNone: [ nil ].
	(comingFrom isNil or: [ self hasOwner: comingFrom ]) ifTrue: [ self highlight ].
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
	super outOfWorld: aWorld
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

{ #category : 'accessing' }
ReplayWrapperMorph >> reference [
	"The Morphic path reference to my wrapped morph"

	^ ReplayUIReference morphicPath: self path
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

"
I select an item of a list, table, tree or drop list by its label, the text it shows, such as 'Morph'. In a tree, my labels are the path from a root to the item, such as 'Kernel' then 'Object', and I expand the parents of the item.

I run natively on Spec presenters (SpAbstractListPresenter, SpAbstractTreePresenter and SpDropListPresenter), so I do not depend on where the item is on screen, or whether it is scrolled into view. While no item has my label, I wait for one like for a missing target.

In a table or tree table, the label of an item is the text of its first text column.
"
Class {
	#name : 'ReplaySelectItem',
	#superclass : 'ReplayUIHandler',
	#traits : 'TReplayActionWithLabelPath',
	#classTraits : 'TReplayActionWithLabelPath classTrait',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplaySelectItem class >> displayName [

	^ 'Select item'
]

{ #category : 'editing' }
ReplaySelectItem class >> editorClass [

	^ ReplaySelectItemEditor
]

{ #category : 'testing' }
ReplaySelectItem >> allowsWorldTarget [

	^ false
]

{ #category : 'testing' }
ReplaySelectItem >> canRunNativelyOn: anObject [

	^ self canSelectIn: anObject
]

{ #category : 'testing' }
ReplaySelectItem >> canSelectIn: anObject [

	^ (anObject isKindOf: SpAbstractListPresenter)
		  or: [ (anObject isKindOf: SpAbstractTreePresenter)
		  or: [ anObject isKindOf: SpDropListPresenter ] ]
]

{ #category : 'running' }
ReplaySelectItem >> childrenOf: anItem in: aPresenter [

	(self isTree: aPresenter) ifFalse: [
		ReplayError new
			messageText: 'Only trees have items under items: give ' , aPresenter className , ' a single label.';
			subject: aPresenter;
			signal ].
	^ (aPresenter childrenFor: anItem) asArray
]

{ #category : 'running' }
ReplaySelectItem >> ensureReadyOn: aResolvedUIElement [
	"Wait until my item is shown"

	(self canSelectIn: aResolvedUIElement nativeElement) ifTrue: [
		self pathIn: aResolvedUIElement nativeElement ]
]

{ #category : 'testing' }
ReplaySelectItem >> isTree: aPresenter [

	^ aPresenter isKindOf: SpAbstractTreePresenter
]

{ #category : 'running' }
ReplaySelectItem >> labelOf: anItem in: aPresenter [
	"The text that aPresenter shows for anItem"

	| label |
	label := (aPresenter isKindOf: SpDropListPresenter)
		         ifTrue: [ aPresenter display cull: anItem ]
		         ifFalse: [
			         (self textColumnOf: aPresenter)
				         ifNil: [
					         (aPresenter respondsTo: #display)
						         ifTrue: [ aPresenter display value: anItem ]
						         ifFalse: [ anItem ] ]
				         ifNotNil: [ :column | column readObject: anItem ] ].
	^ label asString
]

{ #category : 'error handling' }
ReplaySelectItem >> missingLabel: aString among: items in: aPresenter [

	self
		missingLabel: aString
		in: self target description
		among: (items collect: [ :item | self labelOf: item in: aPresenter ])
]

{ #category : 'running' }
ReplaySelectItem >> pathIn: aPresenter [
	"The indexes of my item in aPresenter, from a root in a tree. Signal a ReplayMissingUIError when it has no item with my labels."

	| items path |
	self ensureLabels.
	items := (self isTree: aPresenter)
		         ifTrue: [ aPresenter roots asArray ]
		         ifFalse: [ aPresenter items asArray ].
	path := OrderedCollection new.
	self labels doWithIndex: [ :label :depth |
		| index |
		index := items findFirst: [ :item | (self labelOf: item in: aPresenter) = label ].
		index = 0 ifTrue: [ self missingLabel: label among: items in: aPresenter ].
		path add: index.
		depth < self labels size ifTrue: [
			items := self childrenOf: (items at: index) in: aPresenter ] ].
	^ path asArray
]

{ #category : 'printing' }
ReplaySelectItem >> printOn: stream [

	super printOn: stream.
	self printDetail: self labelPath on: stream
]

{ #category : 'running' }
ReplaySelectItem >> runOnMorph: aMorph [

	ReplayError new
		messageText: 'Select item needs a Spec list, table, tree or drop list, not ' , aMorph className , '.';
		subject: aMorph;
		signal
]

{ #category : 'running' }
ReplaySelectItem >> runOnNative: aPresenter [

	self select: (self pathIn: aPresenter) in: aPresenter
]

{ #category : 'running' }
ReplaySelectItem >> select: aPath in: aPresenter [

	"Scrolling to the selection waits for a widget, so I only ask for it when there is one"

	| scroll |
	(aPresenter isKindOf: SpDropListPresenter) ifTrue: [
		^ aPresenter selectIndex: aPath first ].
	scroll := aPresenter adapter notNil.
	(self isTree: aPresenter) ifFalse: [
		^ scroll
			  ifTrue: [ aPresenter selectIndex: aPath first scrollToSelection: true ]
			  ifFalse: [ aPresenter selectIndex: aPath first ] ].
	aPath size > 1 ifTrue: [ aPresenter expandPath: aPath allButLast ].
	scroll
		ifTrue: [ aPresenter selectPath: aPath scrollToSelection: true ]
		ifFalse: [ aPresenter selectPath: aPath ]
]

{ #category : 'running' }
ReplaySelectItem >> textColumnOf: aPresenter [
	"The first text column of a table, or nil"

	(aPresenter respondsTo: #columns) ifFalse: [ ^ nil ].
	^ aPresenter columns
		  detect: [ :column | column isKindOf: SpStringTableColumn ]
		  ifNone: [ nil ]
]

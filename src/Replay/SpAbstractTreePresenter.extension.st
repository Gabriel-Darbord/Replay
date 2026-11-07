Extension { #name : 'SpAbstractTreePresenter' }

{ #category : '*Replay' }
SpAbstractTreePresenter >> replayChildItemsOf: anItem [

	^ (self childrenFor: anItem) asArray
]

{ #category : '*Replay' }
SpAbstractTreePresenter >> replayLabelOfItem: anItem [
	"The text that I show for anItem, for Replay to find it by label"

	^ anItem asString
]

{ #category : '*Replay' }
SpAbstractTreePresenter >> replayRootItems [
	"My roots, from which Replay finds an item by the labels of its path"

	^ self roots asArray
]

{ #category : '*Replay' }
SpAbstractTreePresenter >> replaySelectItemAt: aPath [
	"Expand the parents of my item at aPath, a path of indexes from a root, and select it, as a Replay action does. Scrolling to it waits for a widget, so I only ask for it when there is one."

	aPath size > 1 ifTrue: [ self expandPath: aPath allButLast ].
	self adapter
		ifNil: [ self selectPath: aPath ]
		ifNotNil: [ self selectPath: aPath scrollToSelection: true ]
]

{ #category : '*Replay' }
SpAbstractTreePresenter >> replaySelectsItems [

	^ true
]

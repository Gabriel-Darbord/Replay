Extension { #name : 'SpAbstractListPresenter' }

{ #category : '*Replay' }
SpAbstractListPresenter >> replayLabelOfItem: anItem [
	"The text that I show for anItem, for Replay to find it by label"

	^ anItem asString
]

{ #category : '*Replay' }
SpAbstractListPresenter >> replayRootItems [
	"My items, which Replay finds by label"

	^ self items asArray
]

{ #category : '*Replay' }
SpAbstractListPresenter >> replaySelectItemAt: aPath [
	"Select my item at the index aPath holds, as a Replay action does. Scrolling to it waits for a widget, so I only ask for it when there is one."

	self adapter
		ifNil: [ self selectIndex: aPath first ]
		ifNotNil: [ self selectIndex: aPath first scrollToSelection: true ]
]

{ #category : '*Replay' }
SpAbstractListPresenter >> replaySelectsItems [

	^ true
]

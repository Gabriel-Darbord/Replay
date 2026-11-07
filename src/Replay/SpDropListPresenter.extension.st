Extension { #name : 'SpDropListPresenter' }

{ #category : '*Replay' }
SpDropListPresenter >> replayLabelOfItem: anItem [
	"The text that I show for anItem, for Replay to find it by label"

	^ (self display cull: anItem) asString
]

{ #category : '*Replay' }
SpDropListPresenter >> replayRootItems [
	"My items, which Replay finds by label"

	^ self items asArray
]

{ #category : '*Replay' }
SpDropListPresenter >> replaySelectItemAt: aPath [
	"Select my item at the index aPath holds, as a Replay action does"

	self selectIndex: aPath first
]

{ #category : '*Replay' }
SpDropListPresenter >> replaySelectsItems [

	^ true
]

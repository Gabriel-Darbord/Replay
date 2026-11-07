Extension { #name : 'SpNotebookPresenter' }

{ #category : '*Replay' }
SpNotebookPresenter >> replayUnnamedChildrenDo: aBlock [
	"Also the presenters of my pages that were shown"

	super replayUnnamedChildrenDo: aBlock.
	self pages do: [ :page |
		page activePresenter ifNotNil: [ :presenter | aBlock value: nil value: presenter ] ]
]

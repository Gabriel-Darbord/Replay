Extension { #name : 'SpTablePresenter' }

{ #category : '*Replay' }
SpTablePresenter >> replayLabelOfItem: anItem [
	"The text of anItem in my first text column"

	^ (self replayLabelOf: anItem inColumns: self columns) ifNil: [
		  super replayLabelOfItem: anItem ]
]

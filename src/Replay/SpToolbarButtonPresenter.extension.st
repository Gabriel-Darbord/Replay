Extension { #name : 'SpToolbarButtonPresenter' }

{ #category : '*Replay' }
SpToolbarButtonPresenter >> replayCanClickNatively [

	^ self isEnabled and: [ self isVisible ]
]

{ #category : '*Replay' }
SpToolbarButtonPresenter >> replayClickNatively [
	"As my Morphic adapter does on a click"

	self action ifNotNil: [ :actionBlock | actionBlock cull: self ]
]

Extension { #name : 'SpToolbarToggleButtonPresenter' }

{ #category : '*Replay' }
SpToolbarToggleButtonPresenter >> replayClickNatively [
	"As my Morphic adapter does on a click: toggle, then run the action"

	self toggle.
	super replayClickNatively
]

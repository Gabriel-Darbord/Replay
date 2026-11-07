Extension { #name : 'SpButtonPresenter' }

{ #category : '*Replay' }
SpButtonPresenter >> replayCanClickNatively [

	^ self isEnabled and: [ self isVisible ]
]

{ #category : '*Replay' }
SpButtonPresenter >> replayClickNatively [

	self performAction
]

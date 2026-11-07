Extension { #name : 'SpLinkPresenter' }

{ #category : '*Replay' }
SpLinkPresenter >> replayCanClickNatively [

	^ self isEnabled and: [ self isVisible ]
]

{ #category : '*Replay' }
SpLinkPresenter >> replayClickNatively [

	self performAction
]

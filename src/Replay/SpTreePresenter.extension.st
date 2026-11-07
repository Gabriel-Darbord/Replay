Extension { #name : 'SpTreePresenter' }

{ #category : '*Replay' }
SpTreePresenter >> replayLabelOfItem: anItem [

	^ (self display value: anItem) asString
]

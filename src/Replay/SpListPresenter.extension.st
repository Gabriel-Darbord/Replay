Extension { #name : 'SpListPresenter' }

{ #category : '*Replay' }
SpListPresenter >> replayLabelOfItem: anItem [

	^ (self display value: anItem) asString
]

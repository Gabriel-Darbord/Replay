Extension { #name : 'SpPresenter' }

{ #category : '*Replay' }
SpPresenter >> replayUnnamedChildrenDo: aBlock [
	"The presenters of my layout"

	self layout ifNil: [ ^ self ].
	self layout allPresenters do: [ :each |
		each isPresenter ifTrue: [ aBlock value: nil value: each ] ]
]

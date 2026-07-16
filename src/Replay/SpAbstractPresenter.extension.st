Extension { #name : 'SpAbstractPresenter' }

{ #category : '*Replay' }
SpAbstractPresenter >> replayPresenterAt: aPresenterName ifAbsent: absentBlock [
	"Answer a named child presenter for Replay semantic UI actions. Presenters can override this method to expose stable semantic names."

	^ absentBlock value
]

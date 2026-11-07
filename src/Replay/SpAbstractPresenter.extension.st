Extension { #name : 'SpAbstractPresenter' }

{ #category : '*Replay' }
SpAbstractPresenter >> replayDefaultPresenterAt: aPresenterName ifAbsent: absentBlock [
	"The subpresenter that aPresenterName names by default (see replayPresenterAt:ifAbsent:), or the value of absentBlock"

	| separator child |
	separator := aPresenterName indexOf: $..
	separator = 0 ifTrue: [
		^ (self replayDescendantNamed: aPresenterName) ifNil: absentBlock ].
	child := (self replayDescendantNamed: (aPresenterName first: separator - 1))
		         ifNil: [ ^ absentBlock value ].
	^ child
		  replayPresenterAt: (aPresenterName allButFirst: separator)
		  ifAbsent: absentBlock
]

{ #category : '*Replay' }
SpAbstractPresenter >> replayDescendantNamed: aString [
	"My nearest descendant named aString (see replayNamedChildrenDo:), breadth first, or nil"

	| queue visited |
	queue := OrderedCollection with: self.
	visited := IdentitySet with: self.
	[ queue isEmpty ] whileFalse: [
		| presenter |
		presenter := queue removeFirst.
		presenter replayNamedChildrenDo: [ :name :child |
			name = aString ifTrue: [ ^ child ] ].
		presenter replayNamedChildrenDo: [ :name :child |
			(visited includes: child) ifFalse: [
				visited add: child.
				queue add: child ] ] ].
	^ nil
]

{ #category : '*Replay' }
SpAbstractPresenter >> replayHasAncestor: aPresenter [
	"Whether aPresenter is up my chain of owners"

	| current |
	current := owner.
	[ current isNil ] whileFalse: [
		current == aPresenter ifTrue: [ ^ true ].
		current := current owner ].
	^ false
]

{ #category : '*Replay' }
SpAbstractPresenter >> replayNameOfPresenterWith: aMorph [
	"The shortest name that resolves, from me, to the descendant of mine whose widget is aMorph, or nil when there is none.
	A descendant is named by the dotted path of the names leading to it from me, or a suffix of that path when the suffix also leads to it."

	| queue visited |
	queue := OrderedCollection with: self -> ''.
	visited := IdentitySet with: self.
	[ queue isEmpty ] whileFalse: [
		| entry |
		entry := queue removeFirst.
		entry key replayNamedChildrenDo: [ :name :child |
			(visited includes: child) ifFalse: [
				| path |
				visited add: child.
				path := entry value isEmpty
					        ifTrue: [ name ]
					        ifFalse: [ entry value , '.' , name ].
				(child adapter notNil and: [ child adapter widget == aMorph ])
					ifTrue: [ ^ self replayShortestNameOf: child inPath: path ].
				queue add: child -> path ] ] ].
	^ nil
]

{ #category : '*Replay' }
SpAbstractPresenter >> replayNamedChildrenDo: aBlock [
	"Evaluate aBlock with the name and the presenter of each of my named subpresenters: the presenters held by my instance variables, other than those of Spec itself (such as my owner) and my ancestors, and the presenters stored by key in my additional subpresenters map, named by their key"

	| frameworkNames |
	frameworkNames := SpPresenter allInstVarNames.
	self class allInstVarNames doWithIndex: [ :name :index |
		(frameworkNames includes: name) ifFalse: [
			| value |
			value := self instVarAt: index.
			((value isKindOf: SpAbstractPresenter) and: [
				 value ~~ self and: [ (self replayHasAncestor: value) not ] ])
				ifTrue: [ aBlock value: name value: value ] ] ].
	(self class allInstVarNames includes: 'additionalSubpresentersMap')
		ifFalse: [ ^ self ].
	(self instVarNamed: 'additionalSubpresentersMap') ifNotNil: [ :map |
		map keysAndValuesDo: [ :key :value |
			(value isKindOf: SpAbstractPresenter) ifTrue: [
				aBlock value: key asString value: value ] ] ]
]

{ #category : '*Replay' }
SpAbstractPresenter >> replayPresenterAt: aPresenterName ifAbsent: absentBlock [
	"Answer a subpresenter named aPresenterName for Replay actions, or the value of absentBlock.
	By default, a subpresenter is named after the instance variable holding it, such as 'runButton', or after its key in the additional subpresenters map of dynamic presenters. A single name that is not one of mine names my nearest descendant with that name, and a dotted path such as 'toolbar.runButton' names a subpresenter of a subpresenter.
	Presenters override me to expose other names, such as names that do not depend on their implementation."

	^ self replayDefaultPresenterAt: aPresenterName ifAbsent: absentBlock
]

{ #category : '*Replay' }
SpAbstractPresenter >> replayShortestNameOf: aPresenter inPath: aPath [
	"The shortest suffix of aPath, a dotted path from me to aPresenter, that I resolve to aPresenter, or nil"

	| segments |
	segments := aPath substrings: '.'.
	segments size to: 1 by: -1 do: [ :start |
		| name |
		name := '.' join: (segments copyFrom: start to: segments size).
		(self replayPresenterAt: name ifAbsent: [ nil ]) == aPresenter ifTrue: [
			^ name ] ].
	^ nil
]

{ #category : '*Replay' }
SpAbstractPresenter >> replayCanClickNatively [
	"Answer whether a Replay click can act on me without my widget, as a click on my widget would"

	^ false
]

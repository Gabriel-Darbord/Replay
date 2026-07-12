Class {
	#name : 'ReplayMacroContext',
	#superclass : 'Object',
	#instVars : [
		'identifier',
		'displayName',
		'categoryNames',
		'conflictCategoryNames'
	],
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'defaults' }
ReplayMacroContext class >> availableContexts [

	| contexts knownCategoryNames fallbackContexts |
	contexts := self defaultContexts copy.
	knownCategoryNames := (contexts flatCollect: [ :context | context categoryNames ]) asSet.
	fallbackContexts := KMRepository default categories values
		select: [ :category |
			category allEntries keymaps notEmpty
				and: [ (knownCategoryNames includes: category name) not ] ]
		thenCollect: [ :category | self forCategory: category ].
	contexts addAll: (fallbackContexts sorted: [ :first :second |
		first displayName < second displayName ]).
	^ contexts
]

{ #category : 'detecting' }
ReplayMacroContext class >> categoryNames: firstCategoryNames overlapCategoryNames: secondCategoryNames [

	^ firstCategoryNames anySatisfy: [ :categoryName |
		secondCategoryNames includes: categoryName ]
]

{ #category : 'detecting' }
ReplayMacroContext class >> categoryNamesDirectlyAttachedToMorph: aMorph [

	^ aMorph kmDispatcher targets collect: [ :binding | binding category name ]
]

{ #category : 'detecting' }
ReplayMacroContext class >> categoryNamesForMorph: aMorph [

	| categoryNames |
	aMorph ifNil: [ ^ #() ].
	(aMorph isKindOf: Morph) ifFalse: [ ^ #() ].
	categoryNames := OrderedCollection new.
	aMorph allOwnersDo: [ :owner |
		categoryNames addAll: (self categoryNamesDirectlyAttachedToMorph: owner) ].
	aMorph allMorphsDo: [ :morph |
		categoryNames addAll: (self categoryNamesDirectlyAttachedToMorph: morph) ].
	^ (categoryNames asSet asArray sorted: [ :first :second | first asString <= second asString ]) asOrderedCollection
]

{ #category : 'detecting' }
ReplayMacroContext class >> compositeConflictCategoryNamesBetween: firstCategoryNames and: secondCategoryNames [

	| names |
	names := self defaultContexts
		select: [ :context |
			(self categoryNames: firstCategoryNames overlapCategoryNames: context conflictCategoryNames)
				and: [ self categoryNames: secondCategoryNames overlapCategoryNames: context conflictCategoryNames ] ]
		thenCollect: [ :context | context categoryNames first ].
	^ (names asSet asArray sorted: [ :first :second | first asString <= second asString ]) asOrderedCollection
]

{ #category : 'detecting' }
ReplayMacroContext class >> conflictCategoryNamesForCategoryName: aSymbol [

	| contexts names |
	contexts := self defaultContexts select: [ :context |
		context categoryNames includes: aSymbol ].
	contexts ifEmpty: [ ^ { aSymbol } asOrderedCollection ].
	names := contexts flatCollect: [ :context | context conflictCategoryNames ].
	^ (names asSet asArray sorted: [ :first :second | first asString <= second asString ]) asOrderedCollection
]

{ #category : 'detecting' }
ReplayMacroContext class >> conflictCategoryNamesForCategoryNames: aCollection [

	| names |
	names := aCollection flatCollect: [ :categoryName |
		self conflictCategoryNamesForCategoryName: categoryName ].
	^ (names asSet asArray sorted: [ :first :second | first asString <= second asString ]) asOrderedCollection
]

{ #category : 'defaults' }
ReplayMacroContext class >> defaultContexts [

	^ {
		self
			identifier: #textEditors
			displayName: 'Text editors'
			categoryNames: { #RubTextEditor }.
		self
			identifier: #smalltalkEditors
			displayName: 'Smalltalk code editors'
			categoryNames: { #RubSmalltalkEditor }
			conflictCategoryNames: { #RubSmalltalkEditor. #RubTextEditor }.
		self
			identifier: #morphicNavigation
			displayName: 'Morphic navigation'
			categoryNames: { #MorphCtrlNavigation }.
		self
			identifier: #windows
			displayName: 'Windows'
			categoryNames: { #WindowShortcuts } } asOrderedCollection
]

{ #category : 'instance creation' }
ReplayMacroContext class >> forCategory: aKMCategory [

	^ self
		identifier: aKMCategory name
		displayName: (ReplayShortcutConflict displayNameForCategoryName: aKMCategory name)
		categoryNames: { aKMCategory name }
]

{ #category : 'detecting' }
ReplayMacroContext class >> forMorph: aMorph [

	| categoryNames displayName |
	categoryNames := self categoryNamesForMorph: aMorph.
	displayName := categoryNames isEmpty
		ifTrue: [ 'Active UI' ]
		ifFalse: [ 'Active UI: ' , (', ' join: (categoryNames collect: [ :categoryName | ReplayShortcutConflict displayNameForCategoryName: categoryName ])) ].
	^ self identifier: #activeUI displayName: displayName categoryNames: categoryNames
]

{ #category : 'instance creation' }
ReplayMacroContext class >> identifier: aSymbol displayName: aString categoryNames: aCollection [

	^ self
		identifier: aSymbol
		displayName: aString
		categoryNames: aCollection
		conflictCategoryNames: aCollection
]

{ #category : 'instance creation' }
ReplayMacroContext class >> identifier: aSymbol displayName: aString categoryNames: categoryCollection conflictCategoryNames: conflictCollection [

	^ self new
		identifier: aSymbol;
		displayName: aString;
		categoryNames: categoryCollection;
		conflictCategoryNames: conflictCollection;
		yourself
]

{ #category : 'detecting' }
ReplayMacroContext class >> internalConflictCategoryNamesBetween: firstCategoryNames and: secondCategoryNames [

	| exact |
	exact := firstCategoryNames select: [ :categoryName |
		secondCategoryNames includes: categoryName ].
	exact ifNotEmpty: [ ^ exact asOrderedCollection ].
	^ self
		compositeConflictCategoryNamesBetween: firstCategoryNames
		and: secondCategoryNames
]

{ #category : 'accessing' }
ReplayMacroContext >> categories [

	^ self categoryNames collect: [ :categoryName |
		KMRepository default categoryForName: categoryName ]
]

{ #category : 'accessing' }
ReplayMacroContext >> categoryNames [

	^ categoryNames ifNil: [ categoryNames := #() ]
]

{ #category : 'accessing' }
ReplayMacroContext >> categoryNames: aCollection [

	categoryNames := aCollection asOrderedCollection
]

{ #category : 'accessing' }
ReplayMacroContext >> conflictCategories [

	^ self conflictCategoryNames collect: [ :categoryName |
		KMRepository default categoryForName: categoryName ]
]

{ #category : 'accessing' }
ReplayMacroContext >> conflictCategoryNames [

	^ conflictCategoryNames ifNil: [ self categoryNames ]
]

{ #category : 'accessing' }
ReplayMacroContext >> conflictCategoryNames: aCollection [

	conflictCategoryNames := aCollection asOrderedCollection
]

{ #category : 'accessing' }
ReplayMacroContext >> displayName [

	^ displayName
]

{ #category : 'accessing' }
ReplayMacroContext >> displayName: aString [

	displayName := aString
]

{ #category : 'accessing' }
ReplayMacroContext >> identifier [

	^ identifier
]

{ #category : 'accessing' }
ReplayMacroContext >> identifier: aSymbol [

	identifier := aSymbol
]

{ #category : 'testing' }
ReplayMacroContext >> matchesCategoryNames: aCollection [

	^ self categoryNames asSet = aCollection asSet
]

{ #category : 'printing' }
ReplayMacroContext >> printOn: aStream [

	aStream nextPutAll: self displayName
]

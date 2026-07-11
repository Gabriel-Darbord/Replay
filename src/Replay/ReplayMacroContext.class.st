Class {
	#name : 'ReplayMacroContext',
	#superclass : 'Object',
	#instVars : [
		'identifier',
		'displayName',
		'categoryNames'
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
ReplayMacroContext class >> categoryNamesForMorph: aMorph [

	| categories |
	aMorph ifNil: [ ^ #() ].
	(aMorph isKindOf: Morph) ifFalse: [ ^ #() ].
	categories := aMorph kmDispatcher targets collect: [ :binding | binding category name ].
	^ (categories asSet asArray sorted: [ :first :second | first asString <= second asString ]) asOrderedCollection
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
			categoryNames: { #RubSmalltalkEditor }.
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

	^ self new
		identifier: aSymbol;
		displayName: aString;
		categoryNames: aCollection;
		yourself
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

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

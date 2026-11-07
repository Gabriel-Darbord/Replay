"
I describe a keymap context offered to users for installing macros: a display name and the Keymapping category names a macro is installed in, plus the categories checked for conflicts (a Smalltalk code editor also answers to the text editor shortcuts).

My class side knows the default contexts, falls back to one context per other non-empty category, and turns category names into user-facing names.
"
Class {
	#name : 'ReplayMacroContext',
	#superclass : 'Object',
	#instVars : [
		'identifier',
		'displayName',
		'categoryNames',
		'conflictCategoryNames'
	],
	#category : 'Replay-Macros',
	#package : 'Replay',
	#tag : 'Macros'
}

{ #category : 'defaults' }
ReplayMacroContext class >> anywhereContext [

	^ self
		identifier: #anywhere
		displayName: 'Everywhere'
		categoryNames: self installableCategoryNames
		conflictCategoryNames: self installableCategoryNames
]

{ #category : 'defaults' }
ReplayMacroContext class >> availableContexts [

	| contexts knownCategoryNames fallbackContexts |
	contexts := self defaultContexts copy.
	knownCategoryNames := ((contexts reject: [ :context | context isComposite ])
		flatCollect: [ :context | context categoryNames ]) asSet.
	fallbackContexts := KMRepository default categories values
		select: [ :category |
			category allEntries keymaps notEmpty and: [
				(knownCategoryNames includes: category name) not ] ]
		thenCollect: [ :category | self forCategory: category ].
	contexts addAll: (fallbackContexts sorted: [ :first :second | first displayName <= second displayName ]).
	^ contexts
]

{ #category : 'detecting' }
ReplayMacroContext class >> categoryNames: firstCategoryNames overlapCategoryNames: secondCategoryNames [

	^ firstCategoryNames anySatisfy: [ :categoryName |
		secondCategoryNames includes: categoryName ]
]

{ #category : 'detecting' }
ReplayMacroContext class >> compositeConflictCategoryNamesBetween: firstCategoryNames and: secondCategoryNames [

	| names |
	names := self defaultContexts
		select: [ :context |
			context isComposite not and: [
				(self categoryNames: firstCategoryNames overlapCategoryNames: context conflictCategoryNames)
					and: [ self categoryNames: secondCategoryNames overlapCategoryNames: context conflictCategoryNames ] ] ]
		thenCollect: [ :context | context categoryNames first ].
	^ (names asSet asArray sorted: [ :first :second | first asString <= second asString ]) asOrderedCollection
]

{ #category : 'detecting' }
ReplayMacroContext class >> conflictCategoryNamesForCategoryName: aSymbol [

	| contexts names |
	contexts := self defaultContexts select: [ :context |
		context isComposite not and: [ context categoryNames includes: aSymbol ] ].
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
		self anywhereContext.
		self identifier: #textEditors displayName: 'Text editors' categoryNames: { #RubTextEditor }.
		self identifier: #smalltalkEditors displayName: 'Smalltalk code editors' categoryNames: { #RubSmalltalkEditor } conflictCategoryNames: { #RubSmalltalkEditor. #RubTextEditor }.
		self identifier: #morphicNavigation displayName: 'Morphic navigation' categoryNames: { #MorphCtrlNavigation }.
		self identifier: #windows displayName: 'Windows' categoryNames: { #WindowShortcuts } }
		asOrderedCollection
]

{ #category : 'formatting' }
ReplayMacroContext class >> displayNameForCategoryName: aSymbol [
	"A user-facing name for the keymap category named aSymbol"

	| knownContext technical readable |
	knownContext := self defaultContexts
		detect: [ :context | context isComposite not and: [ context categoryNames includes: aSymbol ] ]
		ifNone: [ nil ].
	knownContext ifNotNil: [ ^ knownContext displayName ].
	technical := aSymbol asString.
	readable := self readableNameForCategoryName: technical.
	^ readable = technical
		ifTrue: [ technical ]
		ifFalse: [ readable , ' (' , technical , ')' ]
]

{ #category : 'instance creation' }
ReplayMacroContext class >> forCategory: aKMCategory [

	^ self
		identifier: aKMCategory name
		displayName: (self displayNameForCategoryName: aKMCategory name)
		categoryNames: { aKMCategory name }
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

{ #category : 'defaults' }
ReplayMacroContext class >> installableCategoryNames [

	| names |
	names := KMRepository default categories values
		select: [ :category |
			category allEntries keymaps notEmpty and: [
				(category name asString beginsWith: 'Replay') not ] ]
		thenCollect: [ :category | category name ].
	^ (names asSet asArray sorted: [ :first :second | first asString <= second asString ]) asOrderedCollection
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

{ #category : 'formatting' }
ReplayMacroContext class >> readableNameForCategoryName: aString [

	| source words |
	source := (aString beginsWith: 'Rub')
		ifTrue: [ aString allButFirst: 3 ]
		ifFalse: [ aString ].
	words := String streamContents: [ :stream |
		source withIndexDo: [ :character :index |
			(index > 1 and: [
				character isUppercase and: [
					(source at: index - 1) isLowercase
						or: [ index < source size and: [ (source at: index + 1) isLowercase ] ] ] ])
				ifTrue: [ stream space ].
			stream nextPut: character ] ].
	^ words asLowercase capitalized
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
ReplayMacroContext >> isComposite [

	^ self identifier = #anywhere
]

{ #category : 'testing' }
ReplayMacroContext >> matchesCategoryNames: aCollection [

	^ self categoryNames asSet = aCollection asSet
]

{ #category : 'printing' }
ReplayMacroContext >> printOn: aStream [

	aStream nextPutAll: self displayName
]

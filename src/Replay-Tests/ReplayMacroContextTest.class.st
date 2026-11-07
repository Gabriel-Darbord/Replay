"
I test ReplayMacroContext, the keymap contexts offered for installing macros and their display names, and ReplayShortcutConflict.
"
Class {
	#name : 'ReplayMacroContextTest',
	#superclass : 'ReplayMacroTestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayMacroContextTest >> findConflict [

	| category |
	category := KMRepository default categoryForName: #RubTextEditor.
	^ ReplayShortcutConflict category: category keymap: (category keymapNamed: #find)
]

{ #category : 'tests' }
ReplayMacroContextTest >> testAvailableContextsKeepIndividualFallbackContexts [

	| contexts everywhere simpleList |
	contexts := ReplayMacroContext availableContexts.
	everywhere := contexts detect: [ :context | context identifier = #anywhere ].
	simpleList := contexts detect: [ :context | context identifier = #SimpleHierarchicalList ] ifNone: [ nil ].
	self assert: everywhere displayName equals: 'Everywhere'.
	(KMRepository default categories includesKey: #SimpleHierarchicalList) ifTrue: [
		self assert: simpleList notNil.
		self assert: simpleList categoryNames asArray equals: { #SimpleHierarchicalList } ]
]

{ #category : 'tests' }
ReplayMacroContextTest >> testConflictShowsReadableContextDisplayName [

	self assert: self findConflict contextDisplayName equals: 'Text editors'
]

{ #category : 'tests' }
ReplayMacroContextTest >> testConflictUsesCommandDisplayForMetaShortcut [

	self assert: self findConflict shortcutString equals: 'Command + F'
]

{ #category : 'tests' }
ReplayMacroContextTest >> testConflictWithMacroKeymapIsNamedAfterTheMacro [

	| macro conflict |
	macro := self macroNamed: 'Other macro' keyBinding: (self controlShortcut: 'f').
	conflict := ReplayShortcutConflict
		            category: (KMRepository default categoryForName: #RubTextEditor)
		            keymap: macro keymap.

	self assert: conflict name equals: 'Other macro'.
	self assert: self findConflict name equals: #find
]

{ #category : 'tests' }
ReplayMacroContextTest >> testDefaultContextsExposeAnyContext [

	| contexts anyContext |
	contexts := ReplayMacroContext defaultContexts.
	anyContext := contexts detect: [ :context | context identifier = #anywhere ].
	self assert: anyContext displayName equals: 'Everywhere'.
	self assert: anyContext isComposite.
	self assert: (anyContext categoryNames includes: #RubTextEditor).
	self assert: (anyContext categoryNames includes: #MorphCtrlNavigation).
	self assert: (anyContext categoryNames includes: #WindowShortcuts).
	self deny: (anyContext categoryNames anySatisfy: [ :categoryName |
			 categoryName asString beginsWith: 'Replay' ])
]

{ #category : 'tests' }
ReplayMacroContextTest >> testDefaultContextsExposeUserFacingChoices [

	| contexts textContext codeContext morphicContext windowContext |
	contexts := ReplayMacroContext defaultContexts.
	textContext := contexts detect: [ :context | context identifier = #textEditors ].
	codeContext := contexts detect: [ :context | context identifier = #smalltalkEditors ].
	morphicContext := contexts detect: [ :context | context identifier = #morphicNavigation ].
	windowContext := contexts detect: [ :context | context identifier = #windows ].
	self assert: textContext displayName equals: 'Text editors'.
	self assert: textContext categoryNames asArray equals: { #RubTextEditor }.
	self assert: textContext conflictCategoryNames asArray equals: { #RubTextEditor }.
	self assert: codeContext displayName equals: 'Smalltalk code editors'.
	self assert: codeContext categoryNames asArray equals: { #RubSmalltalkEditor }.
	self assert: codeContext conflictCategoryNames asArray equals: { #RubSmalltalkEditor. #RubTextEditor }.
	self assert: morphicContext displayName equals: 'Morphic navigation'.
	self assert: morphicContext categoryNames asArray equals: { #MorphCtrlNavigation }.
	self assert: windowContext displayName equals: 'Windows'.
	self assert: windowContext categoryNames asArray equals: { #WindowShortcuts }
]

{ #category : 'tests' }
ReplayMacroContextTest >> testDisplayNameForCategoryName [

	self assert: (ReplayMacroContext displayNameForCategoryName: #RubTextEditor) equals: 'Text editors'.
	self
		assert: (ReplayMacroContext displayNameForCategoryName: #MorphFocusNavigation)
		equals: 'Morph focus navigation (MorphFocusNavigation)'.
	self assert: (ReplayMacroContext displayNameForCategoryName: #Lowercase) equals: 'Lowercase'
]

{ #category : 'tests' }
ReplayMacroContextTest >> testForCategoryUsesDisplayName [

	| context |
	context := ReplayMacroContext forCategory: (KMCategory named: #MorphFocusNavigation).
	self assert: context identifier equals: #MorphFocusNavigation.
	self assert: context categoryNames asArray equals: { #MorphFocusNavigation }.
	self assert: context displayName equals: 'Morph focus navigation (MorphFocusNavigation)'
]

{ #category : 'tests' }
ReplayMacroContextTest >> testSmalltalkEditorsConflictWithTextEditors [
	"Everywhere covers every context, but is not a reason for two other contexts to conflict"

	self
		assert: (ReplayMacroContext conflictCategoryNamesForCategoryNames: { #RubSmalltalkEditor }) asArray
		equals: { #RubSmalltalkEditor. #RubTextEditor }.
	self
		assert: (ReplayMacroContext conflictCategoryNamesForCategoryNames: { #WindowShortcuts }) asArray
		equals: { #WindowShortcuts }.
	self
		assert: (ReplayMacroContext internalConflictCategoryNamesBetween: { #RubSmalltalkEditor } and: { #RubTextEditor }) asArray
		equals: { #RubSmalltalkEditor }.
	self assert: (ReplayMacroContext internalConflictCategoryNamesBetween: { #RubTextEditor } and: { #WindowShortcuts }) isEmpty
]

{ #category : 'tests' }
ReplayMacroContextTest >> testTextEditorsMapsToRubTextEditor [

	| context |
	context := ReplayMacroContext availableContexts detect: [ :each | each identifier = #textEditors ].

	self assert: context displayName equals: 'Text editors'.
	self assert: context categoryNames asArray equals: { #RubTextEditor }
]

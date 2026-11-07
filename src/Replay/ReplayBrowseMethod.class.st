"
I open a system browser focused on a configured method reference, stored as 'Class#selector' or 'Class class#selector'.
"
Class {
	#name : 'ReplayBrowseMethod',
	#superclass : 'ReplayBrowse',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayBrowseMethod class >> displayName [

	^ 'Browse Method'
]

{ #category : 'editing' }
ReplayBrowseMethod >> settingsPresenterOn: editor [
	"The method browser selects its first method by itself: the target is only changed when the user selects a method."

	| presenter classList methodList method classes |
	classes := OrderedCollection new.
	self class environment allClassesDo: [ :each |
		classes
			add: each;
			add: each class ].
	(presenter := SpClassMethodBrowser new)
		owner: editor;
		classes: (classes sort: [ :a :b | a name <= b name ]) asArray.
	editor registerReplayPresenter: presenter named: 'Browse method browser'.

	classList := presenter instVarNamed: #classListPresenter.
	methodList := presenter instVarNamed: #methodListPresenter.
	editor registerReplayPresenter: methodList named: 'Browse method target'.
	target ifNotNil: [
		method := self targetMethod.
		classList selectItem: method methodClass scrollToSelection: true.
		methodList selectItem: method scrollToSelection: true ].

	methodList whenSelectedDo: [ :aMethod |
		aMethod ifNotNil: [
			self targetMethod: aMethod.
			editor actionChanged: self ] ].
	^ editor newPresenter
		layout: (SpBoxLayout newTopToBottom
				spacing: 10;
				add: presenter;
				add: (self placementPresenterOn: editor) expand: false;
				yourself);
		yourself
]

{ #category : 'accessing' }
ReplayBrowseMethod >> targetMethod [

	| parts class |
	target ifNil: [ self missingTarget: 'No method to browse is selected.' ].
	parts := $# split: target. "= '{class}#{selector}', class can be 'Foo class'"
	parts size = 2 ifFalse: [
		self missingTarget: 'Invalid method to browse: ' , target , '.' ].
	class := (self class environment classNamed: parts first) ifNil: [
		self missingTarget: 'Cannot find the class of the method to browse: ' , target , '.' ].
	^ class
		  compiledMethodAt: parts second asSymbol
		  ifAbsent: [ self missingTarget: 'Cannot find the method to browse: ' , target , '.' ]
]

{ #category : 'accessing' }
ReplayBrowseMethod >> targetMethod: aMethod [

	target := aMethod methodClass name , '#' , aMethod selector
]

{ #category : 'accessing' }
ReplayBrowseMethod >> targetType [

	^ CompiledMethod
]

{ #category : 'managing UI' }
ReplayBrowseMethod >> uiOn: runner [

	^ self browser selectMethod: self targetMethod
]

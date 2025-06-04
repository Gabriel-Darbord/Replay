"
Opens a browser on a method.
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

	| presenter methodList |
	(presenter := SpClassMethodBrowser new)
		owner: editor;
		classes: self class environment allClasses.

	methodList := presenter instVarNamed: #methodListPresenter.
	self targetMethod: methodList items first.

	methodList whenSelectedDo: [ :aMethod |
		self targetMethod: aMethod.
		editor actions rebuildLayout ].
	^ presenter
]

{ #category : 'accessing' }
ReplayBrowseMethod >> targetMethod [

	| parts class |
	parts := $# split: target.
	class := self class environment at: parts first asSymbol.
	^ class >> parts second asSymbol
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

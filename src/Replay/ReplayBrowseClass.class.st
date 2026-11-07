"
I open a system browser focused on a configured class name.
"
Class {
	#name : 'ReplayBrowseClass',
	#superclass : 'ReplayBrowse',
	#category : 'Replay-Actions',
	#package : 'Replay',
	#tag : 'Actions'
}

{ #category : 'accessing' }
ReplayBrowseClass class >> displayName [

	^ 'Browse Class'
]

{ #category : 'editing' }
ReplayBrowseClass >> settingsPresenterOn: editor [
	"Without a target, nothing is selected until the user chooses a class."

	| presenter |
	(presenter := editor newList)
		help: 'Select class browse';
		items: (self class environment allClasses sorted: [ :a :b | a name <= b name ]).
	editor registerReplayPresenter: presenter named: 'Browse class target'.
	target ifNotNil: [
		presenter selectItem: self targetClass scrollToSelection: true ].
	presenter whenSelectedDo: [ :aClass |
		aClass ifNotNil: [
			self targetClass: aClass.
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
ReplayBrowseClass >> targetClass [

	target ifNil: [ self missingTarget: 'No class to browse is selected.' ].
	^ (self class environment classNamed: target) ifNil: [
		  self missingTarget: 'Cannot find the class to browse: ' , target , '.' ]
]

{ #category : 'accessing' }
ReplayBrowseClass >> targetClass: aClass [

	target := aClass name
]

{ #category : 'accessing' }
ReplayBrowseClass >> targetType [

	^ Class
]

{ #category : 'managing UI' }
ReplayBrowseClass >> uiOn: runner [

	^ self browser selectClass: self targetClass
]

"
I edit a ReplayBrowseMethod: the method to browse, chosen in a class and method browser registered as 'Action method browser', whose method list is registered as 'Action method'. The browser selects its first method by itself: the target only changes when the user selects a method.
"
Class {
	#name : 'ReplayBrowseMethodEditor',
	#superclass : 'ReplayBrowseEditor',
	#category : 'Replay-Editing',
	#package : 'Replay',
	#tag : 'Editing'
}

{ #category : 'building' }
ReplayBrowseMethodEditor >> newTargetList [

	| browser classList methodList method classes |
	classes := OrderedCollection new.
	self class environment allClassesDo: [ :each |
		classes
			add: each;
			add: each class ].
	(browser := self instantiate: SpClassMethodBrowser)
		classes: (classes sort: [ :a :b | a name <= b name ]) asArray.
	classList := browser instVarNamed: #classListPresenter.
	methodList := browser instVarNamed: #methodListPresenter.
	action target ifNotNil: [
		method := action targetMethod.
		classList selectItem: method methodClass scrollToSelection: true.
		methodList selectItem: method scrollToSelection: true ].
	methodList whenSelectedDo: [ :aMethod |
		aMethod ifNotNil: [
			action targetMethod: aMethod.
			self actionChanged ] ].
	self register: methodList as: 'method'.
	^ self register: browser as: 'method browser'
]

{ #category : 'accessing' }
ReplayBrowseMethodEditor >> targetLabel [

	^ 'method'
]

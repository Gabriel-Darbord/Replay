"
I am responsible for executing a specific configurable task.
An action is part of a `ReplayStep`.
"
Class {
	#name : 'ReplayAction',
	#superclass : 'Object',
	#category : 'Replay',
	#package : 'Replay'
}

{ #category : 'editing' }
ReplayAction class >> actionsForDropList [

	^ self selectActions: [ :action | action shouldBeDropListElement ]
]

{ #category : 'editing' }
ReplayAction class >> actionsForMenu [

	^ self selectActions: [ :action | action shouldBeMenuItem ]
]

{ #category : 'editing' }
ReplayAction class >> actionsThatOpenUI [

	^ ReplayOpenUI selectActions: [ :action | true ]
]

{ #category : 'accessing' }
ReplayAction class >> displayName [

	self subclassResponsibility
]

{ #category : 'testing' }
ReplayAction class >> isAbstract [

	^ self == ReplayAction
]

{ #category : 'enumerating' }
ReplayAction class >> selectActions: aBlock [

	^ (self allSubclasses select: [ :c |
		   c isAbstract not and: [ aBlock value: c ] ]) sorted: [ :c1 :c2 |
		  c1 name < c2 name ]
]

{ #category : 'testing' }
ReplayAction class >> shouldBeDropListElement [

	^ true
]

{ #category : 'testing' }
ReplayAction class >> shouldBeMenuItem [

	^ false
]

{ #category : 'editing' }
ReplayAction >> editionPresenterOn: editor [
	"Build a presenter on the editor to configure the action"

	^ self noEditionPresenterOn: editor
]

{ #category : 'editing' }
ReplayAction >> helpPresenterOn: editor about: error [
	"If an error happens during editing, the action may present some help"

	^ editor newPresenter
		  layout: (SpBoxLayout newTopToBottom
				   spacing: 10;
				   add: (SpBoxLayout newLeftToRight
						    spacing: 10;
						    add: (self iconNamed: #error) expand: false;
						    add:
							    'Something went wrong, and this action is unable to help.';
						    yourself)
				   expand: false;
				   add: (SpBoxLayout newTopToBottom
						    add: ' Exception message:' expand: false;
						    add: (editor newText beNotEditable text: error printString);
						    yourself);
				   add: (editor newButton
						    icon: (self iconNamed: #bug);
						    label: 'Debug exception';
						    action: [ error debug ])
				   withConstraints: [ :c | c height: 70 ];
				   yourself);
		  yourself
]

{ #category : 'testing' }
ReplayAction >> isClick [

	^ false
]

{ #category : 'testing' }
ReplayAction >> isUICloser [

	^ false
]

{ #category : 'testing' }
ReplayAction >> isUIHandler [

	^ false
]

{ #category : 'testing' }
ReplayAction >> isUIOpener [

	^ false
]

{ #category : 'editing' }
ReplayAction >> noEditionPresenterOn: editor [
	"For actions that cannot be edited"

	^ editor newPresenter
		  layout: (SpBoxLayout newLeftToRight
				   vAlignStart;
				   spacing: 10;
				   add: (self iconNamed: #info) expand: false;
				   add: 'This action cannot be edited';
				   yourself);
		  yourself
]

{ #category : 'printing' }
ReplayAction >> printOn: stream [

	stream nextPutAll: self class displayName
]

{ #category : 'running' }
ReplayAction >> runOn: aReplayRunner [

	self subclassResponsibility
]

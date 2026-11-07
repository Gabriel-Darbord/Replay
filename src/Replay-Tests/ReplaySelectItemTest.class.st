"
Tests for ReplaySelectItem: selecting by label in lists, tables, drop lists and trees, and waiting for the item during a run.
"
Class {
	#name : 'ReplaySelectItemTest',
	#superclass : 'ReplayTestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplaySelectItemTest >> select: labels in: aPresenter [

	(ReplaySelectItem new labels: labels) runOnNative: aPresenter
]

{ #category : 'tests' }
ReplaySelectItemTest >> testALabelPathIsWrittenAsOneString [

	| action |
	action := ReplaySelectItem new labelPath: ' Kernel >  Object > '.
	self assert: action labels equals: #( 'Kernel' 'Object' ).
	self assert: action labelPath equals: 'Kernel > Object'.
	self assert: (STON fromString: (STON toString: action)) labels equals: #( 'Kernel' 'Object' )
]

{ #category : 'tests' }
ReplaySelectItemTest >> testAMissingLabelWaitsAndSaysWhatIsShown [

	| list error |
	list := SpListPresenter new items: #( #one #two ).
	error := [
	         (ReplaySelectItem new labels: #( 'three' ))
		         ensureReadyOn: (ReplayResolvedUIElement
				          backend: ReplaySpecBackend new
				          reference: (ReplayUIReference named: 'items')
				          nativeElement: list
				          morph: nil).
	         nil ]
		         on: ReplayMissingUIError
		         do: [ :missing | missing ].
	self assert: error isNotNil.
	self assert: (error messageText includesSubstring: '''one'', ''two''')
]

{ #category : 'tests' }
ReplaySelectItemTest >> testOnlyTreesTakeAPath [

	self
		should: [ self select: #( 'one' 'more' ) in: (SpListPresenter new items: #( #one )) ]
		raise: ReplayError
]

{ #category : 'tests' }
ReplaySelectItemTest >> testRunWaitsForTheItemToBeShown [

	| pane manager scenario |
	pane := ReplayNamedPanePresenter new.
	pane items items: #(  ).
	manager := ReplayUIManager new managePresenter: pane.
	manager openLabeled: 'Select item'.
	scenario := ReplayScenario new.
	scenario addStep: (ReplayStep new
			 addAction: (ReplaySelectItem new
					  targetNamed: 'items';
					  labels: #( 'late' );
					  yourself);
			 yourself).
	(ReplayRunner on: scenario)
		manager: manager;
		run.
	self deny: pane items selectedItem equals: #late.
	pane items items: #( #early #late ).
	self waitUntil: [ pane items selectedItem = #late ]
]

{ #category : 'tests' }
ReplaySelectItemTest >> testSelectsADropListItemByItsDisplay [

	| dropList |
	dropList := SpDropListPresenter new
		            items: #( 1 2 3 );
		            display: [ :each | 'Item ' , each printString ];
		            yourself.
	self select: #( 'Item 3' ) in: dropList.
	self assert: dropList selectedItem equals: 3
]

{ #category : 'tests' }
ReplaySelectItemTest >> testSelectsAListItemByItsDisplay [

	| list |
	list := SpListPresenter new
		        items: #( 1 2 3 );
		        display: [ :each | 'Item ' , each printString ];
		        yourself.
	self select: #( 'Item 2' ) in: list.
	self assert: list selectedItem equals: 2
]

{ #category : 'tests' }
ReplaySelectItemTest >> testSelectsATableItemByItsFirstTextColumn [

	| table |
	table := SpTablePresenter new
		         addColumn: (SpStringTableColumn title: 'Name' evaluated: [ :each | each name ]);
		         items: { Object. Morph. String };
		         yourself.
	self select: #( 'Morph' ) in: table.
	self assert: table selectedItem equals: Morph
]

{ #category : 'tests' }
ReplaySelectItemTest >> testSelectsATreeItemByItsPath [

	| tree |
	tree := SpTreePresenter new
		        roots: { Morph };
		        children: [ :each | each subclasses sorted: [ :a :b | a name < b name ] ];
		        display: [ :each | each name ];
		        yourself.
	self select: #( 'Morph' 'BorderedMorph' ) in: tree.
	self assert: tree selectedItem equals: BorderedMorph
]

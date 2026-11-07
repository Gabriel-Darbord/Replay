"
Tests for browse actions: targets, missing targets, and their editors.
"
Class {
	#name : 'ReplayBrowseTest',
	#superclass : 'TestCase',
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'support' }
ReplayBrowseTest >> newEditor [

	^ ReplayEditor on: ReplayScenario new
]

{ #category : 'tests' }
ReplayBrowseTest >> testBrowseClassMissingTargetSignalsReplayError [

	self should: [ ReplayBrowseClass new targetClass ] raise: ReplayError.
	self
		should: [ (ReplayBrowseClass new instVarNamed: #target put: #ReplayNoSuchClass; yourself) targetClass ]
		raise: ReplayError
]

{ #category : 'tests' }
ReplayBrowseTest >> testBrowseClassSettingsKeepUnsetTarget [

	| action editor list |
	action := ReplayBrowseClass new.
	editor := self newEditor.

	editor editAction: action.

	list := editor replayPresenterAt: 'Action class' ifAbsent: [ nil ].
	self assert: list selectedItem isNil.
	self assert: action target isNil.
	self assert: list items first name <= list items second name
]

{ #category : 'tests' }
ReplayBrowseTest >> testBrowseClassSettingsSelectTarget [

	| action editor list |
	action := ReplayBrowseClass new targetClass: ReplayStep; yourself.
	editor := self newEditor.

	editor editAction: action.

	list := editor replayPresenterAt: 'Action class' ifAbsent: [ nil ].
	self assert: list selectedItem equals: ReplayStep.
	self assert: action targetClass equals: ReplayStep
]

{ #category : 'tests' }
ReplayBrowseTest >> testBrowseMethodClassSideTarget [

	| action |
	action := ReplayBrowseMethod new targetMethod: ReplayScenario class >> #example; yourself.

	self assert: action target equals: 'ReplayScenario class#example'.
	self assert: action targetMethod equals: ReplayScenario class >> #example
]

{ #category : 'tests' }
ReplayBrowseTest >> testBrowseMethodMissingTargetSignalsReplayError [

	self should: [ ReplayBrowseMethod new targetMethod ] raise: ReplayError.
	#( 'ReplayNoSuchClass#foo' 'ReplayStep#replayNoSuchSelector' 'ReplayStep' ) do: [ :target |
		self
			should: [ (ReplayBrowseMethod new instVarNamed: #target put: target; yourself) targetMethod ]
			raise: ReplayError ]
]

{ #category : 'tests' }
ReplayBrowseTest >> testBrowseMethodSettingsKeepUnsetTarget [

	| action |
	action := ReplayBrowseMethod new.

	self newEditor editAction: action.

	self assert: action target isNil
]

{ #category : 'tests' }
ReplayBrowseTest >> testBrowseMethodSettingsSelectTarget [

	| action editor methodList |
	action := ReplayBrowseMethod new targetMethod: ReplayScenario class >> #exampleSton; yourself.
	editor := self newEditor.

	editor editAction: action.

	methodList := editor replayPresenterAt: 'Action method' ifAbsent: [ nil ].
	self assert: action target equals: 'ReplayScenario class#exampleSton'.
	self assert: methodList selectedItem equals: ReplayScenario class >> #exampleSton
]

{ #category : 'tests' }
ReplayBrowseTest >> testBrowsePackageMissingTargetSignalsReplayError [

	self should: [ ReplayBrowsePackage new targetPackage ] raise: ReplayError.
	self
		should: [ (ReplayBrowsePackage new instVarNamed: #target put: 'Replay-No-Such-Package'; yourself) targetPackage ]
		raise: ReplayError
]

{ #category : 'tests' }
ReplayBrowseTest >> testBrowsePackageSettingsKeepUnsetTarget [

	| action editor list |
	action := ReplayBrowsePackage new.
	editor := self newEditor.

	editor editAction: action.

	list := editor replayPresenterAt: 'Action package' ifAbsent: [ nil ].
	self assert: list selectedItem isNil.
	self assert: action target isNil
]

{ #category : 'tests' }
ReplayBrowseTest >> testBrowsePackageSettingsSelectTarget [

	| action editor list |
	action := ReplayBrowsePackage new targetPackage: ReplayStep package; yourself.
	editor := self newEditor.

	editor editAction: action.

	list := editor replayPresenterAt: 'Action package' ifAbsent: [ nil ].
	self assert: list selectedItem equals: ReplayStep package.
	self assert: action targetPackage equals: ReplayStep package
]

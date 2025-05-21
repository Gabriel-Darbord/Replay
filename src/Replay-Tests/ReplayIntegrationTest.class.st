Class {
	#name : 'ReplayIntegrationTest',
	#superclass : 'TestCase',
	#instVars : [
		'runner',
		'scenario'
	],
	#category : 'Replay-Tests',
	#package : 'Replay-Tests'
}

{ #category : 'tests' }
ReplayIntegrationTest >> testSmoke [

	(STON fromString:
		 'ReplayScenario{#title:''Test Scenario'',#steps:OrderedCollection[ReplayStep{#actions:OrderedCollection[ReplayBrowseClass{#target:#AColorSelectorMorph},ReplayClick{#path:[3,6,1,2,2,1,3],#buttons:4},ReplayCloseUI{},ReplayBrowseMethod{#target:#''AColorSelectorMorph#initialize''},ReplayAnnotate{#path:[3,7,1,3,5,1,2],#text:''LOL''},ReplayCloseUI{},ReplayBrowsePackage{#target:#AI-Algorithms-Graph},ReplayFocus{#path:[3,5,1,1]},ReplayCloseUI{},ReplayOpenPresenter{#script:''ReplayEditor new''},ReplayInform{#text:''hey''},ReplayScript{#script:''1+1''},ReplayCloseUI{}],#navigation:ReplayNavigate{#skip:true,#acceptLabel:''Next'',#cancelLabel:''Stop'',#text:''''}}],#description:''''}')
		run
]

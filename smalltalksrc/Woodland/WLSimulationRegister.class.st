"
I'm a representation of a simulation register. I'm a helper object for inspection providing accessors #value and #value: to read/write into me.
"
Class {
	#name : #WLSimulationRegister,
	#superclass : #Object,
	#instVars : [
		'processor',
		'name'
	],
	#category : #Woodland
}

{ #category : #'instance-creation' }
WLSimulationRegister class >> on: aProcessor named: registerName [

	^ self new
		processor: aProcessor;
		name: registerName;
		yourself
]

{ #category : #accessing }
WLSimulationRegister >> name [
	^ name
]

{ #category : #accessing }
WLSimulationRegister >> name: aString [ 
	name := aString
]

{ #category : #printing }
WLSimulationRegister >> printOn: aStream [

	aStream
		nextPutAll: self name;
		nextPutAll: ': ';
		nextPutAll: self value hex
]

{ #category : #accessing }
WLSimulationRegister >> processor: aProcessor [
	processor := aProcessor
]

{ #category : #evaluating }
WLSimulationRegister >> value [

	^ processor readRegisterNamed: name
]

{ #category : #accessing }
WLSimulationRegister >> value: anInteger [ 

	^ processor writeRegisterNamed: name value: anInteger
]

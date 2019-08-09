Class {
	#name : #VMMockSchedulerAssociation,
	#superclass : #VMMockObject,
	#instVars : [
		'key',
		'value'
	],
	#category : #VMMakerTests
}

{ #category : #'instance-creation' }
VMMockSchedulerAssociation class >> on: aVMMockProcess [ 
	
	^ self new
		value: aVMMockProcess;
		yourself
]

{ #category : #accessing }
VMMockSchedulerAssociation >> value: aVMMockProcess [ 
	value := aVMMockProcess
]

Class {
	#name : #CoAbstractVMLock,
	#superclass : #VMClass,
	#instVars : [
		'cogit'
	],
	#category : #'VMMaker-Multithreading'
}

{ #category : #initialization }
CoAbstractVMLock >> initializeVMOwnerLock [

	self subclassResponsibility
]

{ #category : #initialization }
CoAbstractVMLock >> tryLockVMOwner [

	self subclassResponsibility
]

{ #category : #initialization }
CoAbstractVMLock >> unlockVMOwner [

	self subclassResponsibility
]

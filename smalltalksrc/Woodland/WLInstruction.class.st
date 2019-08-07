Class {
	#name : #WLInstruction,
	#superclass : #Object,
	#instVars : [
		'address',
		'size',
		'code'
	],
	#category : #Woodland
}

{ #category : #accessing }
WLInstruction >> address [
	^ address
]

{ #category : #accessing }
WLInstruction >> address: anInteger [ 
	address := anInteger
]

{ #category : #accessing }
WLInstruction >> code [
	^ code
]

{ #category : #accessing }
WLInstruction >> code: anObject [
	code := anObject
]

{ #category : #mapping }
WLInstruction >> mapToAddress: anAbsoluteAddress [
	
	address := address + anAbsoluteAddress
]

{ #category : #accessing }
WLInstruction >> size [

	^ size
]

{ #category : #accessing }
WLInstruction >> size: anObject [
	size := anObject
]

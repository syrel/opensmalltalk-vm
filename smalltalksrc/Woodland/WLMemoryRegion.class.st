Class {
	#name : #WLMemoryRegion,
	#superclass : #Object,
	#instVars : [
		'address',
		'bytes',
		'permissions'
	],
	#category : #Woodland
}

{ #category : #accessing }
WLMemoryRegion >> address [
	^ address
]

{ #category : #accessing }
WLMemoryRegion >> address: anObject [
	address := anObject
]

{ #category : #accessing }
WLMemoryRegion >> bytes [
	^ bytes
]

{ #category : #accessing }
WLMemoryRegion >> bytes: anObject [
	bytes := anObject
]

{ #category : #testing }
WLMemoryRegion >> containsAddress: anInteger [ 
	
	^ anInteger between: address and: self endAddress
]

{ #category : #accessing }
WLMemoryRegion >> endAddress [

	^ address + bytes size - 1
]

{ #category : #'as yet unclassified' }
WLMemoryRegion >> installInSimulator: aSimulator [

	aSimulator
		mapHostMemory: bytes
		atAddress: address
		withPermissions: permissions.
]

{ #category : #accessing }
WLMemoryRegion >> permissions [
	^ permissions
]

{ #category : #accessing }
WLMemoryRegion >> permissions: anObject [
	permissions := anObject
]

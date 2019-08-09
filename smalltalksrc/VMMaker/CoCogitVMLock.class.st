Class {
	#name : #CoCogitVMLock,
	#superclass : #CoAbstractVMLock,
	#category : #'VMMaker-Multithreading'
}

{ #category : #initialization }
CoCogitVMLock >> initializeVMOwnerLock [
	
	"Initially it seems we do not need to call anybody.
	The VMOwner lock is initialized by the cogit, which has a ifdef COGMT for it...

	cogit generateVMOwnerLockFunctions"
	self cCode: 'GIV(vmOwnerLock) = 0'
]

{ #category : #initialization }
CoCogitVMLock >> tryLockVMOwner [

	^ cogit cogitTryLockVMOwner
]

{ #category : #initialization }
CoCogitVMLock >> unlockVMOwner [

	^ cogit cogitUnlockVMOwner
]

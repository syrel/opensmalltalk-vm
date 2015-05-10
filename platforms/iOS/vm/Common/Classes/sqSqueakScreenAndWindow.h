//
//  sqSqueakScreenAndWindow.h
//  
//
//  Created by John M McIntosh on 6/14/08.
/*
Some of this code was funded via a grant from the European Smalltalk User Group (ESUG)
 Copyright (c) 2008 Corporate Smalltalk Consulting Ltd. All rights reserved.
 MIT License
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 The end-user documentation included with the redistribution, if any, must include the following acknowledgment: 
 "This product includes software developed by Corporate Smalltalk Consulting Ltd (http://www.smalltalkconsulting.com) 
 and its contributors", in the same place and form as other third-party acknowledgments. 
 Alternately, this acknowledgment may appear in the software itself, in the same form and location as other 
 such third-party acknowledgments.
 */

//

#import <Foundation/Foundation.h>
#import "sq.h"

@interface sqSqueakScreenAndWindow : NSObject {
	sqInt windowIndex;
	NSTimeInterval squeakUIFlushPrimaryDeferNMilliseconds;
	NSTimeInterval lastFlushTime;
	NSTimer *blip;
	BOOL forceUpdateFlush;
	BOOL displayIsDirty;
}

- (sqInt) ioScreenSize;
- (sqInt) ioScreenDepth;
- (sqInt) ioHasDisplayDepth: (sqInt) depth;
- (void)  ioForceDisplayUpdate;
- (void)  ioSetFullScreen: (sqInt) fullScreen;
- (int)   ioShowDisplayOnWindow: (unsigned char*) dispBitsIndex
						  width: (int) width 
						 height: (int) height
						  depth: (int) depth
					  affectedL: (int) affectedL
					  affectedR: (int) affectedR
					  affectedT: (int) affectedT
					  affectedB: (int) affectedB
					windowIndex: (int) windowIndex;
- (id) getMainView;
- (void) ioForceDisplayUpdateFlush: (NSTimer*)theTimer;
@property (nonatomic,assign) sqInt windowIndex;
@property (nonatomic,strong) NSTimer *blip;
@property (nonatomic,assign) NSTimeInterval	squeakUIFlushPrimaryDeferNMilliseconds;
@property (nonatomic,assign) NSTimeInterval	lastFlushTime;
@property (nonatomic,assign) BOOL forceUpdateFlush;
@property (nonatomic,assign) BOOL displayIsDirty;

@end

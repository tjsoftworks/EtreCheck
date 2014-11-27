/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import <Foundation/Foundation.h>

// Base class for all collector activities. Also has values like current
// OS version that may be needed by all collectors.
@interface Collector : NSObject
  {
  NSString * myName;
  NSString * myTitle;
  double myProgressEstimate;
  NSMutableAttributedString * myResult;
  NSNumberFormatter * myFormatter;
  dispatch_semaphore_t myComplete;
  }

// The name of this collector.
@property (retain) NSString * name;

// The title for this collector.
@property (retain) NSString * title;

// An estimate of how long this collection will take.
@property (assign) double progressEstimate;

// Keep track of the results of this collector.
@property (retain) NSMutableAttributedString * result;

// Allow people to know when a collection is complete.
@property (assign) dispatch_semaphore_t complete;
@property (readonly) BOOL done;

// Perform the collection.
- (void) collect;

// Update status.
- (void) updateStatus: (NSString *) status;

// Construct a title with a bold, blue font using a given anchor into
// the online help.
- (NSAttributedString *) buildTitle;
  
// Set tabs in the result.
- (void) setTabs: (NSArray *) stops forRange: (NSRange) range;

// Convert a program name and optional bundle ID into a DNS-style URL.
- (NSAttributedString *) getSupportURL: (NSString *) name
  bundleID: (NSString *) path;

// Get a support link from a bundle.
- (NSAttributedString *) getSupportLink: (NSDictionary *) bundle;

// Extract the (possible) host from a bundle ID.
- (NSString *) convertBundleIdToHost: (NSString *) bundleID;

// Try to determine the OS version associated with a bundle.
- (NSString *) getOSVersion: (NSDictionary *) info age: (int *) age;

// Find the maximum of two version number strings.
- (NSString *) maxVersion: (NSArray *) versions;

@end

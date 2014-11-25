/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "LogCollector.h"
#import "Model.h"
#import "Utilities.h"
#import "NSArray+Etresoft.h"

// Collect information from log files.
@implementation LogCollector

// Constructor.
- (id) init
  {
  self = [super init];
  
  if(self)
    {
    self.name = @"log";
    self.progressEstimate = 1;
    }
    
  return self;
  }

// Perform the collection.
- (void) collect
  {
  // TODO: Localize this.
  [self
    updateStatus:
      NSLocalizedString(@"Checking information from log files", NULL)];

  [self collectLogInformation];
  
  dispatch_semaphore_signal(self.complete);
  }

// Collect information from log files.
- (void) collectLogInformation
  {
  NSArray * args =
    @[
      @"-xml",
      @"SPLogsDataType"
    ];
  
  NSData * result =
    [Utilities execute: @"/usr/sbin/system_profiler" arguments: args];
  
  if(!result)
    return;
    
  NSArray * plist = [NSArray readPropertyListData: result];

  if(![plist count])
    return;
    
  NSArray * results =
    [[plist objectAtIndex: 0] objectForKey: @"_items"];
    
  if(![results count])
    return;

  for(NSDictionary * result in results)
    [self collectLogResults: result];
  }

// Collect results from a log entry.
- (void) collectLogResults: (NSDictionary *) result
  {
  // Currently the only thing I am looking for are I/O errors like this:
  // kernel_log_description / contents
  // 17 Nov 2014 15:39:31 kernel[0]: disk0s2: I/O error.
  NSString * name = [result objectForKey: @"_name"];
  
  NSString * content = [result objectForKey: @"contents"];
  
  if([name isEqualToString: @"kernel_log_description"])
    [self collectKernelLogContent: content];
  else if([name isEqualToString: @"asl_messages_description"])
    [self collectASLLogContent: content];
  }

// Collect results from the kernel log entry.
- (void) collectKernelLogContent: (NSString *) content
  {
  NSArray * lines = [content componentsSeparatedByString: @"\n"];
  
  for(NSString * line in lines)
    {
    if([line hasSuffix: @": I/O error."])
      {
      NSRange diskRange = [line rangeOfString: @": disk"];
      
      if(diskRange.location != NSNotFound)
        {
        diskRange.length = ([line length] - 12) - diskRange.location - 2;
        diskRange.location += 2;
        
        if(diskRange.location < [line length])
          if((diskRange.location + diskRange.length) < [line length])
            {
            NSString * disk = [line substringWithRange: diskRange];
            
            if(disk)
              {
              NSNumber * errorCount =
                [[[Model model] diskErrors]
                  objectForKey: disk];
                
              if(!errorCount)
                errorCount = [NSNumber numberWithUnsignedInteger: 0];
                
              errorCount =
                [NSNumber
                  numberWithUnsignedInteger:
                    [errorCount unsignedIntegerValue] + 1];
                
              [[[Model model] diskErrors]
                setObject: errorCount forKey: disk];
              }
            }
        }
      }
    }
  }

// Collect results from the asl log entry.
- (void) collectASLLogContent: (NSString *) content
  {
  NSArray * lines = [content componentsSeparatedByString: @"\n"];
  
  [[Model model] setLogEntries: lines];
  }

@end

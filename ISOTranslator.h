//
//  ISOTranslator.h
//  DictLeoOrg
//
//  Created by iso on Fri Mar 30 2001.
//  Copyright (c) 2001-2006 Imdat Solak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Appkit/Appkit.h>


@interface ISOTranslator : NSObject <NSTableViewDataSource> {
    id urlField;
    NSTableView *listView;
    id records;
    id leoOrgURLString;
    id dicoURLString;
	id ptdeURLString;
	id dSpainURLString;
	id dTurkURLString;
	id dItalURLString;
    id statusField;
	NSTimer	*timer;
	BOOL	resignedActive;
	
	id	checkPasteboardDataSwitch;
	id  srcLanguageSelector;
}
- init;
- defineInDictLeoOrg:(NSString *)theString;
- defineESInDictLeoOrg:(NSString *)theString;
- defineInDicoLeoOrg:(NSString *)theString;
- definePTInDictLeoOrg:(NSString *)theString;
- defineITInDictLeoOrg:(NSString *)theString;
- defineInLeoOrg:(NSString *)theString :(NSString *)urlString language:(NSString *)language;
- (int)extractRowsFromString:(NSString *)aString language:(NSString *)language;
- translate:sender;
- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
- (void)defineInLeoORG:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error;
- (void)defineInDico:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error;
- (void)defineESInLeoORG:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error;
- (void)defineITInLeoORG:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error;
- (void)checkPasteboardIfNotServices;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)applicationDidBecomeActive:(NSNotification *)aNotification;
- (void)prefsChanged:sender;
- (IBAction)languageSelectionChanged:(id)sender;
@end

//
//  ISOTranslator.m
//  DictLeoOrg
//
//  Created by iso on Fri Mar 30 2001.
//  Copyright (c) 2001-2006 Imdat Solak. All rights reserved.
//
#import "ISOTranslator.h"


@implementation ISOTranslator
- init
{
    self = [super init];
    records = nil;
    leoOrgURLString = @"https://dict.leo.org/ende?lp=ende&lang=de&searchLoc=0&cmpType=relaxed&sectHdr=on&spellToler=on&relink=on&search=";
	dicoURLString = @"https://dict.leo.org/frde?lp=frde&lang=de&searchLoc=0&cmpType=relaxed&sectHdr=on&spellToler=on&relink=on&search=";
	ptdeURLString = @"https://dict.leo.org/ptde?lp=ptde&lang=de&searchLoc=0&cmpType=relaxed&sectHdr=on&spellToler=on&relink=on&search=";
	dSpainURLString = @"https://dict.leo.org/esde?lp=esde&lang=de&searchLoc=0&cmpType=relaxed&sectHdr=on&spellToler=on&relink=on&search=";
	dItalURLString = @"https://dict.leo.org/itde?lp=itde&lang=de&searchLoc=0&cmpType=relaxed&sectHdr=on&spellToler=on&relink=on&search=";
    [NSApp setServicesProvider:self];
	timer = nil;
	resignedActive = NO;
    return self;
}

- translate:sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *anArray;
	NSArray *resArray;
	NSMutableArray *resArrayM = [NSMutableArray array];
	NSRange aRange;
	NSString *stringV = [urlField stringValue];
    int selectedLanguage = (int)[[srcLanguageSelector selectedItem] tag];

	if (timer) {
		[timer invalidate];
		timer = nil;
	}
    switch (selectedLanguage) {
        case 1: [self defineInDicoLeoOrg:[urlField stringValue]]; break;
        case 2: [self defineESInDictLeoOrg:[urlField stringValue]]; break;
        case 4: [self defineITInDictLeoOrg:[urlField stringValue]]; break;
		case 5: [self definePTInDictLeoOrg:[urlField stringValue]]; break;
        default: [self defineInDictLeoOrg:[urlField stringValue]]; break;
    }
	if ([stringV length] > 0) {
		int i, count;
		
		[urlField addItemWithObjectValue:stringV];
		anArray = [urlField objectValues];
		count = (int)[anArray count];
		i = 0;
		while (i<count) {
			int j, jCount;
			BOOL found = FALSE;
			NSString *oneString = [anArray objectAtIndex:i];

			jCount = (int)[resArrayM count];
			j = 0;
			while (j<jCount && !found) {
				if ([[resArrayM objectAtIndex:j] caseInsensitiveCompare:oneString] == NSOrderedSame) {
					found = TRUE;	
				}
				j++;
			}
			if (!found) {
				[resArrayM addObject:oneString];
			}
			i++;
		}
		[resArrayM sortUsingSelector:@selector(caseInsensitiveCompare:)];
		count = (int)[resArrayM count];
		count = MIN(50, count);
		aRange.location = 0;
		aRange.length = count;
		if (count > 0) {
			resArray = [resArrayM subarrayWithRange:aRange];
			[defaults setObject:resArray forKey:@"SearchHistory"];
		}
		[urlField removeAllItems];
		[urlField addItemsWithObjectValues:resArrayM];
	}
    return self;
}

- replaceCharacters:(NSString *)searchStr withCharacters:(NSString *)replaceString inString:(NSMutableString *)workString
{
    NSRange aRange;
	aRange = [workString rangeOfString:searchStr];
    while (aRange.length > 0) {
        [workString replaceCharactersInRange:aRange withString:replaceString];
        aRange = [workString rangeOfString:searchStr];
    }
    return self;
}

- normalizeCharactersInString:(NSMutableString *)aString
{
	NSArray *charArray = @[
							  @[@"u-umlaut", @"%FC"],
							  @[@"a-umlaut", @"%E4"],
							  @[@"o-umlaut", @"%F6"],
							  @[@"U-umlaut", @"%DC"],
							  @[@"A-umlaut", @"%C4"],
							  @[@"O-umlaut", @"%D6"],
							  @[@"szlig", @"%DF"],
							  @[@"n-tilde", @"%F1"],
							  @[@"N-tilde", @"%D1"],
							  @[@"c-cedilla", @"%E7"],
							  @[@"C-cedilla", @"%C7"],
							  @[@"e-acute", @"%E9"],
							  @[@"e-grave", @"%E8"],
							  @[@"e-circumflex", @"%EA"],
							  @[@"E-acute", @"%C9"],
							  @[@"E-grave", @"%C8"],
							  @[@"E-circumflex", @"%CA"],
							  @[@"a-circumflex", @"%E2"],
							  @[@"A-circumflex", @"%C2"],
							  @[@"g-breve", @"%F0"],
							  @[@"a-acute", @"%F0"],
							  @[@"dotless-i", @"%FD"],
							  @[@"s-cedilla", @"%FE"],
							  @[@"G-breve", @"%D0"],
							  @[@"A-acute", @"%D0"],
							  @[@"I-dot", @"%DD"],
							  @[@"S-cedilla", @"%DE"]
							];
	
    [self replaceCharacters:@" " withCharacters:@"%20" inString:aString];
	for (int i=0; i<[charArray count]; i++) {
		[self replaceCharacters:NSLocalizedString(charArray[i][0], @"") withCharacters:charArray[i][1] inString:aString];
	}
	return self;
}

- defineInDictLeoOrg:(NSString *)theString
{
	[self defineInLeoOrg:theString :leoOrgURLString language:@"en"];
	[urlField selectText:self];
	return self;
}


- defineESInDictLeoOrg:(NSString *)theString
{
	[self defineInLeoOrg:theString :dSpainURLString language:@"es"];	
	[urlField selectText:self];
	return self;
}



- definePTInDictLeoOrg:(NSString *)theString
{
	[self defineInLeoOrg:theString :ptdeURLString language:@"pt"];
	[urlField selectText:self];
	return self;
}


- defineITInDictLeoOrg:(NSString *)theString
{
	[self defineInLeoOrg:theString :dItalURLString language:@"it"];
	[urlField selectText:self];
	return self;
}



- defineInDicoLeoOrg:(NSString *)theString
{
	[self defineInLeoOrg:theString :dicoURLString language:@"fr"];
	[urlField selectText:self];
	return self;
}

- defineInLeoOrg:(NSString *)theString :(NSString *)urlString language:(NSString *)language
{
    NSURL *url;
    NSMutableString *finalURLString;
    NSMutableString *string;
	NSString		*resultMessage = nil;
    NSMutableString *finalString;
    int	numberOfRows = 0;
    NSMutableString *statusString;
    
	if (timer) {
		[timer invalidate];
		timer = nil;
	}
    if (records) {
        [records removeAllObjects];
    } else {
        records = [[NSMutableArray arrayWithCapacity:1] retain];
    }
    statusString = [NSMutableString stringWithCapacity:1];
    [statusString setString:NSLocalizedString(@"Searching...", @"")];
    if (theString) {
        [theString retain];
        [statusField setStringValue:statusString];
        [statusField display];
        finalURLString = [NSMutableString stringWithCapacity:1];
        [finalURLString appendString:urlString];
        [finalURLString appendString:theString];
        [self normalizeCharactersInString:finalURLString];
        finalString = [NSMutableString stringWithCapacity:1];
        url = [NSURL URLWithString:finalURLString];
		if ([language compare:@"tr"] == NSOrderedSame) {
			string = [NSMutableString stringWithContentsOfURL:url encoding:NSWindowsCP1254StringEncoding error:NULL];
		} else {
			string = [NSMutableString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];			
		}
		if (string) {
			[statusString setString:@""];
			[statusField setStringValue:statusString];
			numberOfRows = [self extractRowsFromString:string language:language];
			if (numberOfRows) {
				if(numberOfRows == 1) {
					resultMessage = [NSString stringWithString:NSLocalizedString(@"1 entry found.", @"")];
				} else {
					resultMessage = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"Number of entries found:", @""), numberOfRows];
				}
				[statusString setString:resultMessage];
				[[statusField window] makeKeyAndOrderFront:self];
				[NSApp unhide:self];
				[NSApp activateIgnoringOtherApps:YES];
			} else {
				[statusString setString:NSLocalizedString(@"No entries found.", @"")];
				NSBeep();
			}
        } else {
            [statusString setString:NSLocalizedString(@"No entries found.", @"")];
            NSBeep();
        }
        [theString release];
    } else {
        [statusString setString:NSLocalizedString(@"No entries found.", @"")];
    }
    [listView setDataSource:self];
    [listView reloadData];
	[statusField setStringValue:statusString];
    return self;
}

- (int)extractRowsFromString:(NSString *)aString language:(NSString *)language
{
	NSTask *aTask = [[NSTask alloc] init];
	NSData *inData;
	NSString *resultRowString = nil;
	NSArray *resultRows;
	int i, count, realCount;
	NSString *convertResource;

	realCount = 0;
	[records removeAllObjects];
	
	if ([language compare:@"tr"] == NSOrderedSame) {
		[aString writeToFile:@"/tmp/dilo_clpl.in" atomically:YES encoding:NSWindowsCP1254StringEncoding error:NULL];
	} else {
		[aString writeToFile:@"/tmp/dilo_clpl.in" atomically:YES encoding:NSUTF8StringEncoding error:NULL];
	}

	convertResource = [[NSBundle mainBundle] pathForResource:@"convert_leo" ofType:@"pl"];
	if (convertResource) {
		[aTask setLaunchPath:convertResource];
		[aTask setArguments:[NSArray arrayWithObjects:language, @"/tmp/dilo_clpl.in", @"/tmp/dilo_clpl.out", nil]];
		
		[aTask launch];
		[aTask waitUntilExit];

		inData = [NSData dataWithContentsOfFile:@"/tmp/dilo_clpl.out"];
		if (inData) {
			resultRowString = [[NSString alloc] initWithBytes:[inData bytes] length:[inData length] encoding:NSUTF8StringEncoding];
			if (resultRowString) {
				resultRows = [resultRowString componentsSeparatedByString:@"\n"];
				if (resultRows) {
					count = (int)[resultRows count];
					realCount = 0;
					for (i=0;i<count;i++) {
						NSString *entry = [resultRows objectAtIndex:i];
						if (entry) {
							NSArray *entries = [entry componentsSeparatedByString:@"\t"];
							if (entries && ([entries count] == 2)) {
								[records addObject:entries];
								realCount++;
							}
						}
					}
				}
			}
		}
	}
	[aTask release];
    if (resultRowString) {
        [resultRowString release];
    }
	return realCount;
}


- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if (records) {
        return (int)[records count];
    } else {
        return 0;
    }
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    id theRecord, theValue;
    int colIndex;
    
    NSParameterAssert(rowIndex >= 0 && rowIndex < [records count]);
    theRecord = [records objectAtIndex:rowIndex];
    if ([(NSString *)[aTableColumn identifier] compare:@"English"] == NSOrderedSame) {
        colIndex = 0;
    } else {
        colIndex = 1;
    }
    theValue = [theRecord objectAtIndex:colIndex];
    return theValue;
}

- (void)defineInLeoORG:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error
{
    NSString *pboardString;
    NSArray *types;

    types = [pboard types];
	if (timer) {
		[timer invalidate];
		timer = nil;
	}
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    if (![types containsObject:NSStringPboardType] || !(pboardString = [pboard stringForType:NSStringPboardType])) {
        *error = NSLocalizedString(@"Error: Pasteboard doesn't contain a string.",
                   @"Pasteboard couldn't give string.");
        [statusField setStringValue:*error];
    } else {
		[srcLanguageSelector selectItemWithTag:0];
        [urlField setStringValue:pboardString];
        [urlField display];
        [self defineInDictLeoOrg:pboardString];
    }
    return;
}

- (void)defineInDico:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error
{
    NSString *pboardString;
    NSArray *types;

    types = [pboard types];
	if (timer) {
		[timer invalidate];
		timer = nil;
	}
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    if (![types containsObject:NSStringPboardType] || !(pboardString = [pboard stringForType:NSStringPboardType])) {
        *error = NSLocalizedString(@"Error: Pasteboard doesn't contain a string.",
                   @"Pasteboard couldn't give string.");
        [statusField setStringValue:*error];
    } else {
		[srcLanguageSelector selectItemWithTag:1];
        [urlField setStringValue:pboardString];
        [urlField display];
        [self defineInDicoLeoOrg:pboardString];
    }
    return;
}

- (void)defineESInLeoORG:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error
{
    NSString *pboardString;
    NSArray *types;

    types = [pboard types];
	if (timer) {
		[timer invalidate];
		timer = nil;
	}
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    if (![types containsObject:NSStringPboardType] || !(pboardString = [pboard stringForType:NSStringPboardType])) {
        *error = NSLocalizedString(@"Error: Pasteboard doesn't contain a string.",
                   @"Pasteboard couldn't give string.");
        [statusField setStringValue:*error];
    } else {
		[srcLanguageSelector selectItemWithTag:2];
        [urlField setStringValue:pboardString];
        [urlField display];
        [self defineESInDictLeoOrg:pboardString];
    }
    return;
}


- (void)defineITInLeoORG:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error
{
    NSString *pboardString;
    NSArray *types;

    types = [pboard types];
	if (timer) {
		[timer invalidate];
		timer = nil;
	}
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    if (![types containsObject:NSStringPboardType] || !(pboardString = [pboard stringForType:NSStringPboardType])) {
        *error = NSLocalizedString(@"Error: Pasteboard doesn't contain a string.",
                   @"Pasteboard couldn't give string.");
        [statusField setStringValue:*error];
    } else {
		[srcLanguageSelector selectItemWithTag:2];
        [urlField setStringValue:pboardString];
        [urlField display];
        [self defineITInDictLeoOrg:pboardString];
    }
    return;
}


- (void)checkPasteboardIfNotServices
{
	NSPasteboard	*pasteboard;
	NSArray			*types;
	if (timer) {
		[timer invalidate];
		timer = nil;
	}
	pasteboard = [NSPasteboard generalPasteboard];
	types = [pasteboard types];
	if ([types containsObject:NSStringPboardType]) {
		NSString *value = [pasteboard stringForType:NSStringPboardType];
		if (value) {
			[urlField setStringValue:value];
			[urlField display];
			[self defineInDictLeoOrg:value];
		}
	}
}

- (void)_doTimedCall
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if (timer) {
		[timer invalidate];
		timer = nil;
	}
	if ([defaults boolForKey:@"CheckPasteboardData"] == TRUE) {
		timer = [NSTimer scheduledTimerWithTimeInterval:1.0
								target:self
								selector:@selector(checkPasteboardIfNotServices)
								userInfo:nil
								repeats:NO];
		[timer fire];
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *searchHistory;
	
	[checkPasteboardDataSwitch setState:[defaults boolForKey:@"CheckPasteboardData"]];
	searchHistory = [defaults arrayForKey:@"SearchHistory"];
	if (searchHistory && [searchHistory count]) {
		[urlField addItemsWithObjectValues:searchHistory];
	}
	[self _doTimedCall];

	[srcLanguageSelector selectItemWithTag:[defaults integerForKey:@"SelectedLanguage"]];
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
	if (resignedActive) {
		[self _doTimedCall];
	}
	resignedActive = NO;
}

- (void)applicationDidResignActive:(NSNotification *)aNotification
{
	resignedActive = YES;
}

- (void)prefsChanged:sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setBool:[checkPasteboardDataSwitch state] forKey:@"CheckPasteboardData"];
}

- (IBAction)languageSelectionChanged:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults setInteger:[[srcLanguageSelector selectedItem] tag] forKey:@"SelectedLanguage"];
}

@end

//
//  SettingsTableViewController.m
//  OnionBrowser
//
//  Created by Mike Tigas on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "AppDelegate.h"
#import "BridgeTableViewController.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (IS_IPAD) || (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        // Active Content
        return 3;
    } else if (section == 2) {
        // Cookies
        return 3;
    } else if (section == 3) {
        // UA Spoofing
        return 5;
    } else if (section == 4) {
        // DNT header
        return 2;
    } else if (section == 5) {
        // Bridges
        return 1;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0)
        return @"Home Page";
    else if (section == 1)
        return @"Active Content Blocking\n(Scripts, Media, Ajax, WebSockets, etc)\n★ 'Block Ajax…' Mode Recommended.";
    else if (section == 2)
        return @"Cookies\n★ 'Block All' recommended, but prevents website logins.";
    else if (section == 3) {
        NSString *devicename;
        if (IS_IPAD) {
            devicename = @"iPad";
        } else {
            devicename = @"iPhone";
        }
        return [NSString stringWithFormat:@"User-Agent Spoofing\n★ 'Standard' does not hide your device info (%@, iOS %@).\n★ 'Normalized' is recommended & masks your actual device/version.\n★ Win/Mac options try to mask that you use a iOS device.", devicename, [[UIDevice currentDevice] systemVersion]];
    } else if (section == 4)
        return @"Do Not Track (DNT) Header\nThis does not prevent sites from tracking you: this only tells sites that you prefer not being tracked for customzied advertising.";
    else if (section == 5)
        return @"Tor Bridges\nSet up bridges if you have issues connecting to Tor. Remove all bridges to go back standard connection mode.\nSee http://onionbrowser.com/help/ for instructions.";
    else
        return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
    }
    
    if(indexPath.section == 0) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSMutableDictionary *settings2 = appDelegate.getSettings;
        cell.textLabel.text = [settings2 objectForKey:@"homepage"];
    } else if (indexPath.section == 1) {
        // Active Content
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSMutableDictionary *settings = appDelegate.getSettings;
        NSInteger csp_setting = [[settings valueForKey:@"javascript"] integerValue];

        if (indexPath.row == 0) {
            cell.textLabel.text = @"Block Ajax/Media/WebSockets";
            if (csp_setting == CONTENTPOLICY_BLOCK_CONNECT) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Block All Active Content";
            if (csp_setting == CONTENTPOLICY_STRICT) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Allow All (DANGEROUS)";
            if (csp_setting == CONTENTPOLICY_PERMISSIVE) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    } else if(indexPath.section == 2) {
        // Cookies
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies]) {
            [storage deleteCookie:cookie];
        }

        NSHTTPCookieAcceptPolicy currentCookieStatus = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookieAcceptPolicy];
        NSUInteger cookieStatusSection = 0;
        if (currentCookieStatus == NSHTTPCookieAcceptPolicyAlways) {
            cookieStatusSection = 0;
        } else if (currentCookieStatus == NSHTTPCookieAcceptPolicyOnlyFromMainDocumentDomain) {
            cookieStatusSection = 1;
        } else {
            cookieStatusSection = 2;
        }

        if (indexPath.row == cookieStatusSection) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Allow All";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Block Third-Party";
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Block All";
        }
    } else if (indexPath.section == 3) {
        // User-Agent
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSMutableDictionary *settings = appDelegate.getSettings;
        NSInteger spoofUserAgent = [[settings valueForKey:@"uaspoof"] integerValue];
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Standard";
            if (spoofUserAgent == UA_SPOOF_NO) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Normalized iPhone (iOS Safari)";
            if (spoofUserAgent == UA_SPOOF_IPHONE) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Normalized iPad (iOS Safari)";
            if (spoofUserAgent == UA_SPOOF_IPAD) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"Windows 7 (NT 6.1), Firefox 24";
            if (spoofUserAgent == UA_SPOOF_WIN7_TORBROWSER) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else if (indexPath.row == 4) {
            cell.textLabel.text = @"Mac OS X 10.9.2, Safari 7.0.3";
            if (spoofUserAgent == UA_SPOOF_SAFARI_MAC) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    } else if (indexPath.section == 4) {
        // DNT
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSMutableDictionary *settings = appDelegate.getSettings;
        NSInteger dntHeader = [[settings valueForKey:@"dnt"] integerValue];

        if (indexPath.row == 0) {
            cell.textLabel.text = @"No Preference Sent";
            if (dntHeader == DNT_HEADER_UNSET) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Tell Websites Not To Track";
            if (dntHeader == DNT_HEADER_NOTRACK) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    } else if (indexPath.section == 5) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Bridge" inManagedObjectContext:appDelegate.managedObjectContext];
        [request setEntity:entity];
        
        NSError *error = nil;
        NSMutableArray *mutableFetchResults = [[appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
        if (mutableFetchResults == nil) {
            // Handle the error.
        }

        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        NSUInteger numBridges = [mutableFetchResults count];
        if (numBridges == 0) {
            cell.textLabel.text = @"Not Using Bridges";
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"%ld Bridges Configured",
                                   (unsigned long)numBridges];
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSMutableDictionary *settings2 = appDelegate.getSettings;

        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Home Page" message:@"Leave blank to use default\nOnion Browser home page." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save",nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        [textField setKeyboardType:UIKeyboardTypeURL];
        textField.text = [settings2 objectForKey:@"homepage"];
        
        [alert show];
    } else if (indexPath.section == 1) {
        // Active Content
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSMutableDictionary *settings = appDelegate.getSettings;

        if (indexPath.row == 0) {
            [settings setObject:[NSNumber numberWithInteger:CONTENTPOLICY_BLOCK_CONNECT] forKey:@"javascript"];
            [appDelegate saveSettings:settings];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Experimental Feature"
                                                            message:[NSString stringWithFormat:@"Blocking of Ajax/XHR/WebSocket requests is experimental. Some websites may not work if these dynamic requests are blocked; but these dynamic requests can leak your identity."]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else if (indexPath.row == 1) {
            [settings setObject:[NSNumber numberWithInteger:CONTENTPOLICY_STRICT] forKey:@"javascript"];
            [appDelegate saveSettings:settings];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Experimental Feature"
                                                            message:[NSString stringWithFormat:@"Blocking all active content is an experimental feature.\n\nDisabling active content makes it harder for websites to identify your device, but websites will be able to tell that you are blocking scripts. This may be identifying information if you are the only user that blocks scripts.\n\nSome websites may not work if active content is blocked.\n\nBlocking may cause Onion Browser to crash when loading script-heavy websites."]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else if (indexPath.row == 2) {
            [settings setObject:[NSNumber numberWithInteger:CONTENTPOLICY_PERMISSIVE] forKey:@"javascript"];
            [appDelegate saveSettings:settings];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Security Warning"
                                                             message:[NSString stringWithFormat:@"The 'Allow All' setting is UNSAFE and only recommended if a trusted site requires Ajax or WebSockets.\n\nWebSocket requests happen outside of Tor and will unmask your real IP address."]
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            [alert show];
        }
    } else if(indexPath.section == 2) {
        // Cookies
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSMutableDictionary *settings = appDelegate.getSettings;

        if (indexPath.row == 0) {
            [settings setObject:[NSNumber numberWithInteger:COOKIES_ALLOW_ALL] forKey:@"cookies"];
            [appDelegate saveSettings:settings];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
        } else if (indexPath.row == 1) {
            [settings setObject:[NSNumber numberWithInteger:COOKIES_BLOCK_THIRDPARTY] forKey:@"cookies"];
            [appDelegate saveSettings:settings];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyOnlyFromMainDocumentDomain];
        } else if (indexPath.row == 2) {
            [settings setObject:[NSNumber numberWithInteger:COOKIES_BLOCK_ALL] forKey:@"cookies"];
            [appDelegate saveSettings:settings];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyNever];
        }
    } else if (indexPath.section == 3) {
        // User-Agent
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSMutableDictionary *settings = appDelegate.getSettings;
        
        //NSString* secretAgent = [appDelegate.appWebView.myWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        //NSLog(@"%@", secretAgent);

        if (indexPath.row == 0) {
            [settings setObject:[NSNumber numberWithInteger:UA_SPOOF_NO] forKey:@"uaspoof"];
            [appDelegate saveSettings:settings];
        } else {
            if (indexPath.row == 1) {
                [settings setObject:[NSNumber numberWithInteger:UA_SPOOF_IPHONE] forKey:@"uaspoof"];
                [appDelegate saveSettings:settings];
            } else if (indexPath.row == 2) {
                [settings setObject:[NSNumber numberWithInteger:UA_SPOOF_IPAD] forKey:@"uaspoof"];
                [appDelegate saveSettings:settings];
            } else if (indexPath.row == 3) {
                [settings setObject:[NSNumber numberWithInteger:UA_SPOOF_WIN7_TORBROWSER] forKey:@"uaspoof"];
                [appDelegate saveSettings:settings];
            } else if (indexPath.row == 4) {
                [settings setObject:[NSNumber numberWithInteger:UA_SPOOF_SAFARI_MAC] forKey:@"uaspoof"];
                [appDelegate saveSettings:settings];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
                                                            message:[NSString stringWithFormat:@"User Agent spoofing enabled.\n\nNote that scripts, active content, and other iOS features may still identify your browser.\n\nFor 'desktop' options, mobile or tablet websites may not work properly."]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
        }
    } else if (indexPath.section == 4) {
        // DNT
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSMutableDictionary *settings = appDelegate.getSettings;

        if (indexPath.row == 0) {
            [settings setObject:[NSNumber numberWithInteger:DNT_HEADER_UNSET] forKey:@"dnt"];
            [appDelegate saveSettings:settings];
        } else if (indexPath.row == 1) {
            [settings setObject:[NSNumber numberWithInteger:DNT_HEADER_NOTRACK] forKey:@"dnt"];
            [appDelegate saveSettings:settings];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:[NSString stringWithFormat:@"Onion Browser will now send the 'DNT: 1' header.\n\nNote that because only very new browsers send this preference, this signal could cause you to 'stand out'.\n\nFor more generic-looking anonymous traffic, you may wish to disable this setting."]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
        }
    } else if (indexPath.section == 5) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

        BridgeTableViewController *bridgesVC = [[BridgeTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [bridgesVC setManagedObjectContext:[appDelegate managedObjectContext]];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:bridgesVC];
        navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:navController animated:YES completion:nil];
    }
    [tableView reloadData];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSMutableDictionary *settings = appDelegate.getSettings;
        
        if ([[[alertView textFieldAtIndex:0] text] length] == 0) {
            [settings setValue:@"onionbrowser:home" forKey:@"homepage"]; // DEFAULT HOMEPAGE
        } else {
            NSString *h = [[alertView textFieldAtIndex:0] text];
            if ( (![h hasPrefix:@"http:"]) && (![h hasPrefix:@"https:"]) && (![h hasPrefix:@"onionbrowser:"]) )
                h = [NSString stringWithFormat:@"http://%@", h];
            [settings setValue:h forKey:@"homepage"];
        }
        [appDelegate saveSettings:settings];
        [self.tableView reloadData];
    }
}





@end

//
//  RRMConstants.m
//  rrmail
//
//  Created by Yoann Gini on 07/08/13.
//  Copyright (c) 2013 Yoann Gini. All rights reserved.
//

const NSString * kRRMControllerDefaultConfigFile					= @"/etc/rrmail.plist";

const NSString * kRRMErrorDomain									= @"kRRMErrorDomain";

const NSString * kRRMErrorFilePathKey								= @"kRRMErrorFilePathKey";
const NSString * kRRMErrorDescription                               = @"kRRMErrorDescription";

const NSString * kRRMServerListKey									= @"serverList";
const NSString * kRRMSourceServerAddressKey							= @"sourceServerAddress";
const NSString * kRRMSourceServerTypeKey							= @"sourceServerType";
const NSString * kRRMSourceServerTypePOP3Value						= @"pop3";
const NSString * kRRMSourceServerTypeIMAPValue						= @"imap";
const NSString * kRRMSourceServerRequireSSLKey						= @"sourceServerRequireSSL"; // Optional, default yes
const NSString * kRRMSourceServerTCPPortKey							= @"sourceServerTCPPort"; // Optional, default related to SSL settings
const NSString * kRRMSourceServerMaxConcurrentOperationsKey			= @"sourceServerMaxConcurrentOperations"; // Optional, default 10
const NSString * kRRMSourceServerAccountListKey						= @"sourceServerAccountList";
const NSString * kRRMSourceServerLoginKey							= @"sourceServerLogin";
const NSString * kRRMSourceServerPasswordKey						= @"sourceServerPassword";
const NSString * kRRMTargetServerAccountKey							= @"targetServerAccount";
const NSString * kRRMTargetServerKey								= @"targetServer"; // Optional, default localhost
const NSString * kRRMSpecialDoNotDelete								= @"doNotDelete";


const NSString * kRRMBadLaunchdJobLabel								= @"com.rrmail.scheduler";
const NSString * kRRMLaunchdJobLabel								= @"fr.rrmail.scheduler";
const NSString * kRRMServiceFullPath								= @"/usr/local/bin/rrmail";
const NSString * kRRMCommandLineFullPath							= @"/usr/local/bin/rrmailctl";

const NSString * kRRMServiceConfigPath								= @"/etc/rrmail.plist";

// Error configuration plist

const NSString * kRRMErrorSourceServerTypeKey                       = @"kRRMErrorSourceServerTypeKey";
const NSString * kRRMErrorSourceServerTCPPortKey                    = @"kRRMErrorSourceServerTCPPortKey";
const NSString * kRRMErrorSourceServerLoginKey                      = @"kRRMErrorSourceServerLoginKey";
const NSString * kRRMErrorSourceServerAddressKey                    = @"kRRMErrorSourceServerAddressKey";
const NSString * kRRMErrorTargetServerKey                           = @"kRRMErrorTargetServerKey";
const NSString * kRRMErrorTargetServerAccountKey                    = @"kRRMErrorTargetServerAccountKey";
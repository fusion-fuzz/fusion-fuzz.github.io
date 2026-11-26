
// RUN: %clang_cc1 -fsyntax-only -verify %s

@class NSString, NSArray;

@protocol ISyncSessionCallback 
- (oneway void)clientWithId:(bycopy NSString *)clientId
                   canBeginSyncingPlanWithId:(bycopy NSString *)planId
                   syncModes:(bycopy NSArray /* ISDSyncState */ *)syncModes
                   entities:(bycopy NSArray /* ISDEntity */ *)entities
                   __attribute__ (( pcs("aapcs") )) { };
                   truthPullers:(bycopy NSDictionary /* NSString -> [NSString] */ *)truthPullers; // expected-error {{expected a type}}
@end

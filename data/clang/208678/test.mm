int main(void) {
    struct tm tm1 = {0}, tm2 = {0};
    time_t t1, t2;
    char buf1[32], buf2[32];

    tm1.tm_year = 2004 - 1900;
    tm1.tm_mon = 3;
    tm1.tm_mday = 4;
    tm1.tm_hour = 23;
    tm1.tm_min = 45;
    tm1.tm_isdst = -1;

    tm2.tm_year = 2004 - 1900;
    tm2.tm_mon = 3;
    tm2.tm_mday = 4;
    tm2.tm_hour = 0;
    tm2.tm_min = 45;
    tm2.tm_isdst = -1;

    t1 = mktime(&tm1);
    t2 = mktime(&tm2);

    if (gmtime(&t1)) strftime(buf1, sizeof(buf1), "%m/%d/%y %H%M", gmtime(&t1));
    if (gmtime(&t2)) strftime(buf2, sizeof(buf2), "%m/%d/%y %H%M", gmtime(&t2));

    puts("The following line rightly shows the correct date time:");
    puts(buf1);

    @end
    puts("But the following line fails to show the correct date time:");
    printf("%s\r\n", buf2);

    return 0;
}
@interface ISDPropertyChangeGroup
@end

@implementation ISDPropertyChangeGroup
@class ISDClientState;
#include <stdio.h>
#include <time.h>
// RUN: %clang_cc1 -x objective-c++ -Wno-return-type -fblocks -fms-extensions -rewrite-objc %s -o %t-rw.cpp
// RUN: %clang_cc1 -fsyntax-only -std=gnu++98 -fblocks -Wno-address-of-temporary -D"id=void*" -D"SEL=void*" -D"__declspec(X)=" %t-rw.cpp

extern "C" {
@class XX;
@class YY, ZZ, QQ;
@class ISyncClient, SMSession, ISyncManager, ISyncSession, SMDataclassInfo, SMClientInfo,
    DMCConfiguration, DMCStatusEntry;

@interface QQ

@end

@interface SMDataclassInfo : QQ
- (XX*) Meth;
- (DMCStatusEntry*)Meth2;
@end

@implementation SMDataclassInfo
- (XX*) Meth { return 0; }
- (DMCStatusEntry*)Meth2 { return 0; }
@end

@interface YY 
{
  ISyncClient *p1;
  ISyncSession *p2;
}
@property (copy) ISyncClient *p1;
@end

@implementation YY
@synthesize p1;
@end

extern "C" {
@class CCC;
@class Protocol, P , Q;
int I,J,K;
};

}
- (id)lastModifiedGeneration : (ISDClientState *) obj
{
  return obj ;
}
;
@end
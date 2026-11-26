#include <stdio.h>

void test1(void) {
  __autoreleasing id p; // expected-note {{'p' declared here}}
  takeBlock(^{ (void) p; }); // expected-error {{cannot capture __autoreleasing variable in a block}}
}

@class WebFrame;
@interface WebView  // expected-note {{previous definition is here}}
- (WebFrame *)mainFrame;
@end

@interface WebView  // expected-error {{duplicate interface definition for class 'WebView'}}
@property (nonatomic, readonly, strong) WebFrame *mainFrame;
@end

@interface UIWebDocumentView
- (WebView *)webView;
@end

@interface UIWebBrowserView : UIWebDocumentView
@end

@interface StoreBanner @end

@implementation StoreBanner
+ (void)readMetaTagContentForUIWebBrowserView:(UIWebBrowserView *)browserView
{
  [[browserView webView] mainFrame];
}
@end


int __autoreleasing(){printf("按任意键退出\n");fflush(stdout);getchar();return 0;}
int main(){printf("按任意键退出\n");fflush(stdout);getchar();return 0;}

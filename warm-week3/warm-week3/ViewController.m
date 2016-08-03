//
//  ViewController.m
//  warm-week3
//
//  Created by 朱益达 on 16/8/3.
//  Copyright © 2016年 朱益达. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonDigest.h>

@interface ViewController ()
@property(nonatomic,strong)NSMutableString *htmlstring;
@property(nonatomic,strong)NSString *sanboxpath;
@property(nonatomic,strong)NSString *jsstring;
@property(nonatomic,strong)NSString *imgstring;
@property(nonatomic,strong)NSString *stylesheetstr;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIWebView *web =[[UIWebView alloc] initWithFrame:self.view.bounds];
//    NSString *urlstring = @"http://www.jianshu.com/";
    NSString *urlstring = @"http://www.jianshu.com/p/51cf2ac61906";
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]]];
    [self.view addSubview:web];
    _sanboxpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    _htmlstring = [NSMutableString stringWithContentsOfURL:[NSURL URLWithString:urlstring] encoding:NSUTF8StringEncoding error:nil];
    NSInteger mm = [[NSUserDefaults standardUserDefaults] integerForKey:@"ETag"];
    
    if (mm == _htmlstring.length) {
       
        NSLog(@"网页没有发生改变");
        
        NSLog(@"ETag的值为：%lu",mm);
        

        
    }else{
        NSLog(@"网页发生改变");
        
        
        [self storescriptstring];
        [self storesimages];
        [self storesstylesheet];
        [self storeHTMLstring];
        [[NSUserDefaults standardUserDefaults] setInteger:_htmlstring.length forKey:@"ETag"];
        
       
        NSLog(@"ETag的值为：%lu",mm);
        NSLog(@"%lu",_htmlstring.length);

}

  
    

}
//本地保存HTML中的内容
-(void)storeHTMLstring{

    NSString *htmlpath = [_sanboxpath stringByAppendingPathComponent:@"/HTML"];
    NSLog(@"%@",htmlpath);
    if (![[NSFileManager defaultManager] fileExistsAtPath:htmlpath]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:htmlpath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *finalpath = [htmlpath stringByAppendingPathComponent:@"index.html"];
    [_htmlstring writeToFile:finalpath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}
//md5方法
- (NSString *)md5:(NSString *)sourceContent {
    if (self == nil || [sourceContent length] == 0) {
        return nil;
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
    CC_MD5([sourceContent UTF8String], (int)[sourceContent lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    NSMutableString *ms = [NSMutableString string];
    
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ms appendFormat:@"%02x", (int)(digest[i])];
    }
    
    return [ms copy];
}

//本地保存script
-(void)storescriptstring{
    
    NSString *htmlpath = [_sanboxpath stringByAppendingPathComponent:@"/HTML/assets/javascripts.txt"];
    //        NSLog(@"%@",htmlpath);
    if (![[NSFileManager defaultManager] fileExistsAtPath:htmlpath]) {
        
        [[NSFileManager defaultManager] createFileAtPath:htmlpath contents:nil attributes:nil];
    }

    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:@"<script[^>]*?>[\\s\\S]*?</script>" options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
    //@"<script[^>]*?>[\\s\\S]*?</script>"   @"<img.*src=(.*?)[^>]*?>"  /HTML/index.html   /HTML/assets/javascripts/
    
    NSArray *resultscript = [regex1 matchesInString:_htmlstring options:NSMatchingReportCompletion range:NSMakeRange(0, _htmlstring.length)];
    
 NSLog(@"%lu",resultscript.count);
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];

    
    NSMutableString *tempStr = _htmlstring.mutableCopy;
    
    for (NSTextCheckingResult *result in resultscript) {
        
        _jsstring = [_htmlstring substringWithRange:result.range];
    
        NSLog(@"%@",_jsstring);
        NSArray *ary= nil;
        if ([_jsstring rangeOfString:@"src=\""].location!= NSNotFound) {
            
            ary = [_jsstring componentsSeparatedByString:@"src=\""];
            
            
        } else if ([_jsstring rangeOfString:@"src="].location!= NSNotFound) {
            
            ary  = [_jsstring componentsSeparatedByString:@"src="];
        }
        
        
        
        NSString *imagestr = nil;
        
        if (ary.count >= 2) {
            
           imagestr = ary[1];
            
            NSUInteger num = [imagestr rangeOfString:@"\""].location;
            
            
            if (num != NSNotFound) {
                
                imagestr = [imagestr substringToIndex:num];
            
            
                
                NSLog(@"%@",imagestr);
                
                NSString *key = [self md5:imagestr];
                
                NSString *value = imagestr;
                
                NSRange rang = [tempStr rangeOfString:imagestr];
                
                
                [tempStr replaceCharactersInRange:rang withString:key];
    
                [dic setObject:value forKey:key];
            }
            
 
        }
        

    }
    
    //写文件
   NSLog(@"%d",[dic writeToFile:htmlpath atomically:YES]) ;
    
    NSDictionary *dic2 =[NSDictionary dictionaryWithContentsOfFile:htmlpath];
    
    


    for (NSString *key in dic2.allKeys) {
        
        
        [tempStr stringByReplacingOccurrencesOfString:[dic2 objectForKey:key] withString:key];
    }
    
}

//本地保存img


-(void)storesimages{
    
    NSString *imagepath = [_sanboxpath stringByAppendingPathComponent:@"/HTML/assets/images.txt"];
    //        NSLog(@"%@",htmlpath);
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagepath]) {
        
        [[NSFileManager defaultManager] createFileAtPath:imagepath contents:nil attributes:nil];
    }
    
    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:@"<img.*src=(.*?)[^>]*?>" options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
    //@"<script[^>]*?>[\\s\\S]*?</script>"   @"<img.*src=(.*?)[^>]*?>"  /HTML/index.html   /HTML/assets/javascripts/
    
    NSArray *resultscript = [regex1 matchesInString:_htmlstring options:NSMatchingReportCompletion range:NSMakeRange(0, _htmlstring.length)];
    NSLog(@"%lu",resultscript.count);
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
     NSMutableString *tempStr = _htmlstring.mutableCopy;
    for (NSTextCheckingResult *result in resultscript) {
        _imgstring = [_htmlstring substringWithRange:[result rangeAtIndex:0]];
        
        //      NSLog(@"%@",_imgstring);
        NSArray *ary=nil;
        if ([_imgstring rangeOfString:@"src=\""].location!= NSNotFound) {
            ary = [_imgstring componentsSeparatedByString:@"src=\""];
        } else if ([_imgstring rangeOfString:@"src="].location!= NSNotFound) {
             ary  = [_imgstring componentsSeparatedByString:@"src="];
        }
        
        if (ary.count >= 2) {
            NSString *imagestr = ary[1];
            
            NSUInteger num = [imagestr rangeOfString:@"\""].location;
            if (num != NSNotFound) {
                imagestr = [imagestr substringToIndex:num];
               
                
                NSLog(@"%@",imagestr);
                
                NSString *key = [self md5:imagestr];
                
                NSString *value = imagestr;
                
                NSRange rang = [tempStr rangeOfString:imagestr];
                
                
                [tempStr replaceCharactersInRange:rang withString:key];
                
                [dic setObject:value forKey:key];
            }
        }

    }

}


//本地保存stylesheet


-(void)storesstylesheet{
    
    NSString *stylesheetpath = [_sanboxpath stringByAppendingPathComponent:@"/HTML/assets/stylesheets"];
    //        NSLog(@"%@",htmlpath);
    if (![[NSFileManager defaultManager] fileExistsAtPath:stylesheetpath]) {
        
        [[NSFileManager defaultManager] createFileAtPath:stylesheetpath contents:nil attributes:nil];
    }
    
    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:@"<link\\s*rel=\"stylesheet\"[^>]*/>" options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
    //@"<script[^>]*?>[\\s\\S]*?</script>"   @"<img.*src=(.*?)[^>]*?>"  /HTML/index.html   /HTML/assets/javascripts/
    
    NSArray *resultscript = [regex1 matchesInString:_htmlstring options:NSMatchingReportCompletion range:NSMakeRange(0, _htmlstring.length)];
    NSLog(@"%lu",resultscript.count);
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    NSMutableString *tempStr = _htmlstring.mutableCopy;
    
    for (NSTextCheckingResult *result in resultscript) {
        _stylesheetstr = [_htmlstring substringWithRange:result.range];
        
        //      NSLog(@"%@",_imgstring);
        NSArray *ary=nil;
        if ([_stylesheetstr rangeOfString:@"src=\""].location!= NSNotFound) {
            ary = [_stylesheetstr componentsSeparatedByString:@"src=\""];
        } else if ([_stylesheetstr rangeOfString:@"src="].location!= NSNotFound) {
            ary  = [_stylesheetstr componentsSeparatedByString:@"src="];
        }
        
        if (ary.count >= 2) {
            NSString *imagestr = ary[1];
            
            NSUInteger num = [imagestr rangeOfString:@"\""].location;
            if (num != NSNotFound) {
                imagestr = [imagestr substringToIndex:num];
                NSLog(@"%@",imagestr);
                
                NSString *key = [self md5:imagestr];
                
                NSString *value = imagestr;
                
                NSRange rang = [tempStr rangeOfString:imagestr];
                
                
                [tempStr replaceCharactersInRange:rang withString:key];
                
                [dic setObject:value forKey:key];
                
                
            }
        }

    }
    
}





-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

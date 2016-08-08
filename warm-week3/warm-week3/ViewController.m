//
//  ViewController.m
//  warm-week3
//
//  Created by 朱益达 on 16/8/3.
//  Copyright © 2016年 朱益达. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
@property(nonatomic,strong)UIWebView *web;
@property(nonatomic,strong)NSMutableString *htmlstring;
@property(nonatomic,strong)NSString *sanboxpath;
@property(nonatomic,strong)NSString *jsstring;
@property(nonatomic,strong)NSString *imgstring;
@property(nonatomic,strong)NSString *stylesheetstr;
@property(nonatomic,strong)NSString *htmlpath;
@end

@implementation ViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    
     _web =[[UIWebView alloc] initWithFrame:self.view.bounds];
//    NSString *urlstring = @"http://www.jianshu.com/";
    NSString *urlstring = @"http://www.jianshu.com/p/51cf2ac61906";

    _sanboxpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSLog(@"%@",_sanboxpath);
    _htmlstring = [NSMutableString stringWithContentsOfURL:[NSURL URLWithString:urlstring] encoding:NSUTF8StringEncoding error:nil];
   
    NSInteger mm = [[NSUserDefaults standardUserDefaults] integerForKey:@"ETag"];
    
    if (mm == _htmlstring.length) {
       
        NSLog(@"网页没有发生改变");
      
        
       [self localhtml];
        

        
    }else{
        NSLog(@"网页发生改变");
        
        [_web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]]];
        [self.view addSubview:_web];
       
         [self storescriptstring];
        

        [[NSUserDefaults standardUserDefaults] setInteger:_htmlstring.length forKey:@"ETag"];
        
       
        NSLog(@"ETag的值为：%lu",mm);
        NSLog(@"%lu",_htmlstring.length);

  }
}

-(void)localhtml{
    NSString *sanboxpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSLog(@"%@",sanboxpath);
    
    NSString *sanpath = [sanboxpath stringByAppendingPathComponent:@"HTML"];
    NSString *final = [sanpath stringByAppendingPathComponent:@"index.html"];
    NSString *str = [NSString stringWithContentsOfFile:final encoding:NSUTF8StringEncoding error:nil];
    
    
    [_web loadHTMLString:str baseURL:[NSURL URLWithString:final]];
     _web.scalesPageToFit =YES;
    [self.view addSubview:_web];
    }
    
//本地保存HTML中的内容
-(void)storeHTMLstring{

    NSString *htmlpath = [_sanboxpath stringByAppendingPathComponent:@"/HTML"];
    NSLog(@"%@",htmlpath);
    if (![[NSFileManager defaultManager] fileExistsAtPath:htmlpath]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:htmlpath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    _htmlpath = [htmlpath stringByAppendingPathComponent:@"index.html"];
    [_htmlstring writeToFile:_htmlpath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}


//本地保存script
-(void)storescriptstring{
    

    NSMutableString *tempStr = _htmlstring.mutableCopy;
    
    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:@"<script[^>]*?>[\\s\\S]*?</script>" options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
    //@"<script[^>]*?>[\\s\\S]*?</script>"   @"<img.*src=(.*?)[^>]*?>"  /HTML/index.html   /HTML/assets/javascripts/
    
    NSArray *resultscript = [regex1 matchesInString:tempStr options:NSMatchingReportCompletion range:NSMakeRange(0, tempStr.length)];
    

    for (NSTextCheckingResult *result in resultscript) {
        
        _jsstring = [tempStr substringWithRange:result.range];
    
       // NSLog(@"%@",_jsstring);
        NSArray *ary= nil;
        if ([_jsstring rangeOfString:@"src=\""].location!= NSNotFound) {
            
            ary = [_jsstring componentsSeparatedByString:@"src=\""];
            
            
        }
        
        
        //
        NSString *jspath = [_sanboxpath stringByAppendingPathComponent:@"demo.js"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:jspath]) {
            [[NSFileManager defaultManager] createFileAtPath:jspath contents:nil attributes:nil];
        }
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:jspath];
        //
        NSString *jsstr = nil;
        
        if (ary.count >= 2) {
            
           jsstr = ary[1];
            
            NSUInteger num = [jsstr rangeOfString:@"\""].location;
            
            
            if (num != NSNotFound) {
                
                jsstr = [jsstr substringToIndex:num];
            
              //  NSLog(@"%@",jsstr);


               NSString *jshtml = [NSString stringWithContentsOfURL:[NSURL URLWithString:jsstr] encoding:NSUTF8StringEncoding error:nil];
               NSData *stringData  = [jshtml dataUsingEncoding:NSUTF8StringEncoding];
               [fileHandle writeData:stringData]; //追加写入数据
                [fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
                
                

          _htmlstring =  [_htmlstring stringByReplacingOccurrencesOfString:jsstr withString:jspath];
               
                

            }
            
 
        }
        
        

    }
    [self storesstylesheet];

}

//本地保存img


-(void)storesimages{
    
//    NSString *imagepath = [_sanboxpath stringByAppendingPathComponent:@"/HTML/assets/images.txt"];
//    //        NSLog(@"%@",htmlpath);
//    if (![[NSFileManager defaultManager] fileExistsAtPath:imagepath]) {
//        
//        [[NSFileManager defaultManager] createFileAtPath:imagepath contents:nil attributes:nil];
//    }
    
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
        //
        
        NSString *jspath = [_sanboxpath stringByAppendingPathComponent:@"img.txt"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:jspath]) {
            [[NSFileManager defaultManager] createFileAtPath:jspath contents:nil attributes:nil];
        }
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:jspath];
        
        //
        
        if (ary.count >= 2) {
            NSString *imagestr = ary[1];
            
            NSUInteger num = [imagestr rangeOfString:@"\""].location;
            if (num != NSNotFound) {
                imagestr = [imagestr substringToIndex:num];
               
                
             //   NSLog(@"%@",imagestr);
                
                NSString *jshtml = [NSString stringWithContentsOfURL:[NSURL URLWithString:imagestr] encoding:NSUTF8StringEncoding error:nil];
                
                
                [fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
                
                
                NSData* stringData  = [jshtml dataUsingEncoding:NSUTF8StringEncoding];
                
                [fileHandle writeData:stringData]; //追加写入数据
                
                
                
                _htmlstring = [_htmlstring stringByReplacingOccurrencesOfString:imagestr withString:jspath];
                
                
                
            }
        }
        
        [fileHandle closeFile];
        
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
    
    NSMutableArray *ary = nil;

    NSString *htmlcopy = _htmlstring.mutableCopy;
    NSArray *result1 = [regex1 matchesInString:htmlcopy options:NSMatchingReportCompletion range:NSMakeRange(0, htmlcopy.length)];
    NSMutableDictionary *urlDicts2 = [[NSMutableDictionary alloc] init];
    for (NSTextCheckingResult *item in result1) {
        NSString *imgHtml = [htmlcopy substringWithRange:[item rangeAtIndex:0]];
        // NSLog(@"%@",imgHtml);
        NSArray *tmpArray = nil;
        
        //
        NSString *jspath = [_sanboxpath stringByAppendingPathComponent:@"demo1.css"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:jspath]) {
            [[NSFileManager defaultManager] createFileAtPath:jspath contents:nil attributes:nil];
        }
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:jspath];
        //
        
       if ([imgHtml rangeOfString:@"href=\""].location != NSNotFound) {
            tmpArray = [imgHtml componentsSeparatedByString:@"href=\""];
        }
        
        if (tmpArray.count >= 2) {
            NSString *src = tmpArray[1];
            
            NSUInteger loc = [src rangeOfString:@"\""].location;
            if (loc != NSNotFound) {
                src = [src substringToIndex:loc];
            //    NSLog(@"stylesheet字符串为：%@",src);
                
                NSString *jshtml = [NSString stringWithContentsOfURL:[NSURL URLWithString:src] encoding:NSUTF8StringEncoding error:nil];

                
                
                
                
                NSData* stringData  = [jshtml dataUsingEncoding:NSUTF8StringEncoding];
                
                [fileHandle writeData:stringData]; //追加写入数据
                
                [fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
                


             _htmlstring = [_htmlstring stringByReplacingOccurrencesOfString:src withString:jspath];
                

      
            }
        }
        
        [fileHandle closeFile];
        
        }
    [self storeHTMLstring];

}




-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

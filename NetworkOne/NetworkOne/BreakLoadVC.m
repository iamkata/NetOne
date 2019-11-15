//
//  BreakLoadVC.m
//  NetworkOne
//
//  Created by sy.
//  Copyright ©sy. All rights reserved.
//  断点下载

/*
 AFN
 1不支持断点下载
 2文件上传支持
 3扩散
 
 1断点下载（下文件的时候，突然中断了，当我们第二次下载的时候，在第一次基础之上继续下载
    假如文件有 10MB， 下载到5MB的时候突然中断， 第二开启下载的时候，从第5MB开始下载数据
 ）
 技术手段： 1.1第一个请求头(request的header)设置 key:Range
 1.2 中转站：假如下载一个文件A到 Document文件夹，先把文件下载到Tmp文件夹下面，当文件全部下载完的时候，在把文件移到（move）Document文件夹下。（可以判断一个任务是否有过异常，开启一个网络任务的时候，先去Tmp文件夹找这个网络相关的文件数据，如果有的相关的数据，那么这个网络之前有操作过，如果没有，就认为是一个新的）
 */

#import "BreakLoadVC.h"

#define ImageURL @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1573808735952&di=0fc4400fb3f01736e08e8a6dd2d43f12&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201502%2F18%2F20150218133515_QviYV.thumb.700_0.jpeg"

@interface BreakLoadVC ()<NSURLSessionDataDelegate>{
    
    NSString *filePath; // 目标路径
    NSString *filePathTmp; // 中专站路径
    
    NSOutputStream *outputStream;
}

@end

@implementation BreakLoadVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"断点下载";

    NSString *fileName = @"test.png";
    
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    filePath = [document stringByAppendingPathComponent:fileName];
    filePathTmp = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    
    outputStream = [[NSOutputStream alloc] initToFileAtPath:filePathTmp append:YES];
    [outputStream open];
    
    NSLog(@"%@", filePath);
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self netLoadImage];
}

- (void)netLoadImage{
    
    NSURL *url = [NSURL URLWithString:ImageURL];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    
    /*Range 0-10000, 服务器就返回文件的前面10000个字节
     Range  20000 - 30000, 服务器就返回文件的20000个字节的位置到30000个字节的位置之间的数据
     Range 50000-  从50000个字节位置开始的内容
    */
    
    //这是设置请求头的代码, 添加以下代码就能实现断点下载
    // filezise 文件大小（这个文件已经下载多少数据了）
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePathTmp error:nil];
    long filezise = [[fileInfo objectForKey:NSFileSize] longValue];
    [request setValue:[NSString stringWithFormat:@"bytes=%ld-", filezise] forHTTPHeaderField:@"Range"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    
    [task resume];
}

// 1响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    // 从响应头获取总共需要下载的数据,详情请看BreakLoadVC2.m
    completionHandler(NSURLSessionResponseAllow);
}


// 2 接收数据 （计算已经下载了多少）
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
 
    
    //方法一. 拼接数据性能不好,因为有很多打开文件操作
//    NSMutableData *fileData = [NSMutableData dataWithContentsOfFile:filePathTmp];
//    if (!fileData) {
//        fileData = [NSMutableData new];
//    }
//    [fileData appendData:data];
//    [fileData writeToFile:filePathTmp atomically:YES];
    
    //方法二. 输出流拼接数据,这个会直接根据路径有就拼接, 没有就创建
    //不用一直打开关闭文件了
    [outputStream write:[data bytes] maxLength:data.length];
}

// 3 完成
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    
    [outputStream close];
    // 3.1 把文件从Tmp文件夹移到目标区域：document
    [[NSFileManager defaultManager] moveItemAtPath:filePathTmp toPath:filePath error:nil];
    
}

@end

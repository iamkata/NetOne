//
//  SysDownLoadVC.m
//  NetworkOne
//
//  Created by 徐金城 on 2019/11/15.
//  Copyright © 2019 sy. All rights reserved.
//

#import "SysDownLoadVC.h"
#define FileName @"121212.jpeg"
#define ImageURL @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1573808735952&di=0fc4400fb3f01736e08e8a6dd2d43f12&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201502%2F18%2F20150218133515_QviYV.thumb.700_0.jpeg"

@interface SysDownLoadVC () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSData *resumData;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation SysDownLoadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"文件下载";
    self.view.backgroundColor = [UIColor whiteColor];
    //[self download];
    
    [self startBtnClick];
}

-(void)download
{
    //1.url
    NSURL *url = [NSURL URLWithString:ImageURL];
    
    //2.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //3.创建session
    NSURLSession *session = [NSURLSession sharedSession];
    
    //4.创建Task
    /*
     第一个参数:请求对象
     第二个参数:completionHandler 回调
     location:
     response:响应头信息
     error:错误信息
     */
    //该方法内部已经实现了边接受数据边写沙盒(tmp)的操作
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //6.处理数据
        NSLog(@"%@---%@",location,[NSThread currentThread]);
        
        //6.1 拼接文件全路径
        NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
        
        //6.2 剪切文件
        [[NSFileManager defaultManager]moveItemAtURL:location toURL:[NSURL fileURLWithPath:fullPath] error:nil];
        NSLog(@"%@",fullPath);
    }];
    
    //5.执行Task
    [downloadTask resume];
}

-(void)startBtnClick
{
    //1.url
    NSURL *url = [NSURL URLWithString:ImageURL];
    
    //2.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //3.创建session
    NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.session = session;
    
    //4.创建Task
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
    self.downloadTask = downloadTask;
    //5.执行Task
    [downloadTask resume];
}


#pragma mark NSURLSessionDownloadDelegate
/**
 *  写数据
 *
 *  @param session                   会话对象
 *  @param downloadTask              下载任务
 *  @param bytesWritten              本次写入的数据大小
 *  @param totalBytesWritten         下载的数据总大小
 *  @param totalBytesExpectedToWrite  文件的总大小
 */
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
    //1. 获得文件的下载进度
    NSLog(@"%f",1.0 * totalBytesWritten/totalBytesExpectedToWrite);
}

/**
 *  当恢复下载的时候调用该方法
 *
 *  @param fileOffset         从什么地方下载
 *  @param expectedTotalBytes 文件的总大小
 */
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"%s",__func__);
}

/**
 *  当下载完成的时候调用
 *
 *  @param location     文件的临时存储路径
 */
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"%@",location);
    
    //1 拼接文件全路径
    NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    
    //2 必须要剪切文件,因为系统会默认删掉
    [[NSFileManager defaultManager]moveItemAtURL:location toURL:[NSURL fileURLWithPath:fullPath] error:nil];
    NSLog(@"%@",fullPath);
}

/**
 *  请求结束
 */
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"didCompleteWithError");
}

@end

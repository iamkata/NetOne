//
//  UpdateLoadVC.m
//  NetworkOne
//
//  Created by sy.
//  Copyright © sy. All rights reserved.
//

#import "UpdateLoadVC.h"

#define UpdateImageURL @"http://www.8pmedu.com/themes/jianmo/img/upload.php"
#define Kboundary @"----WebKitFormBoundaryjv0UfA04ED44AhWx"
#define KNewLine [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]

@interface UpdateLoadVC ()<NSURLSessionDelegate, NSURLSessionDataDelegate>

@end

@implementation UpdateLoadVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"文件上传";
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self netUpdateImage];
}

/*
 AFN里面就是这样根据表单格式来封装的
 //上传操作比下载操作复杂,是通过表单这种格式来进行上传的
 表单 mulitpart/form-data; (格式)
 
 1 边界符号 要配置请求头
 
 上传都是POST： bodydata
 // 2.1 边界符号（开始边界）
 
 // 2.2 属性配置 名字；key；类型
 
 // 2.3 拼接数据(配置数据+文件数据)
 
 // 2.4 边界符号 (结束边界)
 */

- (void)netUpdateImage{
    
    NSURL *url = [NSURL URLWithString:UpdateImageURL];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    //请求体
    NSMutableData *bodyData = [self getBodyDataWithRequest:request];
    
    //设置请求体
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    
    //回话对象
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    //请求task
    /*
     第一个参数:请求对象
     第二个参数:传递是要上传的数据(请求体)
     第三个参数:
     */
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData: bodyData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //解析
        NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    
    //执行Task
    [uploadTask resume];
}

- (NSMutableData *)getBodyDataWithRequest:(NSMutableURLRequest *)request {
    
    //1 边界符号要配置请求头里面去
    /*
     multipart/form-data 是表单格式
     charset=utf-8 是utf-8编码
     bounary 是表单开头
     */
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; charset=utf-8; boundary=%@", Kboundary] forHTTPHeaderField:@"Content-Type"];
    
    /// body
    NSMutableData *boydData = [NSMutableData data];
    // 2.1 边界符号（开始边界）
    // body每一个段内容以换行符作为结束标示
    NSString *fileBeginBoundary = [NSString stringWithFormat:@"--%@\r\n", Kboundary];
    [boydData appendData:[fileBeginBoundary dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 2.2 属性配置 名字；key；类型
    
    NSString *serverFileKey = @"image";  //key
    NSString *serverFileName = @"eoc123111.png";  //name
    NSString *serverContentTypes = @"image/png";  //类型
    
    // filename已命名文件;  name相当于一个key, 这个名字和服务器保持一致
    /*
     理解key，表单发送给服务端，服务端拿到数据之后，可以将任务解析成一个字典了imageDict；图片数据会通过这个字典里面的name来获取图片（伪代码 image =  imageDict[serverFileKey]）
     */
    //2.3 拼接数据(创建一个字符串来拼装)
    NSMutableString *string = [NSMutableString new];
    [string appendFormat:@"Content-Disposition:form-data; name=\"%@\"; filename=\"%@\" ", serverFileKey, serverFileName];
    [string appendFormat:@"%@", KNewLine];
    [string appendFormat:@"Content-Type:%@", serverContentTypes];
    [string appendFormat:@"%@", KNewLine];
    [string appendFormat:@"%@", KNewLine];
    [boydData appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 2.3 拼接数据(拼接文件数据)
    UIImage *image = [UIImage imageNamed:@"1.png"];
    NSData *imageData = UIImagePNGRepresentation(image);
    [boydData appendData:imageData];
    
    // 2.4 边界符号 (结束边界)
    NSString *fileEndBoundary = [NSString stringWithFormat:@"\r\n--%@", Kboundary];
    [boydData appendData:[fileEndBoundary dataUsingEncoding:NSUTF8StringEncoding]];
    
    return boydData;
}

// 1响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    
    completionHandler(NSURLSessionResponseAllow);
}

// 上传进度
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    
    //每包发送的大小bytesSent，totalBytesSent已经上传了多少；totalBytesExpectedToSend总共要发送多少
    // 32768 = 32KB
    NSLog(@"didSendBodyData: %ld--%ld-%ld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    
}

// 2 接收数据
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
    NSDictionary *infoDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"%@", infoDict);
}

// 3 完成
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
}

@end

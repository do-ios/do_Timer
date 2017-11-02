//
//  do_Timer_MM.m
//  DoExt_MM
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_Timer_MM.h"

#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doInvokeResult.h"

@implementation do_Timer_MM {
    NSTimer *_timer;
    BOOL _isOn;
    float _interval;
    float _delay;
    doInvokeResult * _invokeResult;
    
    BOOL _isInterval;
}

#pragma mark - 注册属性（--属性定义--）
/*
 [self RegistProperty:[[doProperty alloc]init:@"属性名" :属性类型 :@"默认值" : BOOL:是否支持代码修改属性]];
 */
-(void)OnInit
{
    [super OnInit];
    //注册属性
    [self RegistProperty:[[doProperty alloc]init:@"interval" :Number :@"1000" :NO]];
    [self RegistProperty:[[doProperty alloc]init:@"delay" :Number :@"0" :NO]];
    
    _isInterval = NO;
}

//销毁所有的全局对象
-(void)Dispose
{
    //自定义的全局属性
    if(_timer.isValid)
        [_timer invalidate];
    _timer = nil;
}
#pragma mark -
#pragma mark - 同步异步方法的实现
/*
 1.参数节点
 NSDictionary *_dictParas = [parms objectAtIndex:0];
 a.在节点中，获取对应的参数
 NSString *title = [doJsonHelper GetOneText: _dictParas :@"title" :@"" ];
 说明：第一个参数为对象名，第二为默认值
 
 2.脚本运行时的引擎
 id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
 
 同步：
 3.同步回调对象(有回调需要添加如下代码)
 doInvokeResult *_invokeResult = [parms objectAtIndex:2];
 回调信息
 如：（回调一个字符串信息）
 [_invokeResult SetResultText:((doUIModule *)_model).UniqueKey];
 异步：
 3.获取回调函数名(异步方法都有回调)
 NSString *_callbackName = [parms objectAtIndex:2];
 在合适的地方进行下面的代码，完成回调
 新建一个回调对象
 doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
 填入对应的信息
 如：（回调一个字符串）
 [_invokeResult SetResultText: @"异步方法完成"];
 [_scritEngine Callback:_callbackName :_invokeResult];
 */
//同步
- (void)isStart:(NSArray *)parms
{
    //自己的代码实现
    _invokeResult = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    [_invokeResult SetResultBoolean:_timer.isValid];
}

//同步
- (void)start:(NSArray *)parms
{
    [self stop:nil];

    _invokeResult = [parms objectAtIndex:2];
    
    [NSThread detachNewThreadSelector:@selector(onTimeStart) toTarget:self withObject:nil];
    
}

- (void)onTimeStart{
    NSString *interval = [self GetPropertyValue:@"interval"];
    if (!interval || [interval isEqualToString:@""]) {
        _isInterval = NO;
    }else
        _isInterval = YES;
    _interval = [[self GetPropertyValue:@"interval"] floatValue]/1000.0f;
    _delay = [[self GetPropertyValue:@"delay"] floatValue]/1000.0f;
    if (_delay < 0) {
        return;
    }
    if (_interval <= 0) {
        if (_isInterval) {
            return;
        }else
            _interval = [[self GetProperty:@"interval"].DefaultValue floatValue]/1000.0f;
    }
    
    _timer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:_delay] interval:_interval target:self selector:@selector(fireEvent) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
}

- (void)fireEvent
{
    [self.EventCenter FireEvent:@"tick" :_invokeResult];
}

- (void)stop:(NSArray *)parms
{
    if (!_timer) {
        return;
    }
    [_timer invalidate];
}

@end

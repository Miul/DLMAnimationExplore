//
//  DLMViewController.m
//  DLMAnimationExplore
//
//  Created by liumu on 2019/1/11.
//  Copyright © 2019 Miul. All rights reserved.
//

#import "DLMViewController.h"

@interface DLMViewController ()

@property (nonatomic, strong) CALayer *redLayer;

@property (nonatomic, strong) UIView *greenView;

@property (nonatomic, strong) UIView *blueView;

@property (nonatomic, strong) UIView *yellowView;

@property (nonatomic, strong) UIView *smallView;

@end

@implementation DLMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createUI];
}

- (void)createUI {
    _greenView = [[UIView alloc] initWithFrame:CGRectMake(30, 30, 100, 100)];
    _greenView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_greenView];
    
    _redLayer = [[CALayer alloc] init];
    _redLayer.frame = CGRectMake(30, 200, 100, 100);
    _redLayer.backgroundColor = [UIColor redColor].CGColor;
    [self.view.layer addSublayer:_redLayer];
    
    _blueView = [[UIView alloc] initWithFrame:CGRectMake(30, 400, 100, 100)];
    _blueView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:_blueView];
    
    _yellowView = [[UIView alloc] initWithFrame:CGRectMake(200, 600, 100, 100)];
    _yellowView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:_yellowView];
    
    _smallView = [[UIView alloc] initWithFrame:CGRectMake(200, 400, 20, 20)];
    _smallView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_smallView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self movingTest];
    });
}

- (void)movingTest {
    //greenView设置frame后没有动画直接跳到新位置
    //self.greenView.frame = CGRectMake(230, 30, 100, 100);
    
    //layer有隐式动画
    self.redLayer.frame = CGRectMake(230, 200, 100, 100);
    
    CABasicAnimation *anim = [self moveAnimation];
    
    //动画结束后会变到最初的位置
    [self.greenView.layer addAnimation:anim forKey:@"MoveGreenAnim"];
    //layer默认的anchorPoint是中心点
    _greenView.layer.anchorPoint = CGPointMake(0, 0);
    //修改modelLayer的位置
    //此时动画开始前已经把位置设为了230,所以看到的是从230开始做动画
    _greenView.layer.position = CGPointMake(230, 30);
    _greenView.layer.bounds = CGRectMake(0, 0, 150, 150);
    NSLog(@"greenView frame = %@", [NSValue valueWithCGRect:_greenView.frame]);
    
    anim.beginTime = CACurrentMediaTime() + 1;
    [self.blueView.layer addAnimation:anim forKey:@"MoveBlueAnim"];
    
    [self.yellowView.layer addAnimation:[self keyFrameAnimation] forKey:@"keyframeAnim"];
    
    [self.smallView.layer addAnimation:[self keyFramePathAnimation] forKey:@"keyPathframeAnim"];
}

- (CABasicAnimation *)moveAnimation {
    CABasicAnimation *moveAnim = [CABasicAnimation animationWithKeyPath:@"position.x"];
    //与byValue等价,byValue是to和from的差值
//    moveAnim.fromValue = @(30);
//    moveAnim.toValue = @(230);
    
    //再不知道初始值,只想做增量效果时更通用
    moveAnim.byValue = @(200);
    moveAnim.duration = 3.0;
    
    moveAnim.delegate = self;
    
    NSLog(@"moveAnim = %@", moveAnim);
    return moveAnim;
}

- (CAKeyframeAnimation *)keyFrameAnimation {
    CAKeyframeAnimation *keyAnim = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    keyAnim.values = @[@0, @30, @-30, @30, @0];
    //keyAnim.values = @[@250, @280, @220, @280, @250];
    keyAnim.calculationMode = kCAAnimationPaced;
//    keyAnim.keyTimes = @[@0, @(1/6.0), @(3/6.0), @(5/6.0), @1];
    keyAnim.duration = 0.4;
    
    //这个属性设为YES,上面的values就不用使用绝对值,可以设置已动画当前值的增量值
    keyAnim.additive = YES;
    
    return keyAnim;
}

- (CAKeyframeAnimation *)keyFramePathAnimation {
    CAKeyframeAnimation *keyPathAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    CGRect boundRect = CGRectMake(-150, -150, 300, 300);
    keyPathAnim.path = CFAutorelease(CGPathCreateWithEllipseInRect(boundRect, NULL));
    keyPathAnim.duration = 4;
    keyPathAnim.additive = YES;
    keyPathAnim.repeatCount = HUGE_VALF;
    keyPathAnim.calculationMode = kCAAnimationPaced;
    keyPathAnim.rotationMode = kCAAnimationRotateAuto;
    
    return keyPathAnim;
}

#pragma mark - CAAnimationDelegate
//从打印的anim看,anim都是复制后的实例,如果想直接比较是哪个anim实例肯定不可以
//一个有效的方法是设置anim的AnimationKey属性,然后通过这个属性来判断是哪个anim
- (void)animationDidStart:(CAAnimation *)anim {
    NSLog(@"start anim = %@, anim key = %@", anim, [anim valueForKey:@"AnimationKey"]);
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSLog(@"stop anim = %@", anim);
}

@end

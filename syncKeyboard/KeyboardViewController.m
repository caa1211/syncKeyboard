//
//  KeyboardViewController.m
//  syncKeyboard
//
//  Created by caa on 11/9/15.
//  Copyright © 2015 yahoo. All rights reserved.
//

#import "KeyboardViewController.h"
#import <SocketIO.h>
#import <SocketIOPacket.h>

@interface KeyboardViewController () <SocketIODelegate>
@property (weak, nonatomic) IBOutlet UILabel *debugLabel;

@property (weak, nonatomic) IBOutlet UIButton *nextKeyboard;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;
@property (nonatomic, strong) SocketIO *socketIO;
@property (nonatomic, strong) NSString *roomName;
@end

typedef NS_ENUM(NSInteger, CntSt) {
    CntSt_NO = 0,
    CntSt_JOINING,
    CntSt_OK
};


@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"============Custom height===============");
    
    NSLayoutConstraint *heightConstraint =
    [NSLayoutConstraint constraintWithItem: self.view
                                 attribute: NSLayoutAttributeHeight
                                 relatedBy: NSLayoutRelationEqual
                                    toItem: nil
                                 attribute: NSLayoutAttributeNotAnAttribute
                                multiplier: 0.0
                                  constant: 70];
    [self.view addConstraint: heightConstraint];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.socketIO sendEvent:@"leaveRoom" withData:self.roomName];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"uniqueIdentifier %@", uniqueIdentifier);
    self.roomName = @"my room";
    
    [self.nextKeyboard addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
    [self connectionStatusChange:CntSt_NO];
    [self setupSocketio];
}

- (void) setupSocketio {
    NSString *socketServer = @"believeweave.corp.gq1.yahoo.com";
    self.socketIO = [[SocketIO alloc] initWithDelegate:self];
    self.socketIO.delegate = self;
    //[socketIO connectToHost:@"believeweave.corp.gq1.yahoo.com" onPort:3000 withParams:@{@"auth_token":@"1234"}];
    [self.socketIO connectToHost:socketServer onPort:3001];
}

# if 0 // Unused code


- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet{
    self.debugLabel.text = @"c";
}

- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet{
    //self.debugLabel.text = @"d"; //v
}
#endif
- (IBAction)onRetry:(id)sender {
    //[self.socketIO sendEvent:@"sendMsg" withData:@{@"room": self.roomName, @"data": @"ooo"}];
    // do retry
    [self setupSocketio];
}

- (void) socketIODidConnect:(SocketIO *)socket{
    [self connectionStatusChange:CntSt_JOINING];
    [self.socketIO sendEvent:@"joinRoom" withData: self.roomName];
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error{
    [self connectionStatusChange:CntSt_NO];
}


- (void) socketIO:(SocketIO *)socket onError:(NSError *)error{
    [self connectionStatusChange:CntSt_NO];
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet
{
    NSLog(@"didReceiveMessage >>> data: %@", packet.data);
    self.debugLabel.text = @"11";
}


- (NSString *)getLastWordBeforeInput {
    //get last word before input. if last character is a space, the return value will be an empty string
    NSString *context = [self.textDocumentProxy documentContextBeforeInput];
    context = [context stringByReplacingOccurrencesOfString:@"[^a-zA-Z]" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, context.length)];
    NSArray *listItems = [context componentsSeparatedByString:@" "];
    if (listItems.lastObject == nil) {
        return @"";
    }
    return listItems.lastObject;
}


- (void) connectionStatusChange:(CntSt)st {
    if(st == CntSt_NO){
        [self.statusImage setBackgroundColor:[UIColor redColor]];
        self.retryButton.hidden = NO;
    }else if (st == CntSt_JOINING){
        [self.statusImage setBackgroundColor:[UIColor yellowColor]];
    }else if (st == CntSt_OK){
        [self.statusImage setBackgroundColor:[UIColor greenColor]];
        self.retryButton.hidden = YES;
    }
}

// event delegate
- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSString *msgName = packet.name;
    NSString *remoteInput = packet.args[0][@"data"];
    if ( [msgName isEqualToString:@"receiveMsg"] ) {
        [self receiveKey:remoteInput];
    }else if ([msgName isEqualToString:@"receiveCtrlMsg"]) {
        [self receiveCtrlKey:remoteInput];
    }else if ([msgName isEqualToString:@"roomJoined"]) {
        [self connectionStatusChange:CntSt_OK];
    }

}

-(void) receiveKey:(NSString*)remoteInput {
    while (self.textDocumentProxy.hasText==YES)
    {
        [self.textDocumentProxy deleteBackward];
    }
    self.debugLabel.text = remoteInput;
    NSLog(@"didReceiveEvent >>> data: %@", remoteInput);
    [self.textDocumentProxy insertText:remoteInput];
}

-(void) receiveCtrlKey:(NSString*)remoteInput {
    if ([remoteInput isEqualToString:@"return"]) {
        [self.textDocumentProxy insertText:@"\n"];
        
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
    //[self.nextKeyboard setTitleColor:textColor forState:UIControlStateNormal];
}

@end

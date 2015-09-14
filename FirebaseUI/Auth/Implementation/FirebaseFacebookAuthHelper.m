/*
 * Firebase UI Bindings iOS Library
 *
 * Copyright © 2015 Firebase - All Rights Reserved
 * https://www.firebase.com
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *this
 * list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binaryform must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY FIREBASE AS IS AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL FIREBASE BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *(INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 *NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "FirebaseFacebookAuthHelper.h"

@implementation FirebaseFacebookAuthHelper

NSString *const kAuthProvider = @"facebook";
NSString *const kEmailScope = @"email";

- (instancetype)initWithRef:(Firebase *)aRef
                   delegate:
                       (UIViewController<FirebaseAuthDelegate> *)authDelegate {
  self = [super init];
  if (self) {
    self.ref = aRef;
    self.loginManager = [[FBSDKLoginManager alloc] init];
    self.delegate = authDelegate;
  }
  return self;
}

- (void)login {
  [self.loginManager logInWithReadPermissions:@[
    kEmailScope
  ] fromViewController:self.delegate handler:^(FBSDKLoginManagerLoginResult
                                                   *facebookResult,
                                               NSError *facebookError) {

    if (facebookError) {
      // Surface any errors
      [self.delegate onError:facebookError];
    } else if (facebookResult.isCancelled) {
      // Surface cancellations
      [self.delegate onCancelled];
    } else {
      // Get the token from the FBSDKAccessToken
      NSString *accessToken =
          [[FBSDKAccessToken currentAccessToken] tokenString];

      // Authenticate with Firebase
      [self.ref authWithOAuthProvider:kAuthProvider
                                token:accessToken
                  withCompletionBlock:^(NSError *error, FAuthData *authData) {
                    if (error) {
                      [self.delegate onError:error];
                    } else {
                      // TODO: Possibly register a onAuth listener and ignore
                      // login events
                      [self.delegate onAuthStageChange:authData];
                    }
                  }];
    }
  }];
}

- (void)logout {
  [self.ref unauth];
}

@end
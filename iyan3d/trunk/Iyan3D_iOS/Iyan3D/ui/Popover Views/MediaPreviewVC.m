//
//  MediaPreviewVC.m
//  Iyan3D
//
//  Created by Karthik on 15/06/16.
//  Copyright © 2016 Smackall Games. All rights reserved.
//

#import "MediaPreviewVC.h"
#import "Utility.h"
#import "AppHelper.h"

@implementation MediaPreviewVC

#define IMAGE_TYPE 0
#define VIDEO_TYPE 1

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mediaType:(int)medType medPath:(NSString*) medPath;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mediaType = medType;
        mediaPath = medPath;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shareBtn.layer.cornerRadius = 5.0;
    self.closeBtn.layer.cornerRadius = 5.0;
    
    if(mediaType == IMAGE_TYPE) {
        
        UIImage *img = [UIImage imageWithContentsOfFile:mediaPath];
        float imgWidth = img.size.width;
        float imgHeight = img.size.height;
        float aspectRatio = (imgWidth > imgHeight) ? (imgWidth / imgHeight) : (imgHeight / imgWidth);
        CGRect imgViewFrame = self.medView.frame;
        
        if([Utility IsPadDevice] || [[AppHelper getAppHelper] iPhone6Plus]) {
            if(imgWidth > imgHeight) {
                imgViewFrame.size.height = (imgViewFrame.size.width / aspectRatio);
                float offset = (self.medView.frame.size.height - imgViewFrame.size.height) / 2.0;
                imgViewFrame.origin.y = offset;
            } else {
                imgViewFrame.size.width = (imgViewFrame.size.height / aspectRatio);
                float offset = (self.medView.frame.size.width - imgViewFrame.size.width) / 2.0;
                imgViewFrame.origin.x = offset;
            }
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imgViewFrame];
        imageView.image = img;
        imageView.autoresizingMask = self.medView.autoresizingMask;
        [self.medView addSubview:imageView];
        
    } else if (mediaType == VIDEO_TYPE) {
        self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:mediaPath]];
        [self.moviePlayer.view setFrame:self.medView.frame];
        [self.moviePlayer.view setCenter:self.medView.center];
        [self.medView addSubview:self.moviePlayer.view];
        [self.moviePlayer prepareToPlay];
        [self.moviePlayer play];
        
    }
    
    [self.shareBtn setTitle:NSLocalizedString(@"SHARE", nil) forState:UIControlStateNormal];
    [self.closeBtn setTitle:NSLocalizedString(@"CLOSE", nil) forState:UIControlStateNormal];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (IBAction)closeAction:(id)sender
{
    [self.moviePlayer stop];
    self.moviePlayer = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate closeView];
    }];
}

- (IBAction)shareAction:(id)sender
{
    [self.shareBtn setHidden:YES];
    //    [self.shareActivityIndicator setHidden:false];
    //    [self.shareActivityIndicator startAnimating];
    
    NSArray *objectsToShare;
    if(mediaType == IMAGE_TYPE) {
        objectsToShare = [NSArray arrayWithObjects:NSLocalizedString(@"share_image_social_media", nil), [UIImage imageWithContentsOfFile:mediaPath], nil];
    } else if(mediaType == VIDEO_TYPE){
        NSURL *videoURL = [NSURL fileURLWithPath:mediaPath];
        objectsToShare = [NSArray arrayWithObjects:NSLocalizedString(@"share_video_social_media", nil), videoURL, nil];
    }
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    if([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        if(!controller.popoverPresentationController.barButtonItem) {
            controller.popoverPresentationController.sourceView = self.view;
            controller.popoverPresentationController.sourceRect = self.shareBtn.frame;
        }
    }
    [controller setCompletionHandler:^(NSString *activityType, BOOL completed) {
        //        [self.shareActivityIndicator stopAnimating];
        //        [self.shareActivityIndicator setHidden:true];
        [self.shareBtn setHidden:NO];
        
        if(completed) {
            NSMutableDictionary * attributes = [[NSMutableDictionary alloc] init];
            if(mediaType == IMAGE_TYPE)
                [attributes setObject:@"Image" forKey:@"Share"];
            else
                [attributes setObject:@"Video" forKey:@"Share"];
        }
    }];
    
    [self presentViewController:controller animated:YES completion:nil];
    
}

@end

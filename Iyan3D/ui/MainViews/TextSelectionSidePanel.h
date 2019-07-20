//
//  TextSelectionSidePanel.h
//  Iyan3D
//
//  Created by sabish on 19/12/15.
//  Copyright © 2015 Smackall Games. All rights reserved.
//

#ifndef TextSelectionSidePanel_h
#define TextSelectionSidePanel_h

#import <UIKit/UIKit.h>
#import "CacheSystem.h"
#import "AppHelper.h"
#import "GetPixelDemo.h"
#import "TextFrameCell.h"
#import <CoreText/CoreText.h>
#import "TextColorPicker.h"
#import "WEPopoverController.h"
#import "PopUpViewController.h"
#import "GAI.h"
#import "Vector3.h"

@protocol TextSelectionDelegate

- (void)showOrHideLeftView:(BOOL)showView withView:(UIView*)subViewToAdd;
- (void)load3DTex:(int)type AssetId:(int)assetId TextureName:(NSString*)textureName TypedText:(NSString*)typedText FontSize:(int)fontSize BevelValue:(float)bevelRadius TextColor:(Vector4)colors FontPath:(NSString*)fontFileName isTempNode:(bool)isTempNode;
- (void)removeTempNodeFromScene;
- (BOOL)addTempNodeToScene;
- (void)textColorPicker:(UIView*)colorPickerButton;
- (void)showOrHideProgress:(BOOL)value;
- (void)deallocSubViews;

@end

@interface TextSelectionSidePanel : GAITrackedViewController <UICollectionViewDelegate, UICollectionViewDataSource, TextColorPickerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate> {
    NSArray*        fontListArray;
    CacheSystem*    cache;
    NSString*       docDirPath;
    NSMutableArray* fontArray;
    NSString *      fontDirectoryPath, *typedText;
    NSString*       cacheDirectory;
    CGFontRef       customFont;
    NSString*       customFontName;
    int             fontSize;
    int             tabValue, selectedIndex, tempSelectedIndex;
    float           red, green, blue, alpha;
    NSString*       fontFileName;
    int             bevelRadius;
    bool            withRig;
    bool            isCanceled;
}
@property (weak, nonatomic) IBOutlet UIView* dummyLeft;
@property (weak, nonatomic) IBOutlet UIView* dummyRight;

@property (weak, nonatomic) IBOutlet UIButton* cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton* addToScene;
@property (weak, nonatomic) IBOutlet UICollectionView* collectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl* fontTab;
@property (weak, nonatomic) IBOutlet UISlider* bevelSlider;
@property (weak, nonatomic) IBOutlet UITextField*     inputText;
@property (weak, nonatomic) id<TextSelectionDelegate> textSelectionDelegate;
@property (nonatomic, strong) TextColorPicker*        textColorProp;
@property (nonatomic, strong) WEPopoverController*    popoverController;
@property (nonatomic, strong) PopUpViewController*    popUpVc;
@property (weak, nonatomic) IBOutlet UIButton* colorWheelbtn;
@property (weak, nonatomic) IBOutlet UISwitch*        boneSwitch;
@property (strong, nonatomic) UITapGestureRecognizer* tap;

- (IBAction)bevalChangeAction:(id)sender;
- (IBAction)cancelBtnAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel* noFontMessageLable;
@property (weak, nonatomic) IBOutlet UILabel* addBoneLabel;
@property (weak, nonatomic) IBOutlet UILabel* colorLabel;
@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UIView* titleView;

@end

#endif

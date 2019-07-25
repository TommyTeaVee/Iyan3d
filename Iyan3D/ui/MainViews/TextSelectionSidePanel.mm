//
//  TextSelectionSidePanel.m
//  Iyan3D
//
//  Created by sabish on 19/12/15.
//  Copyright © 2015 Smackall Games. All rights reserved.
//

#import "TextSelectionSidePanel.h"
#import "Constants.h"
#import "Utility.h"

#define CANCEL_BUTTON_INDEX 0
#define OK_BUTTON_ACTION 1
#define FONT_STORE 0
#define MY_FONT 1
#define ASSET_TEXT_RIG 10
#define ASSET_TEXT 11

#define DEFAULT_FONT_SIZE 16

@interface TextSelectionSidePanel ()

@end

@implementation TextSelectionSidePanel

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        cache               = [CacheSystem cacheSystem];
        NSArray* srcDirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docDirPath          = [srcDirPath objectAtIndex:0];
        tabValue            = MY_FONT;
        red = green = blue = alpha = 1;
        withRig                    = false;
        isCanceled                 = false;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initializeFontListArray];
    if ([fontArray count] > 0) {
        [self.fontTab setSelectedSegmentIndex:MY_FONT];
        tabValue = MY_FONT;
        [self.collectionView reloadData];
    } else {
        tabValue = MY_FONT;
    }

    //    fontArray = [cache GetAssetList:FONT Search:@""];
    typedText      = [NSString stringWithFormat:@"Text"];
    cache          = [CacheSystem cacheSystem];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    cacheDirectory = [paths objectAtIndex:0];
    //[self initializeFontListArray];
    if ([Utility IsPadDevice]) {
        [self.collectionView registerNib:[UINib nibWithNibName:@"TextFrameCell" bundle:nil] forCellWithReuseIdentifier:@"CELL"];
    } else {
        [self.collectionView registerNib:[UINib nibWithNibName:@"TextFrameCellPhone" bundle:nil] forCellWithReuseIdentifier:@"CELL"];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsSet) name:@"AssetsSet" object:nil];
    self.titleView.layer.cornerRadius  = CORNER_RADIUS;
    self.cancelBtn.layer.cornerRadius  = CORNER_RADIUS;
    self.addToScene.layer.cornerRadius = CORNER_RADIUS;
    self.bevelSlider.value             = bevelRadius;

    [self.titleLabel setText:NSLocalizedString(@"My Fonts", nil)];
    [self.inputText setText:NSLocalizedString(@"Enter Text", nil)];
    [self.cancelBtn setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateNormal];
    [self.addToScene setTitle:NSLocalizedString(@"ADD TO SCENE", nil) forState:UIControlStateNormal];

    [self.addBoneLabel setText:NSLocalizedString(@"With Bones", nil)];
    [self.colorLabel setText:NSLocalizedString(@"Color", nil)];

    [self.fontTab setTitle:NSLocalizedString(@"Font Store", nil) forSegmentAtIndex:0];
    [self.fontTab setTitle:NSLocalizedString(@"My Fonts", nil) forSegmentAtIndex:1];

    _inputText.delegate             = self;
    UITapGestureRecognizer* tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    tapGest.delegate                = self;
    [self.view addGestureRecognizer:tapGest];
    //_inputText.returnKeyType = UIReturnKeyDone  ;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    [[AppHelper getAppHelper] toggleHelp:nil Enable:NO];
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    if (isCanceled)
        return NO;
    [self load3dText];
    [textField resignFirstResponder];
    return NO;
}

- (void)initializeFontListArray {
    fontListArray           = Nil;
    fontDirectoryPath       = [NSString stringWithFormat:@"%@/Resources/Fonts", docDirPath];
    NSArray* fontExtensions = [NSArray arrayWithObjects:@"ttf", @"otf", nil];
    NSArray* filesGathered;
    [self copyFontFilesFromDirectory:docDirPath ToDirectory:fontDirectoryPath withExtensions:fontExtensions];
    filesGathered = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fontDirectoryPath error:Nil];
    fontListArray = [filesGathered filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension IN %@", fontExtensions]];

    if ([fontListArray count] > 0) {
        fontFileName = [fontListArray objectAtIndex:0];
        [[AppHelper getAppHelper] saveToUserDefaults:fontFileName withKey:@"Font_Store_Array"];
    }
}

- (void)copyFontFilesFromDirectory:(NSString*)sourceDir ToDirectory:(NSString*)destinationDir withExtensions:(NSArray*)extensions {
    NSArray* fontFilesToCopy = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourceDir error:Nil] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension IN %@", extensions]];

    for (NSString* aFile in fontFilesToCopy) {
        NSError* error;
        if (![[NSFileManager defaultManager] fileExistsAtPath:[destinationDir stringByAppendingPathComponent:aFile]]) {
            NSLog(@"DESTINATION DIR %@ FILE %@ SOURCE DIR %@", destinationDir, aFile, sourceDir);
            [[NSFileManager defaultManager] copyItemAtPath:[sourceDir stringByAppendingPathComponent:aFile] toPath:[destinationDir stringByAppendingPathComponent:aFile] error:&error];
        }
        if (error)
            NSLog(@" Error copying font files %@ due to %@", error.localizedDescription, error.localizedFailureReason);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadAllFonts];
}

- (IBAction)boneSwitchAction:(id)sender {
    withRig = (_boneSwitch.isOn) ? true : false;
    [self load3dText];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark Fonts data handling methods

- (void)assetsSet {
    [self performSelectorOnMainThread:@selector(loadAllFonts) withObject:nil waitUntilDone:NO];
}

- (void)loadAllFonts {
    [self resetFontsList];
}

- (void)resetFontsList {
    fontArray = [cache GetAssetList:FONT Search:@""];
    [self.collectionView reloadData];
    if ([fontArray count] > 0) {
        AssetItem* assetItem = fontArray[0];
        fontFileName         = assetItem.name;
        [[AppHelper getAppHelper] saveToUserDefaults:fontFileName withKey:@"Font_Store_Array"];
    }
}

- (void)loadFont:(NSString*)customFontPath withExtension:(NSString*)extension {
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithFilename([customFontPath UTF8String]);

    customFont = CGFontCreateWithDataProvider(fontDataProvider);
    CGDataProviderRelease(fontDataProvider);

    customFontName = (NSString*)CFBridgingRelease(CGFontCopyPostScriptName(customFont));
    CTFontManagerRegisterGraphicsFont(customFont, Nil);
}

#pragma mark CollectionView Delegate methods

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    if (tabValue == FONT_STORE) {
        [_noFontMessageLable setHidden:YES];
        return [fontArray count];
    } else {
        [_noFontMessageLable setHidden:(([fontListArray count]) > 0) ? YES : NO];
        return [fontListArray count];
    }
}

- (TextFrameCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath {
    TextFrameCell* cell        = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    cell.layer.backgroundColor = [UIColor colorWithRed:15 / 255.0 green:15 / 255.0 blue:15 / 255.0 alpha:1].CGColor;

    if (tabValue == FONT_STORE) {
        AssetItem* assetItem = fontArray[indexPath.row];
        cell.fontName.text   = [assetItem.name stringByDeletingPathExtension];
        NSString* fileName   = [NSString stringWithFormat:@"%@/%@", cacheDirectory, assetItem.name];
        if (![[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
            [cell.displayText setHidden:YES];
            [cell.progress setHidden:NO];
            [cell.progress startAnimating];
        } else {
            [self loadFont:fileName withExtension:[fontFileName pathExtension]];
            cell.displayText.font = [UIFont fontWithName:customFontName size:15];
            CGFontRelease(customFont);
            cell.displayText.textColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
            [cell.displayText setHidden:NO];
            [cell.progress stopAnimating];
            [cell.progress setHidden:YES];
        }
        if ([[[AppHelper getAppHelper] userDefaultsForKey:@"Font_Store_Array"] isEqualToString:assetItem.name]) {
            cell.layer.backgroundColor = [UIColor colorWithRed:71.0 / 255.0 green:71.0 / 255.0 blue:71.0 / 255.0 alpha:1.0].CGColor;
        }

    } else {
        cell.fontName.text = [fontListArray[indexPath.row] stringByDeletingPathExtension];
        NSString* fileName = [NSString stringWithFormat:@"%@/%@", fontDirectoryPath, fontListArray[indexPath.row]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
            [cell.displayText setHidden:YES];
            [cell.progress setHidden:NO];
            [cell.progress startAnimating];
        } else {
            [self loadFont:fileName withExtension:[fontFileName pathExtension]];
            cell.displayText.font      = [UIFont fontWithName:customFontName size:15];
            cell.displayText.textColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
            CGFontRelease(customFont);
            [cell.displayText setHidden:NO];
            [cell.progress stopAnimating];
            [cell.progress setHidden:YES];

            if ([fontListArray containsObject:fontFileName]) {
                int index = [fontListArray indexOfObject:fontFileName];
                if (indexPath.row == index)
                    cell.layer.backgroundColor = [UIColor colorWithRed:71.0 / 255.0 green:71.0 / 255.0 blue:71.0 / 255.0 alpha:1.0].CGColor;
            }
        }
    }

    return cell;
}

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath {
    [self.textSelectionDelegate showOrHideProgress:1];
    if (tabValue == MY_FONT || (fontArray != NULL && fontArray.count != 0 && fontArray.count > indexPath.row)) {
        if (tabValue == FONT_STORE) {
            AssetItem* assetItem = fontArray[indexPath.row];
            fontFileName         = assetItem.name;
        } else
            fontFileName = [fontListArray objectAtIndex:indexPath.row];
        [[AppHelper getAppHelper] saveToUserDefaults:fontFileName withKey:@"Font_Store_Array"];
        [self unselectAll];
        UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
        cell.layer.backgroundColor = [UIColor colorWithRed:71.0 / 255.0 green:71.0 / 255.0 blue:71.0 / 255.0 alpha:1.0].CGColor;
        [self load3dText];
    }
}

- (void)unselectAll {
    NSArray* indexPathArr = [self.collectionView indexPathsForVisibleItems];
    for (int i = 0; i < [indexPathArr count]; i++) {
        NSIndexPath*          indexPathValue = [indexPathArr objectAtIndex:i];
        UICollectionViewCell* cell           = [self.collectionView cellForItemAtIndexPath:indexPathValue];
        cell.backgroundColor                 = [UIColor clearColor];
    }
}

- (IBAction)inputTextChangedAction:(id)sender {
    if (isCanceled)
        return NO;
    [self load3dText];
    //    [_inputText resignFirstResponder];
}

- (IBAction)bevalChangeAction:(id)sender {
    [self load3dText];
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string {
    // Prevent crashing undo bug – see note below.
    if (range.length + range.location > textField.text.length) {
        return NO;
    }

    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 160;
}

- (IBAction)fontStoreTapChangeAction:(id)sender {
    if ((int)self.fontTab.selectedSegmentIndex == MY_FONT) {
        [self initializeFontListArray];
        if ([fontArray count] > 0) {
            [self.fontTab setSelectedSegmentIndex:MY_FONT];
            tabValue = MY_FONT;
            [self.collectionView reloadData];
        } else {
            tabValue = MY_FONT;
        }
    } else {
        [self.fontTab setSelectedSegmentIndex:FONT_STORE];
        tabValue = FONT_STORE;
        [self loadAllFonts];
    }
}

- (IBAction)colorPickerAction:(id)sender {
    _textColorProp                              = [[TextColorPicker alloc] initWithNibName:@"TextColorPicker" bundle:nil TextColor:nil];
    _textColorProp.delegate                     = self;
    self.popoverController                      = [[WEPopoverController alloc] initWithContentViewController:_textColorProp];
    self.popoverController.popoverContentSize   = CGSizeMake(200, 200);
    self.popoverController.popoverLayoutMargins = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    self.popoverController.animationType        = WEPopoverAnimationTypeCrossFade;
    [_popUpVc.view setClipsToBounds:YES];
    CGRect rect = _colorWheelbtn.frame;
    rect        = [self.view convertRect:rect fromView:_colorWheelbtn.superview];
    [self.popoverController presentPopoverFromRect:rect
                                            inView:self.view
                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                          animated:NO];
}

- (IBAction)cancelBtnAction:(id)sender {
    isCanceled = true;
    [_inputText resignFirstResponder];
    [_textSelectionDelegate removeTempNodeFromScene];
    [_textSelectionDelegate showOrHideLeftView:NO withView:nil];
    [self.textSelectionDelegate showOrHideProgress:0];
    [self.view removeFromSuperview];
    [self.textSelectionDelegate deallocSubViews];
    [self deallocMem];
}

- (IBAction)addToSceneBtnAction:(id)sender {
    if (fontFileName != nil && ![fontFileName isEqualToString:@""]) {
        [self.textSelectionDelegate showOrHideProgress:1];
        isCanceled         = true;
        Vector4 color      = Vector4(red, green, blue, 1.0);
        float   bevelValue = _bevelSlider.value;

        if (![self.textSelectionDelegate addTempNodeToScene])
            [_textSelectionDelegate load3DTex:(withRig) ? ASSET_TEXT_RIG : ASSET_TEXT AssetId:0 TextureName:@"-1" TypedText:_inputText.text FontSize:DEFAULT_FONT_SIZE BevelValue:bevelValue TextColor:color FontPath:fontFileName isTempNode:NO];
        [_textSelectionDelegate removeTempNodeFromScene];
        [_textSelectionDelegate showOrHideLeftView:NO withView:nil];
        [self.view removeFromSuperview];
        [self.textSelectionDelegate deallocSubViews];
        [self deallocMem];
    }
}

- (void)load3dText {
    if (_inputText.text.length == 0) {
        UIAlertView* loadNodeAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Field Empty", nil) message:NSLocalizedString(@"Please enter some text to add.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
        [loadNodeAlert show];
        [self.textSelectionDelegate showOrHideProgress:0];
        return;
    } else if (fontFileName.length == 0) {
        UIAlertView* loadNodeAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Information", nil) message:NSLocalizedString(@"Please Choose Font Style.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
        [loadNodeAlert show];
        [self.textSelectionDelegate showOrHideProgress:0];
        return;
    }
    Vector4 color      = Vector4(red, green, blue, 1.0);
    float   bevelValue = _bevelSlider.value;
    [_textSelectionDelegate load3DTex:(withRig) ? ASSET_TEXT_RIG : ASSET_TEXT AssetId:0 TextureName:@"-1" TypedText:_inputText.text FontSize:DEFAULT_FONT_SIZE BevelValue:bevelValue TextColor:color FontPath:fontFileName isTempNode:YES];
}

- (void)changeVertexColor:(Vector3)vetexColor dragFinish:(BOOL)isDragFinish {
    red   = vetexColor.x;
    green = vetexColor.y;
    blue  = vetexColor.z;
    [_collectionView reloadData];
    if (isDragFinish)
        [self load3dText];
}

- (void)deallocMem {
    fontListArray          = nil;
    docDirPath             = nil;
    fontArray              = nil;
    fontDirectoryPath      = nil;
    typedText              = nil;
    cacheDirectory         = nil;
    customFontName         = nil;
    fontFileName           = nil;
    cache                  = nil;
    _textSelectionDelegate = nil;
    _inputText.delegate    = nil;
}

@end

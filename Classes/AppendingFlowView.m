//
//  AppendingFlowView.m
//
//  AppendingFlowView by Gregory S. Combs, based on work at https://github.com/grgcombs/AppendingFlowView
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//


#import "AppendingFlowView.h"

/* Convenience methods that don't really belong in a class ... more universal */
CGFloat widthOfViews(NSArray *views) {
	CGFloat totW = 0.f;
	for (UIView *sub in views) {
		totW+= CGRectGetWidth(sub.frame);
	}
	return totW;
}

CGFloat maxHeightOfViews(NSArray *views) {
	CGFloat maxH = 0.f;
	for (UIView *sub in views) {
		maxH = fmax(maxH, CGRectGetHeight(sub.frame));
	}
	return maxH;
}



@interface AppendingFlowView (Private)

- (void)createStageSubviews;

@end

@implementation AppendingFlowView
@synthesize items=items_;
@synthesize stageColors=stageColors_;
@synthesize fontColor, font;
@synthesize connectorSize, preferredBoxSize, insetMargin;
@synthesize uniformWidth, uniformHeight;
@synthesize pendingAlpha;

- (void)configure {
	items_ = nil;
	UIColor *red = [UIColor colorWithRed:0.776f green:0.0f blue:0.184f alpha:1.0];
	UIColor *blue = [UIColor colorWithRed:0.196f green:0.310f blue:0.522f alpha:1.0];
	UIColor *green = [UIColor colorWithRed:0.431f green:0.643f blue:0.063f alpha:1.0];
	//UIColor *gray = [UIColor darkGrayColor];
	
	stageColors_ = [[NSDictionary alloc] initWithObjectsAndKeys:
					red, [NSNumber numberWithInteger:FlowStageFailed],
					blue, [NSNumber numberWithInteger:FlowStagePending],
					green, [NSNumber numberWithInteger:FlowStageReached],
					nil];

	font = [[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.f] retain];
	fontColor = [[UIColor colorWithRed:0.863 green:0.894 blue:0.922 alpha:1.000] retain];	
	
	pendingAlpha = 0.4f;
	connectorSize = CGSizeMake(30.f, 6.f);	// on iphone it's 7px wide, not 30px
	preferredBoxSize = CGSizeMake(96.f, 43.f);	
	insetMargin = CGSizeMake(15.f, 15.f);
	uniformWidth = NO;
	uniformHeight = YES;
	
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		[self configure];
    }
    return self;
}

- (void)awakeFromNib {
	[self configure];
}

- (void)setItems:(NSArray *)newItems {
	if (items_) [items_ release];
	items_ = [newItems copy];

	[self createStageSubviews];
	[self setNeedsLayout];
}

- (UIView *)createConnectorForType:(NSNumber *)statusNumber {
	AppendingFlowStageType statusType = [statusNumber integerValue];
	
	CGRect statusRect = CGRectMake(0.f, 0.f, connectorSize.width, connectorSize.height);	
	if (statusType == FlowStageFailed) {
		statusRect.size.height = 30.f;	// we're doing a symbol, not a box, increase height;
	}
	
	UILabel *statView = [[UILabel alloc] initWithFrame:statusRect];
	statView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin  |
								 UIViewAutoresizingFlexibleRightMargin |
								 UIViewAutoresizingFlexibleBottomMargin);
								 
	statView.alpha = (statusType == FlowStagePending) ? pendingAlpha : 1.f;
	UIColor *statusColor = [stageColors_ objectForKey:statusNumber];
	
	if (statusType == FlowStageFailed) {
		statView.font = font;
		statView.text = @"X";
		statView.shadowColor = [UIColor darkTextColor];
		statView.shadowOffset = CGSizeMake(0.f, -1.f);
		statView.textAlignment = UITextAlignmentCenter;
		statView.adjustsFontSizeToFitWidth = YES;
		statView.textColor = statusColor;
		statView.backgroundColor = [UIColor clearColor];
	} else {
		statView.backgroundColor = statusColor;
	}

	return [statView autorelease];
}

- (UIView *)createStageBoxForTitle:(NSString *)title status:(NSNumber *)statusNumber {
	AppendingFlowStageType statusType = [statusNumber integerValue];

	CGSize frameSize = preferredBoxSize;
	
	if (!uniformWidth || !uniformHeight) {
		// This grabs the appropriate width/height render the text
		frameSize = [title sizeWithFont:font 
							constrainedToSize:preferredBoxSize 
								lineBreakMode:UILineBreakModeWordWrap];
		
		if (uniformHeight) {
			// standardize the height vis a vis rendered height vs. preferred height, across all stages
			frameSize.height = fmax(preferredBoxSize.height, frameSize.height);
			preferredBoxSize.height = frameSize.height;
		}
		
		// padding for text rendered vs. box edges, need a little gap
		frameSize.width += 5.f;	
		if (uniformWidth) {
			// standardize the width vis a vis rendered width vs. preferred width, across all stages
			frameSize.width = fmax(preferredBoxSize.width, frameSize.width);
			preferredBoxSize.width = frameSize.width;
		}
	}
	
	CGRect statusRect = CGRectMake(0.f, 0.f, frameSize.width, frameSize.height);
	
	UIColor *statusColor = [stageColors_ objectForKey:statusNumber];
	UILabel *aView = [[UILabel alloc] initWithFrame:statusRect];
	aView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin  |
								 UIViewAutoresizingFlexibleRightMargin |
								 UIViewAutoresizingFlexibleBottomMargin);
		
	aView.backgroundColor = statusColor;
	aView.text = title;
	aView.numberOfLines = 0;
	aView.minimumFontSize = font.pointSize - 2.f;	// sensible, right?
	aView.textAlignment = UITextAlignmentCenter;
	aView.lineBreakMode = UILineBreakModeWordWrap;
	aView.adjustsFontSizeToFitWidth = YES;
	aView.shadowColor = [UIColor darkTextColor];
	aView.shadowOffset = CGSizeMake(0.f, -1.f);
	aView.textColor = fontColor;
	aView.font = font;
	aView.alpha = (statusType == FlowStagePending) ? pendingAlpha : 1.f;

	return [aView autorelease];
}

- (void)createStageSubviews {	
	// Remove subviews at the very least before we create new ones (or if we need zero)
	NSArray *tempList = [NSArray arrayWithArray:self.subviews];
	for (UIView *sub in tempList) {
		[sub removeFromSuperview];
	}
	
	for (NSDictionary *item in items_) {		
		// dictionary key is our title, it's value is our status
		
		NSString *title = [[item allKeys] objectAtIndex:0]; // assume only one value/key pair
		NSNumber *status = [item valueForKey:title];			
		
		UIView *stageBox = [self createStageBoxForTitle:title status:status];
		[self addSubview:stageBox];
		
		if (NO == [item isEqual:[items_ lastObject]]) {
			UIView *statusView = [self createConnectorForType:status];
			[self addSubview:statusView];
		}
	}
	//[self setNeedsDisplay];
}

- (void)layoutSubviews {
	NSInteger subCount = [self.subviews count];
	if (subCount == 0)
		return;

	// Wrap the change of layout using an animation block to animate the layout changes.
	[UIView beginAnimations:@"rearrange" context:nil];
	[UIView setAnimationDuration:0.5];
		
	NSMutableArray *rows = [[NSMutableArray alloc] init];

	CGFloat masterWidth = CGRectGetWidth(self.bounds) - (insetMargin.width*2);
	
	CGFloat widthAll = widthOfViews(self.subviews);
	if (widthAll <= masterWidth) {
		[rows addObject:self.subviews];
	}
	else { // width of all subviews exceeds our bounds ... break them up into rows
		CGFloat rowWidth = 0.f;
		NSMutableArray *row = [[NSMutableArray alloc] init];
		
		for (UIView *sub in self.subviews) {
			CGFloat subWidth = CGRectGetWidth(sub.frame);
			if ((rowWidth+subWidth) > masterWidth) {
				// we can't fit it on this row, so add our old row to our table, then create a new row
				rowWidth = 0.f;
				[rows addObject:row];
				[row release];
				row = [[NSMutableArray alloc] init];					
			}
			rowWidth+=subWidth;
			[row addObject:sub];	// add the view to our current row
		}
		[rows addObject:row];	// add the row to our table
		[row release];
	}
	
	NSInteger rowCount = MAX(1,[rows count]); // prevent divide by zero in case we screw this up
	
	// resize our master view's height to accomodate subviews+margins (width stays the same)
	CGFloat needsViewHeight = (maxHeightOfViews(self.subviews) + insetMargin.height) * rowCount;	//inset has vertical padding
	CGRect newRect = self.frame;
	newRect = CGRectMake(newRect.origin.x, newRect.origin.y, newRect.size.width, needsViewHeight);
	self.frame = newRect;
	
	CGFloat rowHeight =  CGRectGetHeight(self.bounds) / rowCount;	// get the available height for our rows

	NSInteger rowIndex = 0;
	for (NSArray *row in rows) {
		CGFloat rowWidth = widthOfViews(row);
		CGFloat vOffset = (rowHeight * rowIndex);	// raw starting Y postion for this row
		
		// get the horizontal margins for this row (centers it)
		CGFloat leftOffset = (CGRectGetWidth(self.bounds) - rowWidth) / 2.f;	// don't use master width, it's not *actual*
		
		for (UIView *sub in row) {
			/*
			viewCenterY must be equal to rowCenterY
			so we need the vertical offset from 0.f to this row section plus the center point of the section
			now subtract our (item height / 2) from that value to get the raw origin Y for our view
			*/
			
			CGFloat topOffset = vOffset + (rowHeight/2)	- (CGRectGetHeight(sub.bounds) / 2.f);
			CGRect subFrame = CGRectOffset(sub.bounds, round(leftOffset), round(topOffset));
			sub.frame = subFrame;
			
			leftOffset+= CGRectGetWidth(sub.bounds);	// increment our horizontal offset
		}
		rowIndex++;
	}
	
	[rows release];
		
	[UIView commitAnimations];

	[super layoutSubviews];	// does this add anything?
}

- (void)dealloc {
	self.items = nil;
	self.stageColors = nil;
	self.font = nil;
	self.fontColor = nil;
    [super dealloc];
}


@end
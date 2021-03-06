//
//  GoBoardView.m
//  DGSPhone
//
//  Created by Justin Weiss on 6/5/10.
//  Copyright 2010 Justin Weiss. All rights reserved.
//

#import "GoBoardView.h"
#import "Move.h"
#import <QuartzCore/QuartzCore.h>

#define HANDICAP_MARKER_RADIUS 0.16
#define LAST_MOVE_RADIUS 0.25
#define X_MARKER_RADIUS 0.22
#define STONE_RADIUS 0.52

@interface GoBoardView ()
@property (nonatomic) float pointDistance;
@end

@implementation GoBoardView

- (int)maxX {
	return self.bounds.size.width - _marginX;
}

- (int)maxY {
	return self.bounds.size.height - _marginY;
}

- (int)minX {
	return _marginX;
}

- (int)minY {
	return _marginY;
}

- (CGPoint)pointForBoardRow:(int)row column:(int)col {
	
	float pointDelta = [self pointDistance];
	float pointX = (col - 1) * pointDelta + [self minX];
	float pointY = [self maxY] - ((row - 1) * pointDelta);
	
	// Add 0.5 so we snap to the pixel grid
	return CGPointMake(pointX + 0.5, pointY + 0.5);
}

- (CGPoint)boardPositionForPoint:(CGPoint)point {
	float pointDelta = [self pointDistance];
	float boardX = round((point.x - [self minX]) / pointDelta + 1);
	float boardY = round(([self maxY] - point.y) / pointDelta + 1);
	
	return CGPointMake(boardX, boardY);
}

- (void)drawHandicapMarker:(CGContextRef)context boardSize:(int)boardSize row:(int)row column:(int)column {
	
	CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
	
	CGPoint coords = [self pointForBoardRow:row column:column];
	CGContextBeginPath(context);
	CGContextAddArc(context, coords.x, coords.y, [self pointDistance] * HANDICAP_MARKER_RADIUS, 0, 2*3.14159, 0);
	CGContextFillPath(context);
}

- (void)drawBoardGrid:(CGContextRef)context boardSize:(int)boardSize {
	
	[[UIImage imageNamed:@"Board.png"] drawInRect:[self bounds]];
	
	CGContextSetLineWidth(context, 1.0);
	
	// draw all the lines on the X axis
	for(int i = 1; i <= boardSize; i++) {
		if (i == 1 || i == boardSize) {
			CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
		} else {
			CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.7);
		}
		CGContextBeginPath(context);
		CGPoint startPoint = [self pointForBoardRow:1 column:i];
		CGPoint endPoint = [self pointForBoardRow:boardSize column:i];
		CGContextMoveToPoint(context, startPoint.x, startPoint.y);
		CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
		CGContextStrokePath(context);
	}
	
	// draw all the lines on the Y axis
	for(int i = 1; i <= boardSize; i++) {
		if (i == 1 || i == boardSize) {
			CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
		} else {
			CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.7);
		}
		CGContextBeginPath(context);
		CGPoint startPoint = [self pointForBoardRow:i column:1];
		CGPoint endPoint = [self pointForBoardRow:i column:boardSize];
		CGContextMoveToPoint(context, startPoint.x, startPoint.y);
		CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
		CGContextStrokePath(context);
	}
	
	int half = (boardSize + 1) / 2;
	[self drawHandicapMarker:context boardSize:boardSize row:half column:half];
	
	if (9 <= boardSize) {
		if (13 <= boardSize) {
			[self drawHandicapMarker:context boardSize:boardSize row:4 column:4];
			[self drawHandicapMarker:context boardSize:boardSize row:4 column:(boardSize - 3)];
			[self drawHandicapMarker:context boardSize:boardSize row:(boardSize - 3) column:(boardSize - 3)];
			[self drawHandicapMarker:context boardSize:boardSize row:(boardSize - 3) column:4];
			
			if (19 <= boardSize) {
				[self drawHandicapMarker:context boardSize:boardSize row:half column:4];
				[self drawHandicapMarker:context boardSize:boardSize row:half column:(boardSize - 3)];
				[self drawHandicapMarker:context boardSize:boardSize row:4 column:half];
				[self drawHandicapMarker:context boardSize:boardSize row:(boardSize - 3) column:half];
			}
		} else {
			[self drawHandicapMarker:context boardSize:boardSize row:3 column:3];
			[self drawHandicapMarker:context boardSize:boardSize row:3 column:(boardSize - 2)];
			[self drawHandicapMarker:context boardSize:boardSize row:(boardSize - 2) column:(boardSize - 2)];
			[self drawHandicapMarker:context boardSize:boardSize row:(boardSize - 2) column:3];			
		}
	}
}

- (CGLayerRef)newLayerWithImage:(UIImage *)image context:(CGContextRef)context {
    float scale = [self contentScaleFactor];
    CGRect bounds = CGRectMake(0, 0, image.size.width * scale, image.size.height * scale);
    CGLayerRef layer = CGLayerCreateWithContext(context, bounds.size, NULL);
    CGContextRef layerContext = CGLayerGetContext(layer);
    CGContextScaleCTM(layerContext, 1.0, -1.0);
    CGContextTranslateCTM(layerContext, 0.0, -bounds.size.height);
    CGContextDrawImage(layerContext, CGRectMake(0, 0, bounds.size.width, bounds.size.height), image.CGImage);
    return layer;
}

- (void)drawStonesUsingLayer:(CGContextRef)context {
	NSArray *moves = [self.board moves];
	float stoneRadius = [self pointDistance] * STONE_RADIUS;
	UIImage *blackStoneImage = [UIImage imageNamed:@"Black.png"];
    UIImage *whiteStoneImage = [UIImage imageNamed:@"White.png"];

    CGLayerRef blackStone = [self newLayerWithImage:blackStoneImage context:context];
    CGLayerRef whiteStone = [self newLayerWithImage:whiteStoneImage context:context];
        
	for (Move *move in moves) {
		if ([move moveType] == kMoveTypeMove) {
            CGPoint coords = [self pointForBoardRow:[move row] column:[move col]];
			
			CGRect stoneRect = CGRectMake(coords.x - stoneRadius, coords.y - stoneRadius, stoneRadius * 2, stoneRadius * 2);

			if ([move player] == kMovePlayerBlack) {
                CGContextDrawLayerInRect(context, stoneRect, blackStone);
			} else {
                CGContextDrawLayerInRect(context, stoneRect, whiteStone);
			}
		}
	}
    
    CGLayerRelease(blackStone);
    CGLayerRelease(whiteStone);
}

- (void)drawLastMoveIndicator:(CGContextRef)context {
	Move *move = [self.board currentMove];
	
	if (!move || ([move moveType] != kMoveTypeMove)) {
		return;
	}
	
	CGContextSetLineWidth(context, 2.0);
	
	if ([move player] == kMovePlayerBlack) {
		CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
	} else {
		CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
	}	
	
	CGPoint coords = [self pointForBoardRow:[move row] column:[move col]];
	CGContextBeginPath(context);
	CGContextAddArc(context, coords.x, coords.y, [self pointDistance] * LAST_MOVE_RADIUS, 0, 2*3.14159, 0);
	CGContextStrokePath(context);
}

- (void)drawTerritory:(CGContextRef)context {
	NSArray *territory = [self.board territory];
	CGContextSetLineWidth(context, 2.0);
	
	for (Move *move in territory) {
		if ([move player] == kMovePlayerBlack) {
			CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.3);
		} else if ([move player] == kMovePlayerWhite) {
			CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.3);
		} else {
			CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 0.6);
		}
		
		CGPoint coords = [self pointForBoardRow:[move row] column:[move col]];
		CGContextBeginPath(context);
		
		CGContextAddRect(context, CGRectMake(coords.x - [self pointDistance] * 0.5, coords.y - [self pointDistance] * 0.5, [self pointDistance], [self pointDistance]));
		CGContextFillPath(context);
	}
}

- (void)markDeadStones:(CGContextRef)context {
	NSArray *deadStones = [self.board deadStones];
	CGContextSetLineWidth(context, 2.0);
	
	for (Move *move in deadStones) {
		if ([move player] == kMovePlayerBlack) {
			CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
		} else {
			CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
		}	
		
		CGPoint coords = [self pointForBoardRow:[move row] column:[move col]];
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, coords.x - [self pointDistance] * X_MARKER_RADIUS, coords.y - [self pointDistance] * X_MARKER_RADIUS);
		CGContextAddLineToPoint(context, coords.x + [self pointDistance] * X_MARKER_RADIUS, coords.y + [self pointDistance] * X_MARKER_RADIUS);
		CGContextMoveToPoint(context, coords.x + [self pointDistance] * X_MARKER_RADIUS, coords.y - [self pointDistance] * X_MARKER_RADIUS);
		CGContextAddLineToPoint(context, coords.x - [self pointDistance] * X_MARKER_RADIUS, coords.y + [self pointDistance] * X_MARKER_RADIUS);
		CGContextStrokePath(context);
	}
}

- (void)hideStatusBar {
	if (self.statusView.frame.origin.y >= 0) {
		[GoBoardView animateWithDuration:0.5 animations:^() {
			self.statusView.frame = CGRectMake(self.statusView.frame.origin.x, -self.statusView.frame.size.height, self.statusView.frame.size.width, self.statusView.frame.size.height);
		}];
	}
}

- (void)showStatusBar {
	if (self.statusView.frame.origin.y < 0) {
		[GoBoardView animateWithDuration:0.5 animations:^() {
			self.statusView.frame = CGRectMake(self.statusView.frame.origin.x, 0, self.statusView.frame.size.width, self.statusView.frame.size.height);
		}];
	}
}

- (void)updatePlayerInfo {
	self.status.text = @"";
	[self.blackName setText:[self.board name:kMovePlayerBlack]];
	[self.whiteName setText:[self.board name:kMovePlayerWhite]];
	
	self.blackCaptures.text = [NSString stringWithFormat:@"+%d", [self.board captures:kMovePlayerBlack]];	
	self.whiteCaptures.text = [NSString stringWithFormat:@"+%d", [self.board captures:kMovePlayerWhite]];	
	
	NSString *comment = [self.board comment];
	
	if (![self.board gameEnded]) {
		if ([[[self board] currentMove] moveType] == kMoveTypePass) {
			if ([self.board currentMove].player == kMovePlayerBlack) {
				self.status.text = @"B Pass";
			} else {
				self.status.text = @"W Pass";
			}
		} else if ([[[self board] currentMove] moveType] == kMoveTypeResign) {
			if ([self.board currentMove].player == kMovePlayerBlack) {
				self.status.text = @"B Resign";
			} else {
				self.status.text = @"W Resign";
			}
		} else if (comment) {
			self.status.text = comment;
		}
	} else {
		float score = [self.board score];
		if (score > 0) {
			self.status.text = [NSString stringWithFormat:@"Score: B+%.1f", [self.board score]];
		} else if (score < 0) {
			self.status.text = [NSString stringWithFormat:@"Score: W+%.1f", -1.0 * [self.board score]];
		} else {
			self.status.text = @"Touch groups to mark them as dead";
		}
	}
	
	if (![self.status.text isEqual:@""]) {
		[self showStatusBar];
	} else {
		[self hideStatusBar];
	}
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"BoardView layoutSubviews");
    NSLog(@"BoardView blackName %@", self.blackName);
    NSAssert(self.board, @"The board went away.");
    self.layer.masksToBounds = NO;
    self.layer.shadowOpacity = 0.6;
    self.layer.shadowRadius = 9.0;
    CGPathRef shadowPath = CGPathCreateWithRect(self.bounds, NULL);
    self.layer.shadowPath = shadowPath;
    CGPathRelease(shadowPath);
    self.layer.shadowOffset = CGSizeMake(0.0, 4.0);
}

- (void)drawRect:(CGRect)rect {
    NSLog(@"BoardView drawRect");
    NSLog(@"BoardView blackName %@", self.blackName);
    NSLog(@"Board: %@", self.board);
    // Make sure the board view doesn't go away. This should never happen!
    NSAssert(self.board, @"The board went away.");
    NSAssert(self.blackName, @"Lost the reference to blackName.");
    NSAssert(self.blackCaptures, @"Lost the reference to blackCaptures.");
	// in order to get a nice square board with good margins,
	// we need to make a guess first, then calculate the actual margins based on the
	// point distance we calculate. The reason these are different are due to rounding 
	// errors when we snap the board distance to device pixels.
	_marginX = 50;
	self.pointDistance = 2 * round((float)([self maxX] - [self minX]) / (self.board.size - 1) / 2.0);
	_marginX = (self.bounds.size.width - (self.pointDistance * (self.board.size - 1))) / 2.0;
	_marginY = (self.bounds.size.height - (self.pointDistance * (self.board.size - 1))) / 2.0;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	// Drawing code
	[self drawBoardGrid:context boardSize:[[self board] size]];
    [self drawStonesUsingLayer:context];
    
	if ([self.board gameEnded]) {
		[self markDeadStones:context];
		[self drawTerritory:context];
	} else {
		[self drawLastMoveIndicator:context];
	}
	[self updatePlayerInfo];
}

- (bool)playStoneAtPoint:(CGPoint)point {
    NSLog(@"Here!");
	CGPoint boardPoint = [self boardPositionForPoint:point];
	return [self.board playStoneAtRow:(int)boardPoint.y column:(int)boardPoint.x];
}

- (bool)markDeadStonesAtPoint:(CGPoint)point {
	CGPoint boardPoint = [self boardPositionForPoint:point];
	return [self.board markDeadStonesAtRow:(int)boardPoint.y column:(int)boardPoint.x];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Here!");
	UITouch *touch = [touches anyObject];
	[self.delegate performSelector:@selector(handleGoBoardTouch:inView:) withObject:touch withObject:self];
}

@end

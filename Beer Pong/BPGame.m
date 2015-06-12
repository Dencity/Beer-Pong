//
//  BPGame.m
//  Beer Pong
//
//  Created by Dylan Humphrey on 6/11/15.
//  Copyright (c) 2015 Dylan and Branden. All rights reserved.
//

#import "BPGame.h"

@interface BPGame ()

@end

@implementation BPGame

@dynamic contestants, winner, location, winningFlick, score, shotsMade, shotsMissed, bouncesMade, bouncesMissed, lastCupsMade, islandsMade, rebutlesMade, ballsBack, bombs;

+ (NSString*)parseClassName{
    return @"BPGame";
}

+ (BPGame*)gameWithPlayers:(NSArray *)players{
    BOOL winner = nil;
    PFFile *winningFlick = nil;
    NSString *location = @"";
    NSArray *score = @[[NSNumber numberWithInt:0],[NSNumber numberWithInt:0]];

    //Synthesis all arrays that will be stored
    NSArray *shotsMade = @[[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0]];
    NSArray *shotsMissed = @[[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0]];
    NSArray *bouncesMade = @[[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0]];
    NSArray *bouncesMissed = @[[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0]];
    NSArray *lastCupsMade = @[[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0]];
    NSArray *islandsMade = @[[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0]];
    NSArray *rebutlesMade = @[[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0]];
    
    NSArray *ballsBack = @[[NSNumber numberWithInt:0],[NSNumber numberWithInt:0]];
    NSArray *bombs = @[[NSNumber numberWithInt:0],[NSNumber numberWithInt:0]];
    
    //add it all up to get an object
    BPGame *game = [BPGame object];
    game.contestants = players;
    game.winner = winner;
    game.winningFlick = winningFlick;
    game.score = score;
    game.location = location;
    game.shotsMade = shotsMade;
    game.shotsMissed = shotsMissed;
    game.bouncesMade = bouncesMade;
    game.bouncesMissed = bouncesMissed;
    game.lastCupsMade = lastCupsMade;
    game.islandsMade = islandsMade;
    game.rebutlesMade = rebutlesMade;
    game.ballsBack = ballsBack;
    game.bombs = bombs;
    
    return game;
}

+ (void)gameWithPlayersAtCurrentLocation:(NSArray *)players withCompletion:(completion)completion{
    //make sure the app has access to the location and if it doesnt then just do normal stuff
    if ([CLLocationManager locationServicesEnabled]==NO || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        completion([BPGame gameWithPlayers:players], nil);
    }
    
    //reverse geocode this bitch
    CLLocationManager *manager = [[CLLocationManager alloc]init];
    [manager startUpdatingLocation];
    CLLocation *location = manager.location;
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark *p = placemarks[0];
            NSString *location = p.thoroughfare;
            BPGame *game = [BPGame gameWithPlayers:players];
            game.location = location;
            completion(game, nil);
        }
        else{
            completion([BPGame gameWithPlayers:players], error);
        }
    }];
    
}

#pragma mark - Helper Methods

- (int)totalBouncesTaken:(int)teamNumber{
    NSArray *arr = self.bouncesMade;
    NSArray *arr2 = self.bouncesMissed;
    
    if (teamNumber == 1) {
        int numMade = [arr[0] intValue] + [arr[1] intValue];
        int numMissed = [arr2[0] intValue] + [arr2[1] intValue];
        return numMade + numMissed;
    }
    if (teamNumber == 2) {
        int numMade = [arr[2] intValue] + [arr[3] intValue];
        int numMissed = [arr2[2] intValue] + [arr2[3] intValue];
        return numMade + numMissed;
    }
    
    return 0;
}

- (int)totalShotsForTeam:(int)teamNumber{
    NSArray *arr = self.shotsMade;
    NSArray *arr2 = self.shotsMissed;
    
    if (teamNumber == 1) {
        int numMade = [arr[0] intValue] + [arr[1] intValue];
        int numMissed = [arr2[0] intValue] + [arr2[1] intValue];
        return numMade + numMissed;
    }
    if (teamNumber == 2) {
        int numMade = [arr[2] intValue] + [arr[3] intValue];
        int numMissed = [arr2[2] intValue] + [arr2[3] intValue];
        return numMade + numMissed;
    }
    
    return 0;
}

- (void)incrementShotsMadeForSlot:(int)slot byAmount:(int)amount{
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.shotsMade];
    arr[slot] = [NSNumber numberWithInt:[self.shotsMade[slot] intValue] + amount];
    self.shotsMade = [NSArray arrayWithArray:arr];
    
    //check to see if they just made the last cup
    if ([self.score[0] intValue] == 9 || [self.score[1] intValue] == 9) {
        [self incrementLastCupsMadeForSlot:slot byAmount:amount];
        return;
    }
    
    if (slot < 2) {
        [self setScoreForSlot:1 toAmount:[self.score[0] intValue] + 1];
    }
    else{
        [self setScoreForSlot:0 toAmount:[self.score[1] intValue] + 1];
    }}

- (void)incrementShotsMissedForSlot:(int)slot byAmount:(int)amount{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.shotsMissed];
    arr[slot] = [NSNumber numberWithInt:[self.shotsMissed[slot] intValue] + amount];
    self.shotsMissed = [NSArray arrayWithArray:arr];
}

- (void)incrementBouncesMadeForSlot:(int)slot byAmount:(int)amount{

    [self incrementShotsMadeForSlot:slot byAmount:amount];
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.bouncesMade];
    arr[slot] = [NSNumber numberWithInt:[self.bouncesMade[slot] intValue] + amount];
    self.bouncesMade = [NSArray arrayWithArray:arr];
    
    //check to see if they just made the last cup or last 2
    if ([self.score[0] intValue] == 8 || [self.score[1] intValue] == 8 || [self.score[0] intValue] == 9 || [self.score[1] intValue] == 9) {
        
    }
    if (slot < 2) {
        [self setScoreForSlot:1 toAmount:[self.score[0] intValue] + 2];
    }
    else{
        [self setScoreForSlot:0 toAmount:[self.score[1] intValue] + 2];
    }}

- (void)incrementBouncesMissedForSlot:(int)slot byAmount:(int)amount{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.bouncesMissed];
    arr[slot] = [NSNumber numberWithInt:[self.bouncesMissed[slot] intValue] + amount];
    self.bouncesMissed = [NSArray arrayWithArray:arr];
}

- (void)incrementLastCupsMadeForSlot:(int)slot byAmount:(int)amount{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.lastCupsMade];
    arr[slot] = [NSNumber numberWithInt:[self.lastCupsMade[slot] intValue] + amount];
    self.lastCupsMade = [NSArray arrayWithArray:arr];
}

- (void)incrementIslandsMadeForSlot:(int)slot byAmount:(int)amount{
    //check to see if they just made the last cup or last 2
    if ([self.score[0] intValue] == 8 || [self.score[1] intValue] == 8 || [self.score[0] intValue] == 9 || [self.score[1] intValue] == 9) {
        
    }
    
    [self incrementShotsMadeForSlot:slot byAmount:amount];
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.islandsMade];
    arr[slot] = [NSNumber numberWithInt:[self.islandsMade[slot] intValue] + amount];
    self.islandsMade = [NSArray arrayWithArray:arr];
    
    if (slot < 2) {
        [self setScoreForSlot:1 toAmount:[self.score[0] intValue] + 2];
    }
    else{
        [self setScoreForSlot:0 toAmount:[self.score[1] intValue] + 2];
    }
}

- (void)incrementRebutlesMadeForSlot:(int)slot byAmount:(int)amount{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.rebutlesMade];
    arr[slot] = [NSNumber numberWithInt:[self.rebutlesMade[slot] intValue] + amount];
    self.rebutlesMade = [NSArray arrayWithArray:arr];
    
    if (slot < 2) {
        [self setScoreForSlot:1 toAmount:9];
    }
    else{
        [self setScoreForSlot:0 toAmount:9];
    }
}

- (void)setScoreForSlot:(int)slot toAmount:(int)amount{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.score];
    arr[slot] = [NSNumber numberWithInt:amount];
    self.score = [NSArray arrayWithArray:arr];
}

#pragma mark - Important Data Related Methods

- (void)endGame{
    [self recordPlayerStats];
    if (self.winner) {
        [self saveEventually];
    }
}

- (void)recordPlayerStats{
    
    //pull the data only if necessary
    
    [BPGame fetchAllIfNeededInBackground:self.contestants block:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            //pull individual players out of array
            PFUser *p1 = objects[0];
            PFUser *p2 = objects[1];
            PFUser *p3 = objects[2];
            PFUser *p4 = objects[3];
            
            //increment all stats for all 4 players
            [p1 incrementKey:@"shotsMade" byAmount:self.shotsMade[0]];
            [p2 incrementKey:@"shotsMade" byAmount:self.shotsMade[1]];
            [p3 incrementKey:@"shotsMade" byAmount:self.shotsMade[2]];
            [p4 incrementKey:@"shotsMade" byAmount:self.shotsMade[3]];
            
            [p1 incrementKey:@"shotsMissed" byAmount:self.shotsMissed[0]];
            [p2 incrementKey:@"shotsMissed" byAmount:self.shotsMissed[1]];
            [p3 incrementKey:@"shotsMissed" byAmount:self.shotsMissed[2]];
            [p4 incrementKey:@"shotsMissed" byAmount:self.shotsMissed[3]];

            [p1 incrementKey:@"bouncesMade" byAmount:self.bouncesMade[0]];
            [p2 incrementKey:@"bouncesMade" byAmount:self.bouncesMade[1]];
            [p3 incrementKey:@"bouncesMade" byAmount:self.bouncesMade[2]];
            [p4 incrementKey:@"bouncesMade" byAmount:self.bouncesMade[3]];
            
            [p1 incrementKey:@"bouncesMissed" byAmount:self.bouncesMissed[0]];
            [p2 incrementKey:@"bouncesMissed" byAmount:self.bouncesMissed[1]];
            [p3 incrementKey:@"bouncesMissed" byAmount:self.bouncesMissed[2]];
            [p4 incrementKey:@"bouncesMissed" byAmount:self.bouncesMissed[3]];

            [p1 incrementKey:@"lastCupsMade" byAmount:self.lastCupsMade[0]];
            [p2 incrementKey:@"lastCupsMade" byAmount:self.lastCupsMade[1]];
            [p3 incrementKey:@"lastCupsMade" byAmount:self.lastCupsMade[2]];
            [p4 incrementKey:@"lastCupsMade" byAmount:self.lastCupsMade[3]];

            [p1 incrementKey:@"islandsMade" byAmount:self.islandsMade[0]];
            [p2 incrementKey:@"islandsMade" byAmount:self.islandsMade[1]];
            [p3 incrementKey:@"islandsMade" byAmount:self.islandsMade[2]];
            [p4 incrementKey:@"islandsMade" byAmount:self.islandsMade[3]];

            [p1 incrementKey:@"rebutlesMade" byAmount:self.rebutlesMade[0]];
            [p2 incrementKey:@"rebutlesMade" byAmount:self.rebutlesMade[1]];
            [p3 incrementKey:@"rebutlesMade" byAmount:self.rebutlesMade[2]];
            [p4 incrementKey:@"rebutlesMade" byAmount:self.rebutlesMade[3]];

            if (self.winner == YES) {
                [p1 incrementKey:@"wins"];
                [p2 incrementKey:@"wins"];
                [p3 incrementKey:@"losses"];
                [p4 incrementKey:@"losses"];
            }
            else if (self.winner == NO){
                [p1 incrementKey:@"losses"];
                [p2 incrementKey:@"losses"];
                [p3 incrementKey:@"wins"];
                [p4 incrementKey:@"wins"];
            }
            
            [p1 saveEventually];
            [p2 saveEventually];
            [p3 saveEventually];
            [p4 saveEventually];

        }
    }];
}

#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    [manager stopUpdatingLocation];
}

@end

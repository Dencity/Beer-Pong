//
//  BPGame.h
//  Beer Pong
//
//  Created by Dylan Humphrey on 6/11/15.
//  Copyright (c) 2015 Dylan and Branden. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import <CoreLocation/CoreLocation.h>

@interface BPGame : PFObject <PFSubclassing, CLLocationManagerDelegate>

typedef void (^completion)(BPGame *game, NSError *error);

/* This property will store all the contestants of the game
 * Player 1 and Player 2 are on the same team and vice versa for player 3 and 4
 ie. [Player 1, Player 2, Player 3, Player 4]
 */
@property (retain) NSArray *contestants;

/* This property will only be set once the game is finished
 * Case 1 (True) -> Team 1 is winner
 * Case 2 (False) -> Team 2 is winner
 */
@property (nonatomic) BOOL winner;

/* This property will hold the location of the game
 * Is actually just a string that states the name of the location
 * All reverse geocoding takes place on creation of game if proper
 method is called
 */

@property (retain) NSString *location;

/* This property is a PFFile but is actually an image
 * The image is an image taken by the winning team and will act as a
 thumbnail for the game
 */

@property (retain) PFFile *winningFlick;

/* This property will keep track of the score for each team
 * Will be an array of size 2, one slot for each team
 * Each team starts with 0 points in each slot
 * The score will increase by a number depending on the shot if 
 a player makes a shot (ya know normal beeps)
 * Winner is first one to 10 with no rebutles remaining for the other
 team (havent figured out how to track this but shouldnt be too hard)
 &
 * Score will be changed whenever the increment methods are called (they are down a little)
 ** It will be changed depending on the changes in shots made and bounces and stuff
 */

@property (retain) NSArray *score;

/* These will just be all of the statistics that should be kept with the game
 * Player 1 and 2 are always on team 1 and Player 3 and 4 are always on team 2
 * All stats will be stored in a array with 4 places
 ie. Shots made object will be a array with 4 places where 0 index refers to
 player 1's shots made and 1 index refers to player 2's shots made and so on
 * @info - This section is for individual player stats kept tract in the game
 */

@property (retain) NSArray *shotsMade;
@property (retain) NSArray *shotsMissed;
@property (retain) NSArray *bouncesMade;
@property (retain) NSArray *bouncesMissed;
@property (retain) NSArray *lastCupsMade;
@property (retain) NSArray *islandsMade;
@property (retain) NSArray *rebutlesMade;

/* These will be all team statistics kept during the game
 * Do not relate to any individual player, just each seperate team
 * Like above, each object will be an array but instea of 4 places
 each object will have 2 plaes (one for each team)
 */

@property (retain) NSArray *ballsBack;
@property (retain) NSArray *bombs;

+(NSString*)parseClassName;

/* Now for all the methods
 * Alot will be simple methods that just add up certain game stats from above
 * ie. Total team shots will be a method that just adds up the shots made and shots missed
 from above
 * Take note that these methods will not call any data from parse but will use
 the phones processor to add numbers from the already downloaded data
 * @warning - Make sure that data is downloaded before calling any method
 */

- (int)totalShotsForTeam:(int)teamNumber;
- (int)totalBouncesTaken:(int)teamNumber;

/* All these next methods are just simple helper methods
 * They make life easier by allowing quick access to changing values in the arrays
 */

- (void)incrementShotsMadeForSlot:(int)slot byAmount:(int)amount;
- (void)incrementShotsMissedForSlot:(int)slot byAmount:(int)amount;
- (void)incrementBouncesMadeForSlot:(int)slot byAmount:(int)amount;
- (void)incrementBouncesMissedForSlot:(int)slot byAmount:(int)amount;
- (void)incrementLastCupsMadeForSlot:(int)slot byAmount:(int)amount;
- (void)incrementIslandsMadeForSlot:(int)slot byAmount:(int)amount;
- (void)incrementRebutlesMadeForSlot:(int)slot byAmount:(int)amount;
- (void)updateScore;

/* Class method that will return a BPGame object with all arrays initialized
 * This method should be called once all players have been invited and have accepted
 * This method does not record the location of the game
 * @param players - an array of all 4 players in a specific order such as
 [Player 1, Player 2, Player 3, Player 4] where player 1 and 2 are on the same team and 
 vice versa
 */

+ (BPGame*)gameWithPlayers:(NSArray*)players;

/* Same method as above just attaches current location to game as well
 * Called in a completion block because reverse geocoding takes an unknown
 amount of time so object cant be returned until that process is completed
 * Only way around this is, yep you guessed it, passing the BPGame object through
 a completion block that waits for the reverse geocode to finish
 */

+ (void)gameWithPlayersAtCurrentLocation:(NSArray *)players withCompletion:(completion)completion;

/* Method called that ends the game and saves everything to the database
 * Also records all individual player stats and saves them to their profiles
 */

- (void)endGame;

@end

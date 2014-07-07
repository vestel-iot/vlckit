/*****************************************************************************
 * VLCTime.m: VLCKit.framework VLCTime implementation
 *****************************************************************************
 * Copyright (C) 2007 Pierre d'Herbemont
 * Copyright (C) 2007 VLC authors and VideoLAN
 * $Id$
 *
 * Authors: Pierre d'Herbemont <pdherbemont # videolan.org>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

#import "VLCTime.h"

@implementation VLCTime

/* Factories */
+ (VLCTime *)nullTime
{
    static VLCTime * nullTime = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nullTime = [VLCTime timeWithNumber:nil];
    });
    return nullTime;
}

+ (VLCTime *)timeWithNumber:(NSNumber *)aNumber
{
    return [[VLCTime alloc] initWithNumber:aNumber];
}

+ (VLCTime *)timeWithInt:(int)aInt
{
    return [[VLCTime alloc] initWithInt:aInt];
}

/* Initializers */
- (id)initWithNumber:(NSNumber *)aNumber
{
    if (self = [super init]) {
        if (aNumber)
            value = [aNumber copy];
        else
            value = nil;
    }
    return self;
}

- (id)initWithInt:(int)aInt
{
    if (self = [super init]) {
        if (aInt)
            value = @(aInt);
        else
            value = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[VLCTime alloc] initWithNumber:value];
}

/* NSObject Overrides */
- (NSString *)description
{
    return self.stringValue;
}

/* Operations */
- (NSNumber *)numberValue
{
    return value ? [value copy] : nil;
}

- (NSString *)stringValue
{
    if (value) {
        long long duration = [value longLongValue] / 1000;
        long long positiveDuration = llabs(duration);
        if (positiveDuration > 3600)
            return [NSString stringWithFormat:@"%s%01ld:%02ld:%02ld",
                        duration < 0 ? "-" : "",
                (long) (positiveDuration / 3600),
                (long)((positiveDuration / 60) % 60),
                (long) (positiveDuration % 60)];
        else
            return [NSString stringWithFormat:@"%s%02ld:%02ld",
                            duration < 0 ? "-" : "",
                    (long)((positiveDuration / 60) % 60),
                    (long) (positiveDuration % 60)];
    } else {
        // Return a string that represents an undefined time.
        return @"--:--";
    }
}

- (NSString *)verboseStringValue
{
    if (value) {
        long long duration = [value longLongValue] / 1000;
        long long positiveDuration = llabs(duration);
        long hours = positiveDuration / 3600;
        long mins = (positiveDuration / 60) % 60;
        long seconds = positiveDuration % 60;
        const char * remaining = duration < 0 ? " remaining" : "";
        if (hours > 0)
            return [NSString stringWithFormat:@"%ld hours %ld minutes%s", hours, mins, remaining];
        else if (mins > 5)
            return [NSString stringWithFormat:@"%ld minutes%s", mins, remaining];
        else if (mins > 0)
            return [NSString stringWithFormat:@"%ld minutes %ld seconds%s", mins, seconds, remaining];
        else
            return [NSString stringWithFormat:@"%ld seconds%s", seconds, remaining];
    } else {
        // Return a string that represents an undefined time.
        return @"";
    }
}

- (NSString *)minuteStringValue
{
    if (value) {
        long long positiveDuration = llabs([value longLongValue]);
        long minutes = positiveDuration / 60000;
        return [NSString stringWithFormat:@"%ld", minutes];
    }
    return @"";
}

- (int)intValue
{
    if (value)
        return [value intValue];
    return 0;
}

- (NSComparisonResult)compare:(VLCTime *)aTime
{
    if (!aTime && !value)
        return NSOrderedSame;
    else if (!aTime)
        return NSOrderedDescending;
    else
        return [value compare:aTime.numberValue];
}
@end

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TTTCDUnifiedRecord.m instead.

#import "_TTTCDUnifiedRecord.h"

const struct TTTCDUnifiedRecordAttributes TTTCDUnifiedRecordAttributes = {
	.position = @"position",
	.recordID = @"recordID",
	.sortFieldFirstName = @"sortFieldFirstName",
	.sortFieldLastName = @"sortFieldLastName",
};

const struct TTTCDUnifiedRecordRelationships TTTCDUnifiedRecordRelationships = {
	.linkedRecord = @"linkedRecord",
};

const struct TTTCDUnifiedRecordFetchedProperties TTTCDUnifiedRecordFetchedProperties = {
};

@implementation TTTCDUnifiedRecordID
@end

@implementation _TTTCDUnifiedRecord

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UnifiedRecord" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UnifiedRecord";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UnifiedRecord" inManagedObjectContext:moc_];
}

- (TTTCDUnifiedRecordID*)objectID {
	return (TTTCDUnifiedRecordID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"positionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"position"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"recordIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"recordID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic position;



- (float)positionValue {
	NSNumber *result = [self position];
	return [result floatValue];
}

- (void)setPositionValue:(float)value_ {
	[self setPosition:[NSNumber numberWithFloat:value_]];
}

- (float)primitivePositionValue {
	NSNumber *result = [self primitivePosition];
	return [result floatValue];
}

- (void)setPrimitivePositionValue:(float)value_ {
	[self setPrimitivePosition:[NSNumber numberWithFloat:value_]];
}





@dynamic recordID;



- (int32_t)recordIDValue {
	NSNumber *result = [self recordID];
	return [result intValue];
}

- (void)setRecordIDValue:(int32_t)value_ {
	[self setRecordID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveRecordIDValue {
	NSNumber *result = [self primitiveRecordID];
	return [result intValue];
}

- (void)setPrimitiveRecordIDValue:(int32_t)value_ {
	[self setPrimitiveRecordID:[NSNumber numberWithInt:value_]];
}





@dynamic sortFieldFirstName;






@dynamic sortFieldLastName;






@dynamic linkedRecord;

	
- (NSMutableSet*)linkedRecordSet {
	[self willAccessValueForKey:@"linkedRecord"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"linkedRecord"];
  
	[self didAccessValueForKey:@"linkedRecord"];
	return result;
}
	






@end

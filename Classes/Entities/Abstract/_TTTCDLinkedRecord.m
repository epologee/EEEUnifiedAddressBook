// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TTTCDLinkedRecord.m instead.

#import "_TTTCDLinkedRecord.h"

const struct TTTCDLinkedRecordAttributes TTTCDLinkedRecordAttributes = {
	.recordID = @"recordID",
};

const struct TTTCDLinkedRecordRelationships TTTCDLinkedRecordRelationships = {
	.unifiedRecord = @"unifiedRecord",
};

const struct TTTCDLinkedRecordFetchedProperties TTTCDLinkedRecordFetchedProperties = {
};

@implementation TTTCDLinkedRecordID
@end

@implementation _TTTCDLinkedRecord

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"LinkedRecord" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"LinkedRecord";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"LinkedRecord" inManagedObjectContext:moc_];
}

- (TTTCDLinkedRecordID*)objectID {
	return (TTTCDLinkedRecordID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"recordIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"recordID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
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





@dynamic unifiedRecord;

	






@end

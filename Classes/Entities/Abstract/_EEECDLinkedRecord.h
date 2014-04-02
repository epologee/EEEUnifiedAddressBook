// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to EEECDLinkedRecord.h instead.

#import <CoreData/CoreData.h>


extern const struct EEECDLinkedRecordAttributes {
	__unsafe_unretained NSString *recordID;
} EEECDLinkedRecordAttributes;

extern const struct EEECDLinkedRecordRelationships {
	__unsafe_unretained NSString *unifiedRecord;
} EEECDLinkedRecordRelationships;

extern const struct EEECDLinkedRecordFetchedProperties {
} EEECDLinkedRecordFetchedProperties;

@class EEECDUnifiedRecord;



@interface EEECDLinkedRecordID : NSManagedObjectID {}
@end

@interface _EEECDLinkedRecord : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (EEECDLinkedRecordID*)objectID;





@property (nonatomic, strong) NSNumber* recordID;



@property int32_t recordIDValue;
- (int32_t)recordIDValue;
- (void)setRecordIDValue:(int32_t)value_;

//- (BOOL)validateRecordID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) EEECDUnifiedRecord *unifiedRecord;

//- (BOOL)validateUnifiedRecord:(id*)value_ error:(NSError**)error_;





@end

@interface _EEECDLinkedRecord (CoreDataGeneratedAccessors)

@end

@interface _EEECDLinkedRecord (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveRecordID;
- (void)setPrimitiveRecordID:(NSNumber*)value;

- (int32_t)primitiveRecordIDValue;
- (void)setPrimitiveRecordIDValue:(int32_t)value_;





- (EEECDUnifiedRecord*)primitiveUnifiedRecord;
- (void)setPrimitiveUnifiedRecord:(EEECDUnifiedRecord*)value;


@end

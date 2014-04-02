// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to EEECDUnifiedRecord.h instead.

#import <CoreData/CoreData.h>


extern const struct EEECDUnifiedRecordAttributes {
	__unsafe_unretained NSString *position;
	__unsafe_unretained NSString *recordID;
	__unsafe_unretained NSString *sortFieldFirstName;
	__unsafe_unretained NSString *sortFieldLastName;
} EEECDUnifiedRecordAttributes;

extern const struct EEECDUnifiedRecordRelationships {
	__unsafe_unretained NSString *linkedRecord;
} EEECDUnifiedRecordRelationships;

extern const struct EEECDUnifiedRecordFetchedProperties {
} EEECDUnifiedRecordFetchedProperties;

@class EEECDLinkedRecord;






@interface EEECDUnifiedRecordID : NSManagedObjectID {}
@end

@interface _EEECDUnifiedRecord : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (EEECDUnifiedRecordID*)objectID;





@property (nonatomic, strong) NSNumber* position;



@property float positionValue;
- (float)positionValue;
- (void)setPositionValue:(float)value_;

//- (BOOL)validatePosition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* recordID;



@property int32_t recordIDValue;
- (int32_t)recordIDValue;
- (void)setRecordIDValue:(int32_t)value_;

//- (BOOL)validateRecordID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* sortFieldFirstName;



//- (BOOL)validateSortFieldFirstName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* sortFieldLastName;



//- (BOOL)validateSortFieldLastName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *linkedRecord;

- (NSMutableSet*)linkedRecordSet;





@end

@interface _EEECDUnifiedRecord (CoreDataGeneratedAccessors)

- (void)addLinkedRecord:(NSSet*)value_;
- (void)removeLinkedRecord:(NSSet*)value_;
- (void)addLinkedRecordObject:(EEECDLinkedRecord*)value_;
- (void)removeLinkedRecordObject:(EEECDLinkedRecord*)value_;

@end

@interface _EEECDUnifiedRecord (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitivePosition;
- (void)setPrimitivePosition:(NSNumber*)value;

- (float)primitivePositionValue;
- (void)setPrimitivePositionValue:(float)value_;




- (NSNumber*)primitiveRecordID;
- (void)setPrimitiveRecordID:(NSNumber*)value;

- (int32_t)primitiveRecordIDValue;
- (void)setPrimitiveRecordIDValue:(int32_t)value_;




- (NSString*)primitiveSortFieldFirstName;
- (void)setPrimitiveSortFieldFirstName:(NSString*)value;




- (NSString*)primitiveSortFieldLastName;
- (void)setPrimitiveSortFieldLastName:(NSString*)value;





- (NSMutableSet*)primitiveLinkedRecord;
- (void)setPrimitiveLinkedRecord:(NSMutableSet*)value;


@end

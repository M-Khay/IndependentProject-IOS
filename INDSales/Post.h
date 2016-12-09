//
//  Post.h
//  INDSales
//
//////  Created by Kush on 13/11/16.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject

@property(nonatomic, strong) NSString*topic_id;
@property(nonatomic, strong) NSString*client_id;
@property(nonatomic, strong) NSString*posted_by;
@property(nonatomic, strong) NSString*topic;
@property(nonatomic, strong) NSString*createddate;
@property(nonatomic, strong) NSString*category;
@property(nonatomic, strong) NSMutableArray*responses;

@end

/*

[{"topic_id":"920587","client_id":"800203","posted_by":"testuser","topic":"Test in BLRDEV","createddate":"2014-02-24","responses":[{"response_by":"null","response":"null","response_date":"null"}]},{"topic_id":"920586","client_id":"800203","posted_by":"testuser","topic":"A test Post","createddate":"2014-02-24","responses":[{"response_by":"null","response":"null","response_date":"null"}]},{"topic_id":"920585","client_id":"800203","posted_by":"testuser","topic":"A test Post","createddate":"2014-02-24","responses":[{"response_by":"testuser","response":"my fifth response","response_date":"2014-02-24"},{"response_by":"testuser","response":"my fourth response","response_date":"2014-02-24"},{"response_by":"testuser","response":"my third response","response_date":"2014-02-24"},{"response_by":"testuser","response":"my third response","response_date":"2014-02-24"},{"response_by":"testuser","response":"my third response","response_date":"2014-02-24"},{"response_by":"testuser","response":"my second response","response_date":"2014-02-24"}]},{"topic_id":"920584","client_id":"800203","posted_by":"testuser","topic":"A test Post","createddate":"2014-02-24","responses":[{"response_by":"testuser","response":"my response","response_date":"2014-02-24"}]},{"topic_id":"920583","client_id":"800203","posted_by":"test2","topic":"Test Post","createddate":"2014-02-24","responses":[{"response_by":"test","response":"test response3","response_date":"2014-02-24"},{"response_by":"test","response":"test response2","response_date":"2014-02-24"},{"response_by":"test","response":"test response","response_date":"2014-02-24"}]},{"topic_id":"920582","client_id":"800203","posted_by":"test","topic":"Test Post","createddate":"2014-02-24","responses":[{"response_by":"test","response":"test response","response_date":"2014-02-24"}]}]
*/
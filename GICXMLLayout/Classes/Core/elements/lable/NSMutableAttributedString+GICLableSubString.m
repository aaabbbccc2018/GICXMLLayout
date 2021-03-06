//
//  NSMutableAttributedString+GICLableSubString.m
//  GICXMLLayout
//
//  Created by 龚海伟 on 2018/7/3.
//

#import "NSMutableAttributedString+GICLableSubString.h"
#import "NSObject+LayoutElement.h"
#import "GDataXMLNode.h"
#import "GICNumberConverter.h"
#import "GICColorConverter.h"
#import "GICStringConverter.h"
#import "GICFontConverter.h"
#import "GICURLConverter.h"
#import <objc/runtime.h>

#define kLinkAttributeName @"GIClink"

@implementation NSMutableAttributedString (GICLableSubString)

-(void)setGic_attributDict:(NSMutableDictionary *)gic_attributDict{
    objc_setAssociatedObject(self, "gic_attributDict", gic_attributDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableDictionary *)gic_attributDict{
    return objc_getAssociatedObject(self, "gic_attributDict");
}

-(BOOL)gic_isImg{
    return [objc_getAssociatedObject(self, "gic_isImg") boolValue];
}

static NSDictionary<NSString *,GICAttributeValueConverter *> *propertyConverts = nil;
+(void)initialize{
    propertyConverts = @{
                         @"font-color":[[GICColorConverter alloc] initWithPropertySetter:^(NSObject *target, id value) {
                             NSMutableAttributedString *str = (NSMutableAttributedString *)target;
                             [str.gic_attributDict setValue:value forKey:NSForegroundColorAttributeName];
                             [str.gic_getSuperElement gic_setNeedDisplay];
                         } withGetter:^id(id target) {
                             NSMutableAttributedString *str = (NSMutableAttributedString *)target;
                             return [str.gic_attributDict objectForKey:NSForegroundColorAttributeName];
                         }],
                         @"font-size":[[GICNumberConverter alloc] initWithPropertySetter:^(NSObject *target, id value) {
                             NSMutableAttributedString *str = (NSMutableAttributedString *)target;
                             [str.gic_attributDict setValue:[UIFont systemFontOfSize:[value floatValue]] forKey:NSFontAttributeName];
                             [str.gic_getSuperElement gic_setNeedDisplay];
                         }],
                         @"font":[[GICFontConverter alloc] initWithPropertySetter:^(NSObject *target, id value) {
                             NSMutableAttributedString *str = (NSMutableAttributedString *)target;
                             [str.gic_attributDict setValue:value forKey:NSFontAttributeName];
                             [str.gic_getSuperElement gic_setNeedDisplay];
                         }],
                         @"background-color":[[GICColorConverter alloc] initWithPropertySetter:^(NSObject *target, id value) {
                             NSMutableAttributedString *str = (NSMutableAttributedString *)target;
                             [str.gic_attributDict setValue:value forKey:NSBackgroundColorAttributeName];
                             [str.gic_getSuperElement gic_setNeedDisplay];
                         } withGetter:^id(id target) {
                             NSMutableAttributedString *str = (NSMutableAttributedString *)target;
                             return [str.gic_attributDict objectForKey:NSBackgroundColorAttributeName];
                         }],
                         @"img-name":[[GICStringConverter alloc] initWithPropertySetter:^(NSObject *target, id value) {
                             NSMutableAttributedString *str = (NSMutableAttributedString *)target;
                             NSTextAttachment * textAttachment = [[NSTextAttachment alloc ] initWithData:nil ofType:nil];
                             textAttachment.image = [UIImage imageNamed:value];
                             NSAttributedString *attImage=[NSAttributedString attributedStringWithAttachment:textAttachment];
                             [str appendAttributedString:attImage];
                             [str.gic_getSuperElement gic_setNeedDisplay];
                         }],
                         @"text":[[GICStringConverter alloc] initWithPropertySetter:^(NSObject *target, id value) {
                             NSMutableAttributedString *str = (NSMutableAttributedString *)target;
                             [str deleteCharactersInRange:NSMakeRange(0, str.length)];
                             [str appendAttributedString:[[NSAttributedString alloc] initWithString:value]];
                             [str.gic_getSuperElement gic_setNeedDisplay];
                         } withGetter:^id(id target) {
                             NSMutableAttributedString *str = (NSMutableAttributedString *)target;
                             return [str string];
                         }],
                         @"link":[[GICURLConverter alloc] initWithPropertySetter:^(NSObject *target, id value) {
                             NSMutableAttributedString *str = (NSMutableAttributedString *)target;
                             [str.gic_attributDict setValue:value forKey:kLinkAttributeName];
                             [str.gic_attributDict setValue:value forKey:[(NSURL *)value absoluteString]];
                             [str.gic_getSuperElement gic_setNeedDisplay];
                         } withGetter:^id(id target) {
                             NSMutableAttributedString *str = (NSMutableAttributedString *)target;
                             return [str.gic_attributDict objectForKey:NSLinkAttributeName];
                         }],
                         @"underline-style":[[GICNumberConverter alloc] initWithPropertySetter:^(NSObject *target, id value) {
                             NSMutableAttributedString *str = (NSMutableAttributedString *)target;
                             [str.gic_attributDict setValue:value forKey:NSUnderlineStyleAttributeName];
                             [str.gic_getSuperElement gic_setNeedDisplay];
                         } withGetter:^id(id target) {
                             NSMutableAttributedString *str = (NSMutableAttributedString *)target;
                             return [str.gic_attributDict objectForKey:NSUnderlineStyleAttributeName];
                         }],
                         @"throughline-style":[[GICNumberConverter alloc] initWithPropertySetter:^(NSObject *target, id value) {
                             NSMutableAttributedString *str = (NSMutableAttributedString *)target;
                             [str.gic_attributDict setValue:value forKey:NSStrikethroughStyleAttributeName];
                             [str.gic_getSuperElement gic_setNeedDisplay];
                         } withGetter:^id(id target) {
                             NSMutableAttributedString *str = (NSMutableAttributedString *)target;
                             return [str.gic_attributDict objectForKey:NSStrikethroughStyleAttributeName];
                         }],
                         @"line-space":[[GICNumberConverter alloc] initWithPropertySetter:^(NSObject *target, id value) {
                             NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                             [paragraphStyle setLineSpacing:[value integerValue]];//行间距
                             NSMutableAttributedString *str = (NSMutableAttributedString *)target;
                             [str.gic_attributDict setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
                             [str.gic_getSuperElement gic_setNeedDisplay];
                         } withGetter:^id(id target) {
                             NSMutableAttributedString *str = (NSMutableAttributedString *)target;
                             return @([(NSMutableParagraphStyle *)[str.gic_attributDict objectForKey:NSParagraphStyleAttributeName] lineSpacing]);
                         }],
                         };
}


+(NSDictionary<NSString *,GICAttributeValueConverter *> *)gic_elementAttributs{
    return propertyConverts;
}

-(id)initWithXmlElement:(GDataXMLElement *)xmlElement{
    if([xmlElement.name isEqualToString:@"img"]){
        self = [self init];
        objc_setAssociatedObject(self, "gic_isImg", @(true), OBJC_ASSOCIATION_ASSIGN);
    }else{
        NSString *text = [xmlElement stringValueOrginal];
        self = [self initWithString:text];
    }
    self.gic_attributDict = [NSMutableDictionary dictionary];
    return self;
}

-(NSURL *)gic_linkUrl{
    return [self.gic_attributDict objectForKey:kLinkAttributeName];
}
@end

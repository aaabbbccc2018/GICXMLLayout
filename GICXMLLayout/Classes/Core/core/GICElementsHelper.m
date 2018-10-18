//
//  GICElementsHelper.m
//  GICXMLLayout
//
//  Created by 龚海伟 on 2018/8/7.
//

#import "GICElementsHelper.h"

@implementation GICElementsHelper
+(id)findSubElementFromSuperElement:(id)superElment withName:(NSString *)name{
    if(!superElment)
        return nil;
    id findEl = nil;
    for(NSObject *obj in [superElment gic_subElements]){
        if([obj.gic_ExtensionProperties.name isEqualToString:name]){
            findEl = obj;
            break;
        }
    }
    for(GICBehavior *obj in [superElment gic_Behaviors].behaviors){
        if([obj.gic_ExtensionProperties.name isEqualToString:name]){
            findEl = obj;
            break;
        }
    }
    
    if(findEl==nil){
        for(NSObject *obj in [superElment gic_subElements]){
            findEl = [GICElementsHelper findSubElementFromSuperElement:obj withName:name];
            if(findEl){
                break;
            }
        }
    }
    return findEl;
}

+(NSArray *)findSubElementsFromSuperElement:(id)superElment withName:(NSString *)name{
    if(!superElment)
        return nil;
    NSMutableArray *mutArrary = [NSMutableArray array];
    for(NSObject *obj in [superElment gic_subElements]){
        if([obj.gic_ExtensionProperties.name isEqualToString:name]){
            [mutArrary addObject:obj];
        }
    }
    for(GICBehavior *obj in [superElment gic_Behaviors].behaviors){
        if([obj.gic_ExtensionProperties.name isEqualToString:name]){
            [mutArrary addObject:obj];
        }
    }
    
    for(NSObject *obj in [superElment gic_subElements]){
        [mutArrary addObjectsFromArray:[GICElementsHelper findSubElementsFromSuperElement:obj withName:name]];
    }
    return mutArrary;
}

+(id)findElementFromViewModel:(id)viewModel withName:(NSString *)name{
    return [GICElementsHelper findSubElementFromSuperElement:[viewModel gic_ExtensionProperties].superElement withName:name];
}
@end

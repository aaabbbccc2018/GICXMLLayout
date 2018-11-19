//
//  GICDirectiveFor.m
//  GICXMLLayout
//
//  Created by 龚海伟 on 2018/7/6.
//

#import "GICDirectiveFor.h"
#import "NSObject+GICDataBinding.h"
#import "NSObject+GICDataContext.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "GICTemplateRef.h"
#import "GICDataContext+JavaScriptExtension.h"
#import "JSValue+GICJSExtension.h"

@implementation GICDirectiveFor
+(NSString *)gic_elementName{
    return @"for";
}

-(void)gic_parseSubElements:(NSArray<GDataXMLElement *> *)children{
    if(children.count==1){
        self->xmlDoc =  [[GDataXMLDocument alloc] initWithXMLString:children[0].XMLString options:0 error:nil];
    }
}

-(BOOL)gic_parseOnlyOneSubElement{
    return YES;
}

-(void)gic_updateDataContext:(id)superDataContenxt{
    [super gic_updateDataContext:superDataContenxt];
    if([superDataContenxt isKindOfClass:[JSManagedValue class]]){
        JSManagedValue *jsValue = superDataContenxt;
        if([self gic_dataPathKey] && [jsValue.value isObject]){ //以防array 无法获取value
            JSValue *pathValue = jsValue.value[[self gic_dataPathKey]];
            jsValue = [pathValue gic_ToManagedValue:self];
        }
        [self updateDataSourceFromJsValue:jsValue];
    }else{
       [self updateDataSource:[self gic_DataContext]];
    }
}

-(void)updateDataSource:(id)dataSource{
    [self removeAllItems];
    if([dataSource isKindOfClass:[NSArray class]] && [self.target respondsToSelector:@selector(gic_addSubElement:)]){
        
        [dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addAElement:obj index:idx];
        }];
        
        if([dataSource isKindOfClass:[NSMutableArray class]]){
            // 监听添加对象事件
            @weakify(self)
            [[dataSource rac_signalForSelector:@selector(addObject:)] subscribeNext:^(RACTuple * _Nullable x) {
                @strongify(self)
                [self addAElement:x[0] index:[dataSource indexOfObject:x[0]]];
            }];
            
            [[dataSource rac_signalForSelector:@selector(addObjectsFromArray:)] subscribeNext:^(RACTuple * _Nullable x) {
                @strongify(self)
                for(id data in x[0]){
                    [self addAElement:data index:[dataSource indexOfObject:data]];
                }
            }];
            
            // 插入
            [[dataSource rac_signalForSelector:@selector(insertObject:atIndex:)] subscribeNext:^(RACTuple * _Nullable x) {
                @strongify(self)
                [self insertAElement:x[0] index:[dataSource indexOfObject:x[0]]];
            }];
            
            // 监听删除对象事件
            [[dataSource rac_signalForSelector:@selector(removeObject:)] subscribeNext:^(RACTuple * _Nullable x) {
                @strongify(self)
                for(NSObject *obj in [self.target gic_subElements]){
                    if([[obj gic_self_dataContext] isEqual:x[0]]){
                        [self.target gic_removeSubElements:@[obj]];
                        break;
                    }
                }
            }];
            
            [[dataSource rac_signalForSelector:@selector(removeAllObjects)] subscribeNext:^(RACTuple * _Nullable x) {
                @strongify(self)
                [self.target gic_removeSubElements:[self targetSubElements]];
            }];
            
            [[dataSource rac_signalForSelector:@selector(removeObjectsInArray:)] subscribeNext:^(RACTuple * _Nullable x) {
                NSMutableArray *temp = [NSMutableArray array];
                @strongify(self)
                for(NSObject *obj in [self.target gic_subElements]){
                    if([(NSArray *)x[0] containsObject:[obj gic_self_dataContext]]){
                        [temp addObject:obj];
                    }
                }
                if(temp.count>0){
                    [self.target gic_removeSubElements:temp];
                }
            }];
            
            
        }
    }
}

-(NSArray *)targetSubElements{
    NSMutableArray *array = [NSMutableArray array];
    [[self.target gic_subElements] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj gic_ExtensionProperties].isFromDirectiveFor){
            [array addObject:obj];
        }
    }];
    return array;
}

-(void)addAElement:(id)data index:(NSInteger)index{
    NSObject *childElement = [NSObject gic_createElement:[self->xmlDoc rootElement] withSuperElement:self.target];
    childElement.gic_isAutoInheritDataModel = NO;
    childElement.gic_DataContext = data;
    childElement.gic_ExtensionProperties.elementOrder = self.gic_ExtensionProperties.elementOrder + index*kGICDirectiveForElmentOrderStart;
    childElement.gic_ExtensionProperties.isFromDirectiveFor = YES;
    [self.target gic_addSubElement:childElement];
}

-(void)insertAElement:(id)data index:(NSInteger)index{
    NSObject *childElement = [NSObject gic_createElement:[self->xmlDoc rootElement] withSuperElement:self.target];
    childElement.gic_isAutoInheritDataModel = NO;
    childElement.gic_DataContext = data;
    childElement.gic_ExtensionProperties.elementOrder = self.gic_ExtensionProperties.elementOrder + index*kGICDirectiveForElmentOrderStart;
    childElement.gic_ExtensionProperties.isFromDirectiveFor = YES;
    [self.target gic_insertSubElement:childElement atIndex:index];
}

-(void)removeAllItems{
    NSMutableArray *temp = [NSMutableArray array];
    for(id el in [self.target gic_subElements]){
        if([el gic_ExtensionProperties].isFromDirectiveFor ){
            [temp addObject:el];
        }
    }
    [self.target gic_removeSubElements:temp];//更新数据源以后需要清空原来是数据，然后重新添加数据
}
@end

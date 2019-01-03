# event

`event`在`gic`中也是以`behavior`实现的，`event`的基类是`GICEvent `,这个类是`gic`对事件的封装，事件有很多种，点击、触摸、双击等一些手势事件固然也算是事件，而下拉刷新、属性变更等其实也算是事件，因此`gic`中事件是泛指。

在`gic`中，如无必要，你也无需自定义一个event class，直接使用`GICEvent `即可。

`GICEvent `在设计的时候考虑到了多播事件的情况，因此在实现的时候是基于`RAC`来实现的。`GICEvent `的定义如下：

```
@interface GICEvent : GICBehavior{
    NSString *expressionString;
    RACDisposable *signlDisposable;
}
@property (nonatomic,readonly,strong)RACSubject *eventSubject;
@property (nonatomic,assign,readonly)BOOL onlyExistOne;//是否一个元素上面只能存在一个。默认yes
-(id)initWithExpresion:(NSString *)expresion;
-(void)fire:(id)value;
@end
```

`GICEvent `有两个属性，`eventSubject`在这里权当是一个多播事件，你可以在同一个事件上注册多个订阅者，只需要调用`eventSubject`的`subscribeNext `方法就能订阅事件。如果要触发一个事件，那么直接调用`GICEvent `的`fire`方法即可。

而`initWithExpresion`方法，是用来在XML中绑定事件用的，expresion就是绑定事件回调的方法名称，如果回调方法需要接受事件上下文，那么你就需要在方法后面添加一个`:`，其实之所以这样实现，完全是因为`GICEvent `在实现的 时候是通过`NSSelectorFromString `方法来创建事件回调的。

对于绑定是事件回调来说，回调必须在该元素的数据源上下文中，也就是某个`ViewModel`中，`GICEvent `在查找事件回调target的时候，会按照数据源逐级往上查找，当找到最近的一个数据源实现了该绑定的方法，那么就直接回调，不会再往上查找了。



目前所有的UI元素支持如下事件：

1. event-tap

   > 单击事件

2. event-double-tap

   > 双击事件

3. event-touch-begin

   > 触摸开始事件

4. event-touch-move

   > 触摸事件

5. event-touch-end

   > 触摸结束事件

不同的元素可能提供不同的事件，具体的可以查看对应元素的文档。



## 访问事件参数

所有的事件都可以通过eventInfo来访问。

如果是在`JS`中访问，可以通过`$eventInfo`来访问。比如：点击事件获取`point`参数

```xml
<lable text="触摸事件。摸我" event-touch-move="js:$el.text='('+$eventInfo.x+','+$eventInfo.y+')';" />
```

上面`$eventInfo`表示的是由`GIC`传来的`CGPoint`，可以直接通过属性`x,y`访问。



## convertPoint & convertRect

`convertPoint` & `convertRect`两个方式是提供给JS使用的，用来将某个点转换到另外一个view上面。具体的可以参考sample中的示例。

下面提供`convertPoint`的代码示例。

```xml
<lable text="触摸事件。" event-touch-move="js:convertPoint($el,$eventInfo)">
    <behaviors>
        <script>
            var scrollView = document.getElementsByName('scrollView')[0];
            function convertPoint(el,point){
                    var str = '在按钮上的点：\n('+point.x.toFixed(2)+','+point.y.toFixed(2)+')'+'\n';
            		// 将point 转换到 scrollView 上的点
                    var convertP = el.convertPoint(point,scrollView);
                    str+= '将point转换到scroll-view上:\n('+convertP.x+','+convertP.y+')';
                    el.text = str;
             }               
         </script>
    </behaviors>
</lable>
```


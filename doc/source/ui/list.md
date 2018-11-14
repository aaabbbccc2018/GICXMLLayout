# list

`list`是`gic`里面非核心功能中算是最重要的一个元素，`list`对应iOS中的`UITableView`,但是前面也已经介绍过了，`gic`本身是基于`Texture`的，因此`list`自然而然是封装自`Texture`中的`ASTableNode`，并且`gic`对`ASTableNode`进行了进一步的封装，规避了`ASTableNode`在刷新数据时候可能会出现闪的问题。

暂时先不说`ASTableNode`，如果想要了解的，直接点击如下链接即可。

[ASTableNode文档链接](http://texturegroup.org/docs/containers-astablenode.html)

先直接列举下`list`的功能。

1. 所有的Cell都是异步加载的。也即是所有的Cell都是在后台线程完成布局、渲染等操作。因此`list`拥有强大的性能优势。
2. 你无需自己去计算每个cell的高度，高度的计算以及缓存完全交由list(布局系统)自动处理。
3. 所有的cell无需添加`identifyString`,`list`没有重用的的概念(相对理解，也即是在xml中使用的时候你无需考虑重用的问题)。这个功能点使得list面对不同的cell模板的时候，全部一视同仁。
4. 由于cell是异步渲染的，因此cell中如果包含了你自定义的UI元素，那么请确保在代码中访问view的时候使用gcd调度到UI线程上，这个会在后面的自定义章节再做详细的说明。

**综上，在实际的使用过程中，使用`list`大多数情况下你无需关心性能问题。`list`本身进行了大幅度的性能优化**，您可以使用instrument测试下性能。sample中有一个`模拟今日头条Feeds`的一个专门sample，里面提供了8中不同的模板，每次拉取大概20多条的数据，你会看到性能一直维持着较高的水准，如果你用instrument中的`coreAnimation`来查看，你会发现几乎没有会影响性能的地方。

`list`对于`ASTableNode`的封装也并不全面，有些功能可以说是缺失的，但是也因为`gic`拥有的强大的自定义能力，你可以对现有元素进行任意的扩展，甚至你也可以直接自定义一个。



**从0.3.0版本开始增加如下功能：**

1. 支持header、footer。
2. 支持section





## list 属性

| 名称                   | 数据类型      | 介绍                          | 是否支持绑定 | 是否支持动画 |
| ---------------------- | ------------- | ----------------------------- | ------------ | ------------ |
| separator-style        | Integer(枚举) | cell分割线的样式              | 是           | 是           |
| show-ver-scroll        | Bool          | 是否显示垂直滚动条            | 是           | 是           |
| show-hor-scroll        | Bool          | 是否显示水平滚动条            | 是           | 是           |
| content-inset          | UIEdgeInsets  | 内容边距                      | 是           | 是           |
| show-indexs            | Bool          | 是否显示索引                  | 是           | 否           |
| index-color            | UIColor       | 索引文字的颜色                | 是           | 否           |
| content-inset-behavior | Integer(枚举) | 内容边距行为。iOS11.0以上生效 | 是           | 否           |

### separator-style 枚举

| 枚举值 | 对应枚举                                | 说明       |
| ------ | --------------------------------------- | ---------- |
| 0      | UITableViewCellSeparatorStyleNone       | 没有分割线 |
| 1      | UITableViewCellSeparatorStyleSingleLine | 有分割线   |

### content-inset-behavior 枚举

| 枚举值 | 对应枚举                                         | 说明 |
| ------ | ------------------------------------------------ | ---- |
| 0      | UIScrollViewContentInsetAdjustmentAutomatic      |      |
| 1      | UIScrollViewContentInsetAdjustmentScrollableAxes |      |
| 2      | UIScrollViewContentInsetAdjustmentNever          |      |
| 3      | UIScrollViewContentInsetAdjustmentAlways         |      |

### 

## section

`section`的概念就是等同于UITableView中的`section`，每个list至少需要包含一个`section` 

### section 属性

| 名称  | 数据类型 | 介绍               | 是否支持绑定 | 是否支持动画 |
| ----- | -------- | ------------------ | ------------ | ------------ |
| title | String   | 用来显示索引的标题 | 是           | 否           |



# list-item

`list-item`你可以理解为`UITableViewCell`,`list-item`也是`list`唯一能识别的"UI"元素。

### list-item属性

| 名称              | 数据类型      | 介绍           | 是否支持绑定 | 是否支持动画 |
| ----------------- | ------------- | -------------- | ------------ | ------------ |
| selection-style   | Integer(枚举) | 不解释         | 是           | 否           |
| separator-inset   | UIEdgeInsets  |                | 是           | 否           |
| accessory-type    | Integer(枚举) |                | 是           | 否           |
| event-item-select | string        | cell选中事件。 | 是           | 否           |

### selection-style 枚举

| 枚举值 | 对应枚举                             | 说明   |
| ------ | ------------------------------------ | ------ |
| 0      | UITableViewCellSelectionStyleNone    | 不解释 |
| 1      | UITableViewCellSelectionStyleBlue    |        |
| 2      | UITableViewCellSelectionStyleGray    |        |
| 3      | UITableViewCellSelectionStyleDefault | 不解释 |

### accessory-type 

| 枚举值 | 对应枚举                                       | 说明   |
| ------ | ---------------------------------------------- | ------ |
| 0      | UITableViewCellAccessoryNone                   | 不解释 |
| 1      | UITableViewCellAccessoryDisclosureIndicator    |        |
| 2      | UITableViewCellAccessoryDetailDisclosureButton |        |
| 3      | UITableViewCellAccessoryCheckmark              |        |
| 4      | UITableViewCellAccessoryDetailButton           | 不解释 |

## header、footer

~~`header`、`footer` 不支持自动计算高度，必须显式设置height属性,并且不能是比例单位，否则不会显示。~~

> 0.3.2 开始无需显式设置height属性

**从0.3.2版本开始，所有的section都支持单独设置header、footer，~~并且header、footer都必须包含在`section`元素中。~~**





## 例子

在XML中添加list是一件非常简单的事情，只需要两步就能实现。

1. 你可以直接在`list`下面添加N个`list-item`

```xml
<list>
    <section>
        <list-item>
            <inset-panel inset="15" background-color="white">
                <lable text="cell1"></lable>
            </inset-panel>
        </list-item>
        <list-item>
            <inset-panel inset="15" background-color="white">
                <lable text="cell2"></lable>
            </inset-panel>
        </list-item>
        <list-item>
            <inset-panel inset="15" background-color="white">
                <lable text="cell3"></lable>
            </inset-panel>
        </list-item>
        ...
    </section>
</list>
```

2. 通过`for指令`来动态创建`list-item`

   ```xml
   <list>
       <section>
           <for data-context='["1", "2", "3", "4"]'>
               <list-item>
                   <inset-panel inset="15" background-color="white">
                       <lable text="{{  }}"></lable>
                   </inset-panel>
               </list-item>
           </for>
       </section>
   </list> 
   ```

   >1. data-context 通过json字符串创建了一个包含4个item的数组作为数据源
   >2. 使用for指令来动态创建list-item

   这样也算完成了一个简单的列表创建

3. 添加cell选中事件。

   `list-item`有一个`event-item-select`的属性，这是一个事件，可以将点击的回调绑定到ViewModel中的某一个方法。只需要你指定该方法的名称即可。

   ```xml
   <!--page 相当于 UIViewController-->
   <page title="GICXMLLayout11" data-context="IndexPageViewModel">
       <!--list 相当于UITableView-->
       <list background-color="white" separator-style="1">
           <section>
               <for data-path="listDatas">
                   <list-item selection-style="2" event-item-select="onSelect:">
                       <inset-panel background-color="white" inset="15">
                           <lable text="{{ name }}" font-size="15"></lable>
                       </inset-panel>
                   </list-item>
               </for>
           </section>
       </list>
   </page>
   ```

   ```objective-c
   @interface IndexPageViewModel : NSObject
   @property (nonatomic,strong,readonly)NSArray *listDatas;
   @end
   @implementation IndexPageViewModel
   -(id)init{
       self=[super init];
       
       _listDatas = @[
                          @{@"name":@"布局系统",@"pagePath":@"Layout"},
                          ];
       return self;
   }
   
   -(void)onSelect:(GICEventInfo *)eventInfo{
       NSDictionary *ds = [eventInfo.target gic_DataContenxt];
       [UtilsHelp navigateToGICPage:[ds objectForKey:@"pagePath"]];
   }
   @end
   ```

   在这里你可以看到，在`list-item `绑定了一个`onSelect:`的事件，该事件的实际回调就在`IndexPageViewModel`中的`onSelect:`方法。然后可以通过`eventInfo`提供的信息获取实际该`list-item `的数据源·

4. header、footer

   ```xml
    <list>
          <section>
               <!--显式指定高度-->
               <header height="44" background-color="yellow">
                   <dock-panel>
                       <lable text="header" font-size="24"/>
                   </dock-panel>
               </header>
               <!--显式指定高度-->
               <footer height="44" background-color="yellow">
                   <dock-panel>
                       <lable text="footer" font-size="24"/>
                   </dock-panel>
               </footer>
           </section>
   </list>
   ```

5. 多个section

   ```xml
   <list>
           <data-context>
               {
               "section1": ["section1-1", "section1-2", "section1-3", "section1-4", "section1-5", "section1-6", "section1-7"],
               "section2": ["section2-1", "section2-2", "section2-3", "section2-4", "section2-5", "section2-6", "section2-7"],
               "section3": ["section3-1", "section3-2", "section3-3", "section3-4", "section3-5", "section3-6", "section3-7"]
               }
           </data-context>
           <section data-path="section1">
               <for>
                   <list-item selection-style="2">
                       <inset-panel background-color="white" inset="15">
                           <lable text="{{ }}" font-size="15"/>
                       </inset-panel>
                   </list-item>
               </for>
           </section>
           <section data-path="section2">
               <for>
                   <list-item selection-style="2">
                       <inset-panel background-color="red" inset="18">
                           <lable text="{{ }}" font-size="18" font-color="white"/>
                       </inset-panel>
                   </list-item>
               </for>
           </section>
           <section data-path="section3">
               <for>
                   <list-item selection-style="2">
                       <inset-panel background-color="blue" inset="15">
                           <lable text="{{ }}" font-size="15" font-color="white"/>
                       </inset-panel>
                   </list-item>
               </for>
           </section>
       </list>
   ```

   除了上面显式指定多个section以外，您也可以使用一个for指令，将section包进去，比如下面：

   ```xml
   <list>
           <data-context>
               [
               ["section1-1", "section1-2", "section1-3", "section1-4", "section1-5", "section1-6", "section1-7"],
               ["section2-1", "section2-2", "section2-3", "section2-4", "section2-5", "section2-6", "section2-7"],
               ["section3-1", "section3-2", "section3-3", "section3-4", "section3-5", "section3-6", "section3-7"]
               ]
           </data-context>
           <for>
               <section>
                   <for>
                       <list-item selection-style="2">
                           <inset-panel background-color="white" inset="15">
                               <lable text="{{ }}" font-size="15"/>
                           </inset-panel>
                       </list-item>
                   </for>
               </section>
           </for>
       </list>
   ```

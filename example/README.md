# flutter_paging_widget_example

Demonstrates how to use the flutter_paging_widget plugin.

![Image text](https://github.com/andfaraway/flutter_paging_widget/example.gif)

## How to use

```
FlutterPagingWidget(children: [widget1,widget2...],);
```
or
```
FlutterPagingWidget.builder(
  itemBuild: (context, index) {
    return Widget();
    );
  },
  controller: _controller,
)
```
## How to jump to lastPage/nextPage
```
final FlutterPagingController _controller = FlutterPagingController();

FlutterPagingWidget(children: [widget1,widget2...],controller: _controller,);

_controller.jumpToLast();

```



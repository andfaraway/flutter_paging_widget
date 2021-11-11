import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

typedef WidgetBuilder = Widget Function(BuildContext? context, int index);
enum FlipDirection { up, down }

class FlutterPagingWidget extends StatefulWidget {
  const FlutterPagingWidget(
      {Key? key,
      required this.children,
      this.controller,
      this.direction = FlipDirection.down,
      this.initialIndex = 0,
      this.duration = const Duration(seconds: 1),
      this.spaceWidth = 1.5,
      this.auto = false,
      this.itemBuild,
      this.itemCount})
      : assert(
          children.length > 2,
          'The length of children is not less than 2 .',
        ),
        super(key: key);

  static FlutterPagingWidget builder({
    Key? key,
    required WidgetBuilder itemBuild,
    required int itemCount,
    FlutterPagingController? controller,
    FlipDirection? direction,
    int initialIndex = 0,
    Duration duration = const Duration(seconds: 1),
    double spaceWidth = 1.5,
    bool auto = false,
  }) {
    List<Widget> children = [];
    for (int i = 0; i < itemCount; i++) {
      Widget s = itemBuild(null, i);
      children.add(s);
    }

    return FlutterPagingWidget(
      key: key,
      children: children,
      controller: controller,
      direction: direction,
      initialIndex: initialIndex,
      duration: duration,
      spaceWidth: spaceWidth,
      auto: auto,
    );
  }

  /// Creates a FlutterPagingWidget.
  /// [children] widget 数组
  ///
  /// [controller] controller
  ///
  /// [direction] 翻转方向，包含up,down
  ///
  /// [initialIndex] 初始页，默认为0
  ///
  /// [duration] 动画持续时间
  ///
  /// [spaceWidth]中间空白宽度
  ///
  /// [auto]是否自动翻页  默认为false
  final List<Widget> children;
  final FlutterPagingController? controller;
  final FlipDirection? direction;
  final int initialIndex;
  final Duration duration;
  final double spaceWidth;
  final bool auto;

  final int? itemCount;

  final WidgetBuilder? itemBuild;

  static FlutterPagingWidgetState? of(BuildContext context) {
    final FlutterPagingWidgetState? result =
        context.findAncestorStateOfType<FlutterPagingWidgetState>();
    if (result != null) return result;
    return result;
    // throw 'state no find';
  }

  @override
  FlutterPagingWidgetState createState() => FlutterPagingWidgetState();
}

class FlutterPagingWidgetState extends State<FlutterPagingWidget>
    with SingleTickerProviderStateMixin {
  FlutterPagingWidgetState();

  late bool auto;
  late FlipDirection _direction;
  late int _currentIndex;
  late Widget _currentWidget;
  late Widget _nextWidget;
  late AnimationController _animationController;
  late Animation _topAnimation;
  late Animation _bottomAnimation;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initData();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addStatusListener((status) {
        if (_animationController.status == AnimationStatus.completed) {
          updateSee();
          updateNextWidget();
          _animationController.reset();
          _animationController.duration = widget.duration;
        } else if (_animationController.status == AnimationStatus.dismissed) {}
      });
    _topAnimation = CurvedAnimation(
        parent: _animationController, curve: const Interval(0, 0.5));
    _bottomAnimation = CurvedAnimation(
        parent: _animationController, curve: const Interval(0.5, 1));

    widget.controller?.addListener(() {
      if (widget.controller?._action == _Actions.jumpToLast) {
        jumpToLast();
      } else if (widget.controller?.action == _Actions.jumpToNext) {
        jumpToNext();
      }

      auto = widget.controller!.auto;
      if (auto && _timer == null) {
        _timer = Timer.periodic(widget.duration, _tick);
      } else {
        _timer?.cancel();
        _timer = null;
      }
    });
  }

  /// [jumpToLast]跳转到上一页
  Future<void> jumpToLast() async {
    if (_animationController.isAnimating && _direction != FlipDirection.up) {
      _animationController.reverse();
    } else {
      _direction = FlipDirection.up;
      updateNextWidget();
      if (_animationController.isAnimating) {
        _animationController.duration = const Duration(milliseconds: 200);
      }
      await _animationController.forward();
    }
  }

  /// [jumpToNext]跳转到下一页
  Future<void> jumpToNext() async {
    if (_animationController.isAnimating && _direction != FlipDirection.down) {
      _animationController.reverse();
    } else {
      _direction = FlipDirection.down;
      updateNextWidget();

      if (_animationController.isAnimating) {
        _animationController.duration = const Duration(milliseconds: 200);
      }
      await _animationController.forward();
    }
  }

  void _tick(Timer timer) {
    if (!_animationController.isAnimating) {
      if (_direction == FlipDirection.down) {
        jumpToNext.call();
      } else {
        jumpToLast.call();
      }
    }
  }

  //初始化数据
  _initData() {
    auto = widget.auto;
    _direction = widget.direction ?? FlipDirection.down;
    _currentIndex = widget.initialIndex;
    _currentWidget = widget.children[_currentIndex];

    if (_direction == FlipDirection.down) {
      _nextWidget = widget.children[
          widget.initialIndex == widget.children.length - 1
              ? 0
              : _currentIndex + 1];
    } else {
      _nextWidget = widget.children[widget.initialIndex == 0
          ? widget.children.length - 1
          : _currentIndex - 1];
    }

    if (widget.auto) _timer = Timer.periodic(widget.duration, _tick);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _topWidget(_direction == FlipDirection.down
                ? _nextWidget
                : _currentWidget),
            Padding(
              padding: EdgeInsets.only(top: widget.spaceWidth),
            ),
            _bottomWidget(_direction == FlipDirection.down
                ? _currentWidget
                : _nextWidget),
          ],
        ),
        AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FlipWidget(
                direction: _direction,
                spaceWidth: widget.spaceWidth,
                topWidget: _topWidget(_direction == FlipDirection.down
                    ? _currentWidget
                    : _nextWidget),
                bottomWidget: _bottomWidget(_direction == FlipDirection.down
                    ? _nextWidget
                    : _currentWidget),
                topAnimationValue: _topAnimation.value,
                bottomAnimationValue: _bottomAnimation.value,
              );
            }),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.controller?.removeListener(() {});
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  ///页面完成，更新当前页
  updateSee() {
    //向下翻页
    if (_direction == FlipDirection.down) {
      if (_currentIndex == widget.children.length - 1) {
        _currentIndex = 0;
      } else {
        _currentIndex++;
      }
    } else {
      //向上翻页
      if (_currentIndex == 0) {
        _currentIndex = widget.children.length - 1;
      } else {
        _currentIndex--;
      }
    }
    _currentWidget = widget.children[_currentIndex];
    return;
  }

  ///更新底部widget
  updateNextWidget() {
    if (_direction == FlipDirection.down) {
      _nextWidget = widget.children[
          _currentIndex == widget.children.length - 1 ? 0 : _currentIndex + 1];
    } else {
      _nextWidget = widget.children[
          _currentIndex == 0 ? widget.children.length - 1 : _currentIndex - 1];
    }
    setState(() {});
  }
}

class FlipWidget extends StatelessWidget {
  final Widget topWidget;
  final Widget bottomWidget;
  final double spaceWidth;
  final FlipDirection direction;

  final double topAnimationValue;
  final double bottomAnimationValue;

  final double pageScale = 0.02;
  final double flagDouble = 0.001;

  const FlipWidget({
    Key? key,
    required this.topWidget,
    required this.bottomWidget,
    this.spaceWidth = 1.5,
    this.direction = FlipDirection.down,
    this.topAnimationValue = 0,
    this.bottomAnimationValue = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform(
          transform: direction == FlipDirection.down
              ? (Matrix4.identity()
                ..setEntry(3, 2, flagDouble)
                ..rotateX(pi / 2 * topAnimationValue))
              : (Matrix4.identity()
                ..setEntry(3, 2, flagDouble)
                ..rotateX(pi / 2 - pi / 2 * bottomAnimationValue)),
          alignment: Alignment.bottomCenter,
          child: topWidget,
        ),
        Padding(
          padding: EdgeInsets.only(top: spaceWidth),
        ),
        Transform(
          transform: direction == FlipDirection.down
              ? (Matrix4.identity()
                ..setEntry(3, 2, flagDouble)
                ..rotateX(-pi / 2 + pi / 2 * bottomAnimationValue))
              : (Matrix4.identity()
                ..setEntry(3, 2, flagDouble)
                ..rotateX(-pi / 2 * topAnimationValue)),
          alignment: Alignment.topCenter,
          child: bottomWidget,
        ),
      ],
    );
  }
}

Widget _topWidget(Widget child) {
  return ClipRect(
    child: Align(
      alignment: Alignment.topCenter,
      heightFactor: 0.5,
      child: child,
    ),
  );
}

Widget _bottomWidget(Widget child) {
  return ClipRect(
    child: Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 0.5,
      child: child,
    ),
  );
}

class FlutterPagingController extends ChangeNotifier {
  /// Creates a text widget.
  /// [children] widget 数组
  ///
  /// [direction] 翻转方向，包含up,down
  ///
  /// [initialIndex] 初始页，默认为0
  ///
  /// [duration] 动画持续时间
  ///
  /// [spaceWidth]中间空白宽度
  ///
  /// [auto]是否自动翻页  默认为false
  // final FlipDirection direction;
  // final int initialIndex;
  // final Duration duration;
  // final bool auto;

  int currentIndex = 0;

  /// 是否自动滚动
  bool _auto = false;

  bool get auto => _auto;

  set auto(bool newAuto) {
    if (_auto == newAuto) {
      return;
    }
    _action = _Actions.jumpToLast;
    _auto = newAuto;
    _action = _Actions.changeAuto;
    notifyListeners();
  }

  /// 触发的方法
  _Actions? _action;

  _Actions? get action => _action;

  jumpToLast() {
    _action = _Actions.jumpToLast;
    notifyListeners();
  }

  jumpToNext() {
    _action = _Actions.jumpToNext;
    notifyListeners();
  }

  FlutterPagingController({bool auto = false}) {
    _auto = auto;
  }
}

enum _Actions {
  changeAuto,
  jumpToLast,
  jumpToNext,
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paging_widget/flutter_paging_widget.dart';
import 'package:flutter_paging_widget_example/number_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ValueNotifier notif = ValueNotifier<bool>(false);

  final FlutterPagingController _controller = FlutterPagingController();

  @override
  void initState() {
    super.initState();
    TextEditingController _c = TextEditingController(text: 'f');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    notif.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter paging widget'),
        ),
        body: Stack(
          children: [
            Align(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 180),
                child: FlutterPagingWidget.builder(
                  itemBuild: (context, index) {
                    return NumberWidget(
                      index.toString(),
                      color: getRandomColor(),
                    );
                  },
                  controller: _controller,
                  duration: const Duration(seconds: 1),
                  itemCount: 10,
                  initialIndex: 0,
                  spaceWidth: 0,
                  auto: notif.value,
                ),
              ),
              alignment: Alignment.center,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20, bottom: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ValueListenableBuilder(
                            builder:
                                (BuildContext context, value, Widget? child) {
                              return MaterialButton(
                                minWidth: 54,
                                height: 54,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(27)),
                                onPressed: () {
                                  notif.value = !notif.value;
                                  _controller.auto = notif.value;
                                },
                                elevation: 5,
                                color: Colors.blue,
                                child: Icon(
                                  notif.value ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                              );
                            },
                            valueListenable: notif,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          MaterialButton(
                            minWidth: 54,
                            height: 54,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27)),
                            onPressed: () {
                              _controller.auto = false;
                              notif.value = _controller.auto;
                              _controller.jumpToLast();
                            },
                            elevation: 5,
                            color: Colors.blue,
                            child: const Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          MaterialButton(
                            minWidth: 54,
                            height: 54,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27)),
                            onPressed: () {
                              _controller.auto = false;
                              notif.value = _controller.auto;
                              _controller.jumpToNext();
                            },
                            elevation: 5,
                            color: Colors.blue,
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

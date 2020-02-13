import 'dart:ui';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

mixin ProgressControllable {
  final List<void Function(bool value)> _callbacks = [];
  void Function(bool value) get callback => _callbacks.elementAt(0);
  void registerCallback(Function(bool value) callback) {
    if (_callbacks.length > 0) {
      _callbacks.clear();
    }
    _callbacks.add(callback);
  }
}

class MyProgressControllable extends StatelessWidget with ProgressControllable {
  MyProgressControllable({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.deepOrangeAccent,
      child: Center(
        child: OutlineButton(
          child: Text("Action"),
          onPressed: () {
            callback(true);
            Future.delayed(Duration(seconds: 4), () => callback(false));
          },
        ),
      ),
    );
  }
}

class ApiWidget extends StatefulWidget {
  final bool isLoading;

  final Widget child;

  ApiWidget(this.child, {this.isLoading = false, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ApiWidgetState();
  }
}

class _ApiWidgetState extends State<ApiWidget> {
  bool _isLoading;

  void _attachCallback() {
    if (widget.child is ProgressControllable) {
      (widget.child as ProgressControllable).registerCallback((bool value) {
        setState(() {
          _isLoading = value;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _isLoading = widget.isLoading;
    _attachCallback();
  }

  @override
  void didUpdateWidget(ApiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading) {
      _isLoading = widget.isLoading;
    }
    _attachCallback();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: IntrinsicWidth(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            widget.child,
            if (_isLoading)
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                  child: Container(
                    constraints: BoxConstraints.expand(),
                    decoration: BoxDecoration(color: Colors.grey.shade200.withOpacity(0.5)),
                  ),
                ),
              ),
            if (_isLoading)
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black26),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Widget',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Demo"),
      ),
      body: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            OutlineButton(
              child: Text("Start"),
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
              },
            ),
            ApiWidget(
              MyProgressControllable(),
              isLoading: _isLoading,
            ),
            OutlineButton(
              child: Text("End"),
              onPressed: () {
                setState(() {
                  _isLoading = false;
                });
              },
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

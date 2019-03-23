import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/main.dart';
import 'package:kamino/ui/ui_utils.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:kamino/ui/ui_elements.dart';

class KaminoIntro extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => KaminoIntroState();

}

class KaminoIntroState extends State<KaminoIntro> with SingleTickerProviderStateMixin {

  List<Page> _pages;

  bool get onLastPage {
    return _controller.hasClients && _controller.page.round() == (_pages.length - 1);
  }

  final _fadeInTween = Tween<double>(begin: 0, end: 1);
  AnimationController _animationController;
  Animation<double> _fadeInAnimation;

  PageController _controller;

  @override
  void initState() {
    // Initialize controller.
    _controller = PageController();
    _controller.addListener(() => setState((){}));

    // Initialize animation controller.
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this
    );
    _animationController.addStatusListener((AnimationStatus status) => setState((){}));

    _fadeInAnimation = CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.9, 1.0, curve: Curves.easeIn)
    );

    // Wait a second for the application to catch up.
    Future.delayed(Duration(milliseconds: 500), () => _animationController.forward());

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    _pages = <Page>[
      Page(
        child: Builder(builder: (BuildContext context){
          const double size = 130;
          const double foregroundPadding = 30;

          final _rocketMotionTween = Tween<double>(begin: 0, end: ((MediaQuery.of(context).size.width / 2) + size));
          final _backgroundSizeTween = Tween<double>(begin: size, end: 0);
          final _rocketSizeTween = Tween<double>(begin: size - foregroundPadding, end: 0);

          final _rocketAnimation = CurvedAnimation(
              parent: _animationController,
              curve: Interval(0.2, 0.9, curve: ApolloRocketCurve())
          );

          // This animation is basically just used to clean up
          // the area after the rocket has animated away.
          final _rocketSizeAnimation = CurvedAnimation(
              parent: _animationController,
              curve: Interval(0.7, 0.9, curve: Curves.easeOut)
          );

          final _backgroundAnimation = CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.7, 0.9, curve: Curves.easeOut),
          );

          return AnimatedBuilder(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TitleText(S.of(context).welcome_to_appname(appName), fontSize: 32, textAlign: TextAlign.center),
                    Text(S.of(context).app_tagline, textAlign: TextAlign.center),

                    Container(padding: EdgeInsets.symmetric(vertical: 10)),

                    RaisedButton.icon(
                      onPressed: () => showLanguageSelectionDialog(context),
                      icon: Icon(Icons.translate),
                      label: Text(S.of(context).select_language),
                    )
                  ],
                )
              ),
              animation: _animationController,
              builder: (BuildContext context, Widget child){
                var translateOffset = _rocketMotionTween.evaluate(_rocketAnimation);

                return Column(
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(
                            "assets/images/logo_background.png",
                            height: _backgroundSizeTween.evaluate(_backgroundAnimation),
                            width: _backgroundSizeTween.evaluate(_backgroundAnimation),
                          ),
                        ),

                        Transform.translate(
                          offset: Offset(translateOffset, -translateOffset),
                          child: Transform.rotate(
                            angle: math.pi / -15,
                            child: Image.asset(
                                "assets/images/logo_foreground_lg.png",
                                height: _rocketSizeTween.evaluate(_rocketSizeAnimation),
                                width: _rocketSizeTween.evaluate(_rocketSizeAnimation),
                                fit: BoxFit.cover
                            ),
                          ),
                        )
                      ],
                    ),

                    Offstage(offstage: _fadeInTween.evaluate(_fadeInAnimation) == 0, child: Opacity(
                      opacity: _fadeInTween.evaluate(_fadeInAnimation),
                      child: child,
                    ))
                  ],
                );
              }
          );
        }),
      ),

      Page(
        child: Builder(builder: (_) => Expanded(
          child: Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                TitleText(S.of(context).create_profile, fontSize: 32),

                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                ),

                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                          labelText: "Name",
                          border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                          hintStyle: TextStyle(
                            color: Theme.of(context).primaryColor
                          )
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        )),
      ),

      Page(
        child: Builder(builder: (_) => Text("Hi")),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: new Container(),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,

        centerTitle: true,
        title: generateHeaderLogo(context),
      ),

      backgroundColor: Theme.of(context).backgroundColor,

      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (notification){
          notification.disallowGlow();
          return true;
        },
        child: IgnorePointer(
          ignoring: !_animationController.isCompleted,
          child: PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            itemBuilder: (BuildContext context, int index){
              return _pages[index];
            },
          ),
        )
      ),

      bottomNavigationBar: AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget child) => IgnorePointer(
          ignoring: !_fadeInAnimation.isCompleted,
          child: Opacity(
            opacity: _fadeInTween.evaluate(_fadeInAnimation),
            child: Container(
              child: child,
            )
          ),
        ),

        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IgnorePointer(
                ignoring: onLastPage,
                child: AnimatedOpacity(child: FlatButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  highlightColor: Colors.transparent,
                  child: Text(S.of(context).skip, style: TextStyle(
                      fontSize: 16
                  )),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                ), opacity: onLastPage ? 0 : 1, duration: Duration(milliseconds: 100)),
              ),

              DotsIndicator(
                position: _controller.hasClients ? _controller.page.round() : _controller.initialPage,
                numberOfDot: _pages.length,
                dotActiveShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                dotActiveColor: Theme.of(context).primaryColor,
                dotActiveSize: const Size(18.0, 9.0),
              ),

              new FlatButton(
                onPressed: (){
                  if(onLastPage){
                    Navigator.of(context).pop();
                    return;
                  }

                  _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
                highlightColor: Colors.transparent,
                child: Text(onLastPage ? S.of(context).lets_go : S.of(context).next, style: TextStyle(
                    fontSize: 16
                )),
                padding: EdgeInsets.symmetric(vertical: 15),
                materialTapTargetSize: MaterialTapTargetSize.padded,
              )
            ],
          ),
        ),
      ),
    );
  }

}

class Page extends StatelessWidget {

  final Builder child;

  Page({
    @required this.child
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        child.build(context)
      ]
    );
  }

}

class ApolloRocketCurve extends ElasticInCurve {

  @override
  double transformInternal(double t) {
    final double s = period / 4.0;
    t = t - 1.0;
    return -math.pow(2.0, 10.0 * t) * math.sin((t - s) * (math.pi * 1.0) / period);
  }

}
import 'dart:math' as math;

import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:kamino/api/tmdb.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/interface/settings/page_appearance.dart';
import 'package:kamino/main.dart';
import 'package:kamino/models/list.dart';
import 'package:kamino/ui/ui_utils.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:kamino/ui/ui_elements.dart';
import 'package:kamino/util/settings.dart';

class KaminoIntro extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => KaminoIntroState();

}

class KaminoIntroState extends State<KaminoIntro> with SingleTickerProviderStateMixin {

  KaminoAppState appState;
  List<Page> _pages;

  bool get onLastPage {
    return _controller.hasClients && _controller.page.round() == (_pages.length - 1);
  }

  List<String> _selectedCategories = new List();
  final Map<String, AsyncMemoizer> _categoryMemoizers = new Map();
  final _fadeInTween = Tween<double>(begin: 0, end: 1);
  AnimationController _animationController;
  Animation<double> _fadeInAnimation;

  PageController _controller;
  bool _detailedLayoutType;

  @override
  void initState() {
    // Load default settings for layout type
    (Settings.detailedContentInfoEnabled as Future).then(
      (result) => setState(() => _detailedLayoutType = result)
    );
    (Settings.homepageCategories as Future).then(
      (result) => setState(() => _selectedCategories = result)
    );

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
    appState = context.ancestorStateOfType(const TypeMatcher<KaminoAppState>());

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
            child: ListView(
              children: <Widget>[
                TitleText(S.of(context).customise_appearance, fontSize: 32),
                Text(S.of(context).customise_appearance_description(appName)),

                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                ),

                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        onTap: () => showThemeChoice(context, appState),
                        leading: Icon(Icons.style),
                        isThreeLine: true,
                        title: TitleText("Choose a theme..."),
                        subtitle: Text("Select a general theme! This is used primarily to decide the background color.")
                      ),

                      ListTile(
                        onTap: () => setPrimaryColor(context, appState),
                        leading: CircleColor(
                          circleSize: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                        isThreeLine: true,
                        title: TitleText("What's your favorite color?"),
                        subtitle: Text("Tap to set the accent color; it's used to give a splash of color to buttons, icons, etc..."),
                      ),

                      Container(
                        padding: EdgeInsets.only(top: 15, left: 15, right: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TitleText(
                                "Which do you prefer?"
                            ),
                            ButtonBar(
                              alignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                VerticalIconButton(
                                  backgroundColor: _detailedLayoutType ? Theme.of(context).primaryColor : null,
                                  onTap: () async {
                                    await (Settings.detailedContentInfoEnabled = true);
                                    _detailedLayoutType = await Settings.detailedContentInfoEnabled;
                                    setState(() {});
                                  },
                                  title: TitleText("Card Layout"),
                                  icon: Icon(Icons.view_agenda),

                                ),
                                VerticalIconButton(
                                  backgroundColor: !_detailedLayoutType ? Theme.of(context).primaryColor : null,
                                  onTap: () async {
                                    await (Settings.detailedContentInfoEnabled = false);
                                    _detailedLayoutType = await Settings.detailedContentInfoEnabled;
                                    setState(() {});
                                  },
                                  title: TitleText("Grid Layout"),
                                  icon: Icon(Icons.grid_on),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        )),
      ),

      Page(
        canProceedFunction: (){
          return _selectedCategories.length >= 3;
        },
        child: Builder(builder: (_) => Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width,
              child: ListView(
                children: <Widget>[
                  TitleText(S.of(context).choose_n_categories((3 - _selectedCategories.length < 0 ? 0 : 3 - _selectedCategories.length).toString()), fontSize: 32),
                  Text("Tailor your experience! Choose your top 3 categories and get suggestions for the content that YOU like!"),

                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                  ),

                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints){
                      double idealWidth = 200;
                      double spacing = 10.0;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: (constraints.maxWidth / idealWidth).round(),
                          childAspectRatio: 2,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing
                        ),
                        itemCount: TMDB.availableTraktLists.length,
                        itemBuilder: (BuildContext context, int index){
                          if(!_categoryMemoizers.containsKey(TMDB.availableTraktLists[index]))
                            _categoryMemoizers[TMDB.availableTraktLists[index]] = new AsyncMemoizer();

                          return FutureBuilder(
                            future: _categoryMemoizers[TMDB.availableTraktLists[index]].runOnce(
                                () => TMDB.getList(TMDB.availableTraktLists[index])
                            ),
                            builder: (BuildContext context, AsyncSnapshot snapshot){
                              if(snapshot.hasError){
                                print("Error loading list: ${TMDB.availableTraktLists[index]}");
                                return Container();
                              }

                              switch(snapshot.connectionState){
                                case ConnectionState.none:
                                case ConnectionState.waiting:
                                case ConnectionState.active:
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                  
                                case ConnectionState.done:
                                  ContentListModel list = snapshot.data;
                                  
                                  return Material(
                                    type: MaterialType.card,
                                    borderRadius: BorderRadius.circular(5),
                                    clipBehavior: Clip.antiAlias,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        CachedNetworkImage(
                                          imageUrl: TMDB.IMAGE_CDN_LOWRES + list.backdrop,
                                          fit: BoxFit.cover,
                                        ),

                                        Container(
                                          color: const Color(0x7F000000),
                                          child: Center(child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                            child: TitleText(
                                              list.name,
                                              fontSize: 21,
                                              allowOverflow: true,
                                              textAlign: TextAlign.center
                                            ),
                                          )),
                                        ),

                                        AnimatedOpacity(child: Container(
                                          color: const Color(0x9F000000),
                                          child: Center(
                                            child: Icon(Icons.check),
                                          ),
                                        ), opacity: _selectedCategories.contains(list.id.toString()) ? 1 : 0,
                                            duration: Duration(milliseconds: 300)),

                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () => setState((){
                                              _selectedCategories.contains(list.id.toString())
                                                  ? _selectedCategories.remove(list.id.toString())
                                                  : _selectedCategories.add(list.id.toString());
                                            }),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                              }
                            }
                          );
                        },
                      );
                    },
                  )
                ],
              ),
            )
        )),
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
                onPressed: _pages[_controller.hasClients ? _controller.page.round() : _controller.initialPage]._canProceed() ? (){
                  if(onLastPage){
                    Settings.homepageCategories = _selectedCategories;
                    Settings.initialSetupComplete = true;

                    Navigator.of(context).pop();
                    return;
                  }

                  _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                } : null,
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
  final Function canProceedFunction;

  get _canProceed => (){
    if(canProceedFunction != null) return canProceedFunction();
    return true;
  };

  Page({
    @required this.child,
    this.canProceedFunction
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
import 'dart:convert';
import 'dart:math' as math;

import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kamino/api/tmdb.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/interface/settings/page_appearance.dart';
import 'package:kamino/main.dart';
import 'package:kamino/models/list.dart';
import 'package:kamino/ui/ui_utils.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:kamino/ui/ui_elements.dart';
import 'package:kamino/util/settings.dart';
import 'package:kamino/util/trakt.dart' as trakt;

class KaminoIntro extends StatefulWidget {

  final bool skipAnimation;
  final Function then;

  KaminoIntro({ this.then, this.skipAnimation = false });

  @override
  State<StatefulWidget> createState() => KaminoIntroState();

}

class KaminoIntroState extends State<KaminoIntro> with SingleTickerProviderStateMixin {

  KaminoAppState appState;

  Map<String, bool> _selectedCategories = {};
  bool _autoplaySourcesEnabled = false;
  List<String> _traktCred;

  final Map<String, AsyncMemoizer> _categoryMemoizers = {};
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
      (result) => setState(() => _selectedCategories = jsonDecode(result).cast<String, bool>())
    );

    ((Settings.traktCredentials) as Future).then((data) => setState((){
      _traktCred = data;
    }));

    // This is done for legacy reasons.
    // We would upgrade the setting but we do intent to switch back
    // to having autoplay enabled by default.
    (Settings.manuallySelectSourcesEnabled as Future).then((data){
      setState(() {
        _autoplaySourcesEnabled = !data;
      });
    });

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
    if(!widget.skipAnimation) Future.delayed(Duration(milliseconds: 500), () => _animationController.forward());
    else _animationController.value = 1.0;

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
    bool traktConnected = _traktCred != null && _traktCred.length == 3;

    final _pages = <Page>[
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
                Text(S.of(context).customise_appearance_description(appName), style: Theme.of(context).textTheme.caption.copyWith(fontSize: 14)),

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
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                  "Card layouts are more detailed, however grid layouts can fit more items.",
                                  style: Theme.of(context).textTheme.caption.copyWith(fontSize: 14)
                              ),
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
        child: Builder(builder: (_) => Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width,
              child: ListView(
                children: <Widget>[
                  TitleText("General Settings", fontSize: 32),
                  Text("Here's some commonly used settings options that you might want to take a look at.", style: Theme.of(context).textTheme.caption.copyWith(fontSize: 14)),

                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                  ),

                  Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                            onTap: () async {
                              if(!traktConnected){
                                Navigator.push(context, MaterialPageRoute(
                                  fullscreenDialog: true,
                                  builder: (_ctx) => trakt.TraktAuth(context: _ctx)
                                )).then((var authCode) {
                                  trakt.authUser(context, _traktCred, authCode, shouldShowDialog: false).then((_traktCred) async {
                                    setState(() {
                                      this._traktCred = _traktCred;
                                    });

                                    trakt.synchronize(context, _traktCred);
                                  });
                                });
                              }else{
                                if(await trakt.deauthUser(context, _traktCred, shouldShowScaffold: false)){
                                  setState(() {
                                    _traktCred = [];
                                  });
                                }
                              }
                            },
                            leading: SvgPicture.asset("assets/icons/trakt.svg", height: 36, width: 36, color: const Color(0xFFED1C24)),
                            isThreeLine: true,
                            title: TitleText(traktConnected ? "Disconnect your Trakt account" : "Connect your Trakt account"),
                            subtitle: Text("ApolloTV can synchronise your watch history and favorites from Trakt.tv...")
                        ),

                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                        ),

                        Theme(
                          data: Theme.of(context).copyWith(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent
                          ),
                          child: SwitchListTile(
                            isThreeLine: true,
                            activeColor: Theme.of(context).primaryColor,
                            value: _autoplaySourcesEnabled,
                            title: Row(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  margin: EdgeInsetsDirectional.only(end: 5),
                                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  child: Text("Experimental"),
                                ),
                                TitleText(S.of(context).source_autoplay)
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                S.of(context).source_autoplay_description,
                                style: TextStyle(),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            onChanged: (value) async {
                              if (value != _autoplaySourcesEnabled){
                                await (Settings.manuallySelectSourcesEnabled = value); // ignore: await_only_futures
                                (Settings.manuallySelectSourcesEnabled as Future).then((data) => setState(() => _autoplaySourcesEnabled = data));
                              }
                            },
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
                  Text("Finally, let's tailor your content; choose at least 3 categories and get suggestions for content you enjoy!", style: Theme.of(context).textTheme.caption.copyWith(fontSize: 14)),

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
                                        ), opacity: _selectedCategories.containsKey(list.id.toString()) ? 1 : 0,
                                            duration: Duration(milliseconds: 300)),

                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () => setState((){
                                              _selectedCategories.containsKey(list.id.toString())
                                                  ? _selectedCategories.remove(list.id.toString())
                                                  : _selectedCategories[list.id.toString()] = true;
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
      )
    ];

    bool onLastPage(){
      return _controller.hasClients && _controller.page.round() == (_pages.length - 1);
    }

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
                ignoring: onLastPage(),
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
                ), opacity: onLastPage() ? 0 : 1, duration: Duration(milliseconds: 100)),
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
                  // DONE BUTTON?: onLastPage
                  if(onLastPage()){
                    // Write settings.
                    Settings.homepageCategories = jsonEncode(_selectedCategories);
                    Settings.initialSetupComplete = true;

                    Navigator.of(context).pop();

                    // Perform OTA check now.
                    if(widget.then != null) widget.then();

                    return;
                  }

                  _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                } : null,
                highlightColor: Colors.transparent,
                child: Text(onLastPage() ? S.of(context).lets_go : S.of(context).next, style: TextStyle(
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
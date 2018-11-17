import 'model.dart';
import 'bloc.dart';

import 'package:flutter/widgets.dart';

class SearchResultProvider extends InheritedWidget {
  final SearchResultBloc resultBloc;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static SearchResultBloc of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(SearchResultProvider) as SearchResultProvider)
          .resultBloc;

  SearchResultProvider({SearchResultBloc resultBloc, Widget child})
      : this.resultBloc = resultBloc ?? SearchResultBloc(API()),
        super(child: child);
}
/*
 * This GrowERP software is in the public domain under CC0 1.0 Universal plus a
 * Grant of Patent License.
 * 
 * To the extent possible under law, the author(s) have dedicated all
 * copyright and related and neighboring rights to this software to the
 * public domain worldwide. This software is distributed without any
 * warranty.
 * 
 * You should have received a copy of the CC0 Public Domain Dedication
 * along with this software (see the LICENSE.md file). If not, see
 * <http://creativecommons.org/publicdomain/zero/1.0/>.
 */

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'blocs/@blocs.dart';
import 'services/@services.dart';
import 'styles/themes.dart';
import 'router.dart' as router;
import 'forms/@forms.dart';
import 'models/@models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("app_settings");
  Bloc.observer = SimpleBlocObserver();

  String backend = GlobalConfiguration().getValue("backend");
  var repos = backend == 'moqui'
      ? Moqui(client: Dio())
      : backend == 'ofbiz'
          ? Ofbiz(client: Dio())
          : null;

  runApp(RepositoryProvider(
    create: (context) => repos,
    child: MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(repos)..add(LoadAuth())),
        BlocProvider<CatalogBloc>(
            create: (context) =>
                CatalogBloc(repos, BlocProvider.of<AuthBloc>(context))
                  ..add(LoadCatalog())),
        BlocProvider<OrderBloc>(
            create: (context) => OrderBloc(repos)..add(LoadOrder())),
        BlocProvider<CrmBloc>(
            create: (context) => CrmBloc(repos)..add(CrmLoad())),
        BlocProvider<CartBloc>(
            create: (context) => CartBloc(
                BlocProvider.of<OrderBloc>(context),
                BlocProvider.of<CatalogBloc>(context),
                BlocProvider.of<CrmBloc>(context))
              ..add(LoadCart())),
      ],
      // add other blocs here, shopping cart, catalog?
      child: MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        builder: (context, widget) => ResponsiveWrapper.builder(
            BouncingScrollWrapper.builder(context, widget),
            maxWidth: 2460,
            minWidth: 450,
            defaultScale: true,
            breakpoints: [
              ResponsiveBreakpoint.resize(450, name: MOBILE),
              ResponsiveBreakpoint.autoScale(800, name: TABLET),
              ResponsiveBreakpoint.autoScale(1000, name: TABLET),
              ResponsiveBreakpoint.resize(1200, name: DESKTOP),
              ResponsiveBreakpoint.autoScale(2460, name: "4K"),
            ],
            background: Container(color: Color(0xFFF5F5F5))),
        theme: Themes.formTheme,
        onGenerateRoute: router.generateRoute,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading || state is AuthInitial)
              return SplashForm();
            if (state is AuthUnauthenticated &&
                state.authenticate?.company == null)
              return RegisterForm('No companies found in system, create one?');
            return AdminHome(FormArguments(null, "Welcome"));
          },
        ));
  }
}

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Cubit cubit, Object event) {
    print(">>>Bloc event { $event: }");
    super.onEvent(cubit, event);
  }

  @override
  void onTransition(Cubit cubit, Transition transition) {
    print(">>>$transition");
    super.onTransition(cubit, transition);
  }

  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
    print(">>>error: $error");
    super.onError(cubit, error, stackTrace);
  }
}

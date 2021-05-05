import 'package:flutter/material.dart';
import '../screens/settings_screen.dart';
import '../screens/coupons_screen.dart';
import '../screens/feeds_screen.dart';
import '../screens/products_screen.dart';
import '../screens/place_info_screen.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum namebar { feeds, coupons, products, info, settings }

class ArtBar {
  final BuildContext context;
  final bool canBack;
  final dynamic screenBack;
  ArtBar(this.context, this.canBack, this.screenBack);
  static var gh = namebar.coupons;

  AppBar bar() {
    final loc = AppLocalizations.of(context);
    return AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: 20),
          child: Image.asset(
            '../assets/images/logo.png',
            height: AppBar().preferredSize.height,
          ),
        ),
        leading: canBack
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => navigateRemoved(screenBack),
              )
            : Container(),
        backwardsCompatibility: false,
        bottom: PreferredSize(
            child: Container(
              color: Colors.orange,
              height: 1.0,
            ),
            preferredSize: Size.fromHeight(4.0)),
        actions: [
          menuItem(loc.feed_list, FeedsScreen(), namebar.feeds),
          menuItem(loc.coupons, CouponsScreen(), namebar.coupons),
          menuItem(loc.products, ProductsScreen(), namebar.products),
          menuItem(loc.info, PlaceInfoScreen(), namebar.info),
          menuItem(loc.settings, SettingsScreen(), namebar.settings),
        ]);
  }

  void navigateRemoved(child) {
    Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimations) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        ),
        (route) => false);
  }

  void navigate(child) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimations) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      ),
    );
  }

  Widget menuItem(text, screen, type) {
    return Container(
      //padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
          border: gh == type
              ? Border(
                  bottom: BorderSide(
                      color: Colors.red, width: 2, style: BorderStyle.solid))
              : null),
      child: TextButton(
        onPressed: () {
          if (gh == type) return;
          gh = type;

          navigateRemoved(screen);
        },
        child: Row(
          children: [
            SizedBox(
              width: 40,
            ),
            Text(
              text,
              style: TextStyle(fontWeight: gh == type ? FontWeight.w900 : null),
            ),
            SizedBox(
              width: 40,
            ),
          ],
        ),
      ),
    );
  }
}

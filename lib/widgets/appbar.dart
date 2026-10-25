import 'package:flutter/material.dart';
import 'package:soccerpark/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../pages/mainpage.dart';
import '../pages/settingspage.dart';
import '../pages/contactpage.dart';
import '../pages/venuepage.dart';
import '../pages/versionpage.dart';

class CustomAppBar extends AppBar {
  CustomAppBar(BuildContext context, String title, MenuItemE ignored,
      List<Widget> addActions)
      : super(
            title: Text(title),
            actions: addActions + [getPopupMenu(context, ignored)]);

  static PopupMenuButton<int> getPopupMenu(
      BuildContext context, MenuItemE ignored) {
    return PopupMenuButton<int>(
        // add icon, by default "3 dot" icon
        // icon: Icon(Icons.book)
        itemBuilder: (context) {
      return getItems(context, ignored);
    }, onSelected: (value) {
      switch (MenuItemE.values[value]) {
        case MenuItemE.MAIN:
          goToMainPage(context);
          break;
        case MenuItemE.SETTINGS:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage()),
          );
          break;
        case MenuItemE.CONTACT:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ContactPage()),
          );
          break;
        case MenuItemE.VENUE:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VenuePage()),
          );
          break;
        case MenuItemE.VERSION:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VersionPage()),
          );
          break;
        default:
          break;
      }
    });
  }

  static List<PopupMenuEntry<int>> getItems(
      BuildContext context, MenuItemE ignored) {
    List<PopupMenuEntry<int>> items = [];
    for (var i = 0; i < MenuItemE.COUNT.index; i++) {
      final item = MenuItemE.values[i];
      if (ignored == item) continue;
      // "Über die App" ist kein Ort auf der Anlage: abgesetzt darstellen.
      if (item == MenuItemE.VERSION && items.isNotEmpty) {
        items.add(const PopupMenuDivider(height: 9));
      }
      items.add(MenuItem(context, item));
    }
    return items;
  }
}

enum MenuItemE { MAIN, SETTINGS, CONTACT, VENUE, VERSION, COUNT }

class MenuItem extends PopupMenuItem<int> {
  MenuItem(BuildContext context, MenuItemE value)
      : super(
            value: value.index,
            child: Row(children: [
              Icon(getIcon(value), color: maincolor, size: 22),
              SizedBox(width: 14),
              Text(getText(context, value),
                  style: GoogleFonts.lato(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ]));

  static IconData getIcon(MenuItemE value) {
    switch (value) {
      case MenuItemE.MAIN:
        return Icons.home_outlined;
      case MenuItemE.SETTINGS:
        return Icons.settings_outlined;
      case MenuItemE.CONTACT:
        return Icons.phone_outlined;
      case MenuItemE.VENUE:
        return Icons.directions_outlined;
      case MenuItemE.VERSION:
        return Icons.info_outline;
      default:
        return Icons.circle_outlined;
    }
  }

  static String getText(BuildContext context, MenuItemE value) {
    switch (value) {
      case MenuItemE.MAIN:
        return AppLocalizations.of(context)!.main;
      case MenuItemE.SETTINGS:
        return AppLocalizations.of(context)!.settings;
      case MenuItemE.CONTACT:
        return AppLocalizations.of(context)!.contact;
      case MenuItemE.VENUE:
        return AppLocalizations.of(context)!.venue;
      case MenuItemE.VERSION:
        return AppLocalizations.of(context)!.about;
      default:
        assert(false);
        return "";
    }
  }
}

class ShareButton extends IconButton {
  ShareButton(VoidCallback onPressed)
      : super(onPressed: onPressed, icon: Icon(Icons.share));
}

class TimelineButton extends IconButton {
  TimelineButton(VoidCallback onPressed)
      : super(onPressed: onPressed, icon: Icon(Icons.timeline));
}

class ExportButton extends IconButton {
  ExportButton(VoidCallback onPressed)
      : super(onPressed: onPressed, icon: Icon(Icons.save_alt));
}

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

  static PopupMenuButton getPopupMenu(BuildContext context, MenuItemE ignored) {
    return PopupMenuButton(
        // add icon, by default "3 dot" icon
        // icon: Icon(Icons.book)
        itemBuilder: (context) {
      return getItems(context, ignored);
    }, onSelected: (value) {
      switch (MenuItemE.values[value]) {
        case MenuItemE.MAIN:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
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

  static List<MenuItem> getItems(BuildContext context, MenuItemE ignored) {
    List<MenuItem> items = [];
    for (var i = 0; i < MenuItemE.COUNT.index; i++) {
      if (ignored != MenuItemE.values[i])
        items.add(MenuItem(context, MenuItemE.values[i]));
    }
    return items;
  }
}

enum MenuItemE { MAIN, SETTINGS, CONTACT, VENUE, VERSION, COUNT }

class MenuItem extends PopupMenuItem<int> {
  MenuItem(BuildContext context, MenuItemE value)
      : super(
            value: value.index,
            child: Text(getText(context, value),
                style: GoogleFonts.lato(color: Color(mainredValue))));

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
        return AppLocalizations.of(context)!.version;
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

class CsvButton extends IconButton {
  CsvButton(VoidCallback onPressed)
      : super(
            onPressed: onPressed,
            icon: Image.asset(
              'assets/pics/csv.png',
              color: Colors.white,
            ));
}

class PdfButton extends IconButton {
  PdfButton(VoidCallback onPressed)
      : super(
            onPressed: onPressed,
            icon: Image.asset(
              'assets/pics/pdf_icon_2.png',
              color: Colors.white,
            ));
}

class ExportButton extends IconButton {
  ExportButton(VoidCallback onPressed)
      : super(
            onPressed: onPressed,
            icon: Image.asset(
              'assets/pics/export.png',
              color: Colors.white,
            ));
}

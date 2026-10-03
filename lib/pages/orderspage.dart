import 'package:flutter/material.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:soccerpark/generated/app_localizations.dart';

import '../main.dart';
import '../utils/data.dart';
import '../widgets/appbar.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/space.dart';
import '../widgets/text.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double sep = 8;
    return Scaffold(
        appBar: CustomAppBar(
            context, AppLocalizations.of(context)!.orders, MenuItemE.COUNT, []),
        body: Stack(children: [
          ListView(children: <Widget>[
            Header(),
            AttentionItem(AppLocalizations.of(context)!.orderA1),
            Space(sep),
            AttentionItem(AppLocalizations.of(context)!.orderA2),
            Space(sep),
            AttentionItem(AppLocalizations.of(context)!.orderA3),
            Space(sep),
            AttentionItem(AppLocalizations.of(context)!.orderA4),
            Space(32),
            OrderItem(AppLocalizations.of(context)!.order3),
            Space(sep),
            OrderItem(AppLocalizations.of(context)!.order4),
            Space(sep),
            OrderItem(AppLocalizations.of(context)!.order5),
            Space(sep),
            OrderItem(AppLocalizations.of(context)!.order6),
            Space(sep),
            OrderItem(AppLocalizations.of(context)!.order8),
            Space(sep),
            OrderItem(AppLocalizations.of(context)!.order9),
            Space(sep),
            OrderItem(AppLocalizations.of(context)!.order10),
            Space(sep),
            OrderItem(AppLocalizations.of(context)!.order11),
            Space(10),
            Visibility(
                child: Footer(),
                visible: false,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true)
          ]),
          Column(children: [Spacer(), Footer()])
        ]));
  }
}

class AttentionItem extends StatelessWidget {
  final String text;

  AttentionItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.error, color: maincolor, size: 24),
          SpaceH(4),
          Flexible(child: FloatText(text, left: 6)),
        ]),
      ),
    );
  }
}

class OrderItem extends StatelessWidget {
  final String text;

  OrderItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.check_circle, color: maincolor, size: 24),
          SpaceH(4),
          Flexible(child: FloatText(text, left: 6)),
        ]),
      ),
    );
  }
}

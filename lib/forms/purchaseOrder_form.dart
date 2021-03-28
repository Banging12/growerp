/*
 * This software is in the public domain under CC0 1.0 Universal plus a
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
import 'package:core/templates/@templates.dart';
import 'package:models/@models.dart';
import '@forms.dart';

class PurchaseOrderForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MainTemplate(
      menu: menuItems,
      mapItems: purchaseMap,
      menuIndex: MENU_PURCHASE,
      tabIndex: 0,
    );
  }
}

List<MapItem> purchaseMap = [
  MapItem(
    form: FinDocsForm(sales: false, docType: 'order'),
    label: "Purchase orders",
    icon: Icon(Icons.home),
    floatButtonRoute: "/finDoc",
    floatButtonArgs: FormArguments(
        object: FinDoc(sales: false, docType: 'order', items: []),
        menuIndex: MENU_PURCHASE),
  ),
  MapItem(
      form: UsersForm(
          key: ValueKey("GROWERP_M_SUPPLIER"),
          userGroupId: "GROWERP_M_SUPPLIER",
          menuIndex: MENU_PURCHASE),
      label: "Suppliers",
      icon: Icon(Icons.business),
      floatButtonRoute: "/user",
      floatButtonArgs: FormArguments(
          object: User(userGroupId: "GROWERP_M_SUPPLIER"),
          menuIndex: MENU_PURCHASE)),
];

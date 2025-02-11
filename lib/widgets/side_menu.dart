import 'package:flutter/material.dart';
import '../constants/controllers.dart';
import '../constants/style.dart';
import '../helpers/responsiveness.dart';
import '../routing/routes.dart';
import '../widgets/custom_text.dart';
import '../widgets/side_menu_item.dart';
import 'package:get/get.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({ super.key });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Container(
            color: light,
            child: ListView(
              children: [
                if(ResponsiveWidget.isSmallScreen(context))
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(width: width / 48),
                        Padding(
                          padding: const EdgeInsets.only(right: 0),
                          // child: Image.asset("assets/icons/logo.png", width: 200),

                        ),
                        const Flexible(
                          child: CustomText(
                            text: "TourMate",
                            size: 26,
                            weight: FontWeight.bold,
                            color: active,
                          ),
                        ),
                        SizedBox(width: width / 48),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
                    Divider(color: lightGrey.withOpacity(.1), ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: sideMenuItemRoutes
                      .map((item) => SideMenuItem(
                          itemName: item.name,
                          onTap: () {
                            if(item.route == authenticationPageRoute){
                              Get.offAllNamed(authenticationPageRoute);
                              menuController.changeActiveItemTo(overviewPageDisplayName);

                            }
                            if (!menuController.isActive(item.name)) {
                              menuController.changeActiveItemTo(item.name);
                              // if(ResponsiveWidget.isSmallScreen(context)) {
                              //   Get.back();
                              // }
                              navigationController.navigateTo(item.route);
                            }
                          }))
                      .toList(),
                )
              ],
            ),
          );
  }
}
import 'package:decibelio_app_web/responsive.dart';
import 'package:decibelio_app_web/views/manage_user/components/header.dart';
import 'package:decibelio_app_web/views/manage_user/components/search_field.dart';
import 'package:decibelio_app_web/views/manage_user/components/sensor_status.dart';
import 'package:decibelio_app_web/views/manage_user/components/sensor_table.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: <Widget>[
            const Header(),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      SearchField(
                        onSearchChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      }),
                      const SizedBox(height: 16),
                      SensorTable(searchQuery: _searchQuery),
                      if (Responsive.isMobile(context))
                        const SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context))
                        const Column(
                            children: [
                              //const NoiseLevelTable(),
                              //const SizedBox(height: 16),
                              SensorChart(),
                            ]
                        )
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  const SizedBox(width: defaultPadding),
                // On Mobile means if the screen is less than 850 we don't want to show it
                if (!Responsive.isMobile(context))
                  const Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        //const NoiseLevelTable(),
                        //const SizedBox(height: 16),
                        //RecentFiles(),
                        SensorChart(),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

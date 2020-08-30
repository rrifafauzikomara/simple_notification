import 'package:flutter/material.dart';
import 'package:simple_notification/utils/bundle_data.dart';

class DetailPage extends StatelessWidget {
  static const routeName = '/detail_page';

  @override
  Widget build(BuildContext context) {
    final BundleData arg = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Title: ${arg.payload}'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}

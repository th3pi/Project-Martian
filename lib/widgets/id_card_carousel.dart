import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rounded_modal/rounded_modal.dart';

import '../services/authentication_check.dart';
import '../services/auth_service.dart';
import '../forms/id_form.dart';
import '../models/planet_data.dart';
import 'id_card.dart';
import 'add_id_card.dart';

class IdCardCarousel extends StatefulWidget {
  final String email;
  final BaseAuth auth;

  IdCardCarousel({this.email, this.auth});

  @override
  State<StatefulWidget> createState() {
    return _IdCardCarouselState();
  }
}

enum DataStatus { DETERMINED, NOT_DETERMINED }

class _IdCardCarouselState extends State<IdCardCarousel> {
  DataStatus dataStatus = DataStatus.NOT_DETERMINED;
  PageController pageController;
  int currentPage = 0, numOfIds;
  double page = 2.0;
  double scaleFraction = 0.9,
      fullScale = 1.0,
      pagerHeight = 200,
      viewportFraction = 0.95;
  List<Map<String, dynamic>> listOfIds = [];

  @override
  Widget build(BuildContext context) {
    return _idCardCarousel();
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(
        initialPage: currentPage, viewportFraction: viewportFraction);
    Firestore.instance
        .collection('users')
        .document(widget.email)
        .collection('planetary_ids')
        .snapshots()
        .listen((snapshot) {
      dataStatus =
          snapshot == null ? DataStatus.NOT_DETERMINED : DataStatus.DETERMINED;
      if (snapshot != null) {
        snapshot.documents.forEach((doc) {
          listOfIds.add(doc.data);
          setState(() {
            numOfIds = listOfIds.length + 1;
            currentPage = 0;
          });
        });
      }
    });
  }

  Widget _idCardCarousel() {
    return Container(
      height: 200,
      child: dataStatus == DataStatus.NOT_DETERMINED
          ? SpinKitDualRing(
              color: Colors.deepOrangeAccent,
            )
          : ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                Container(
                  height: pagerHeight,
                  child: NotificationListener<ScrollNotification>(
                    child: PageView.builder(
                      itemBuilder: (context, index) {
                        final scale = max(
                            scaleFraction,
                            (fullScale - (index - page).abs()) +
                                viewportFraction);
                        return index == numOfIds - 1
                            ? AddIdCard(
                                scale: scale,
                                auth: widget.auth,
                                email: widget.email,
                              )
                            : IdCard(
                                index: index,
                                callingFrom: 'home',
                                email: widget.email,
                                auth: widget.auth,
                                scale: scale,
                              );
                      },
                      itemCount: numOfIds,
                      controller: pageController,
                      onPageChanged: (pos) {
                        setState(() {
                          currentPage = pos;
                        });
                      },
                      physics: AlwaysScrollableScrollPhysics(),
                    ),
                    onNotification: (ScrollNotification notification) {
                      if (notification is ScrollUpdateNotification) {
                        setState(() {
                          page = pageController.page;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

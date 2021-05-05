import './common.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './model/place_info_model.dart';
import './model/coupon.dart';
import './model/product.dart';
import './model/feed.dart';
import './screens/coupons_screen.dart';
import './screens/auth_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;
import 'package:uuid/uuid.dart';
import 'package:cloud_functions/cloud_functions.dart';

class Data with ChangeNotifier {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  PlaceInfoModel placeInfo;

  fb.SettableMetadata metadata = fb.SettableMetadata(
    contentType: 'image/png',
  );

  List<Product> listProducts = [];
  List<Product> get getListProducts => listProducts;

  static List<dynamic> types = [];
  List<dynamic> get getTypes => types;

  static int localeIndex;
  int get getLocaleIndex => localeIndex;

  static String localeCode;
  String get getLocaleCode => localeCode;

  void fetchLocaleIndex(context) {
    localeCode = Localizations.localeOf(context).languageCode;
    switch (localeCode) {
      case 'ru':
        localeIndex = 0;
        FirebaseAuth.instance.setLanguageCode('ru');
        break;
      case 'uk':
        localeIndex = 1;
        FirebaseAuth.instance.setLanguageCode('uk');
        break;

      default:
        localeIndex = 0;
        FirebaseAuth.instance.setLanguageCode('uk');
    }
  }

  Future<Map> signIn(
      BuildContext context, String email, String password) async {
    bool isSuccessful = false;
    String errorMessage;
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      final isOwner = checkIsOwner(context);

      if (!isOwner) {
        await FirebaseAuth.instance.signOut().catchError((e) => print(e));
        isSuccessful = false;
      } else {
        isSuccessful = true;
      }
    }).catchError((e) {
      errorMessage = e.code;
      isSuccessful = false;
    });
    if (isSuccessful) {
      fetchTypes();
      fetchLocaleIndex(context);
      ArtBar(context, false, null).navigateRemoved(CouponsScreen());
    }

    return {'isSuccessful': isSuccessful, 'errorMessage': errorMessage};
  }

  Future<Map> loadTerms() async {
    bool isSuccess;
    String terms;
    await firestore.collection('app').doc('terms').get().then((snapshot) {
      terms = snapshot.data()['terms'][localeCode];

      isSuccess = true;
    }).catchError((e) {
      isSuccess = false;
    });
    return {'isSuccess': isSuccess, 'terms': terms};
  }

  bool checkIsOwner(context) =>
      FirebaseAuth.instance.currentUser.uid == 'eTn70vqf6iSAhNoTfoSvlCZQA0V2'
          ? true
          : false;

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut().then((value) {
      ArtBar(context, false, null).navigateRemoved(AuthScreen());
    }).catchError((e) => LoadingDialog().showError(context, e.code));
  }

  String generateUniqueId() {
    return Uuid().v1().substring(1, 6);
  }

  Future<bool> fetchTypes() async {
    types = [];
    bool isSuccess = true;
    try {
      await firestore.collection('app').doc('place').get().then((snapshot) {
        snapshot.data()['types'].entries.forEach((MapEntry doc) {
          types.add(doc.value);
        });
        isSuccess = true;
      });
    } catch (e) {
      print(e);
      isSuccess = false;
    }

    return isSuccess;
  }

  Future<Map> loadEmployers() async {
    List<dynamic> employers = [];
    bool success = false;
    await firestore.collection('app').doc('employers').get().then((snapshot) {
      snapshot.data()['employers'].forEach((key, value) {
        employers.add(value);
        success = true;
      });
    }).catchError((e) {
      success = false;
    });
    return {'employers': employers, 'success': success};
  }

  Future<bool> uploadEmployers(List<dynamic> employers) async {
    bool success = true;
    Map employersMap =
        Map.fromIterable(employers, key: (v) => v[0], value: (v) => v);

    await firestore
        .collection('app')
        .doc('employers')
        .set({'employers': employersMap}).catchError((e) {
      success = false;
    });
    return success;
  }

  Future<PlaceInfoModel> loadPlaceInfo() async {
    await firestore.collection('app').doc('place').get().then((value) {
      placeInfo = new PlaceInfoModel(
          title: value.data()['title'],
          time: value.data()['time'],
          address: value.data()['address'],
          addressUrl: value.data()['addressUrl'],
          addressImages: value.data()['addressImages'],
          images: value.data()['images'],
          phone: value.data()['phone'],
          site: value.data()['site'],
          types: types,
          nutrValue: value.data()['nutrValue']);
    }).catchError((onError) {});

    return placeInfo;
  }

  Future<bool> uploadChangedPlaceInfo(
      BuildContext context, PlaceInfoModel editedPlace) async {
    bool wasSuccessful;
    Map types =
        Map.fromIterable(editedPlace.types, key: (v) => v[0], value: (v) => v);
    await firestore.collection('app').doc('place').update({
      'title': editedPlace.title,
      'address': editedPlace.address,
      'addressUrl': editedPlace.addressUrl,
      'addressImages': editedPlace.addressImages,
      'time': editedPlace.time,
      'images': editedPlace.images,
      'phone': editedPlace.phone,
      'site': editedPlace.site,
      'types': types,
      'nutrValue': editedPlace.nutrValue
    }).then((value) {
      wasSuccessful = true;
    }).catchError((onError) {
      wasSuccessful = false;
    });
    return wasSuccessful;
  }

  Future<bool> deleteCouponFunction(
      String createMode, String couponId, String expirationTask) async {
    bool success = true;
    if (createMode == 'current') {
      await firestore
          .collection('coupons')
          .doc(couponId)
          .delete()
          .catchError((e) {
        success = false;
      });
    } else if (createMode == 'scheduled') {
      await firestore
          .collection('scheduledcoupons')
          .doc(couponId)
          .delete()
          .catchError((e) {
        success = false;
      });
    }
    return success;
  }

  Future<List<dynamic>> loadGallery(bool allowMultiple) async {
    List<dynamic> listGallery = [];

    if (allowMultiple) {
      fb.ListResult results = await fb.FirebaseStorage.instance
          .ref('images/resized')
          .listAll()
          .catchError((e) {
        print(e);
      }).catchError((e) {
        print(e);
      });

      for (var image in results.items) {
        listGallery.add(await image.getDownloadURL());
      }
    } else {
      final nutrValue = await fb.FirebaseStorage.instance
          .ref('images/resized/nutrValue')
          .getDownloadURL()
          .catchError((e) {});
      if (nutrValue != null) listGallery.add(nutrValue);
    }
    return listGallery.reversed.toList();
  }

  Future<bool> pickDiskImages(context, bool withCompression) async {
    bool isSuccessful = true;
    List<Uint8List> listImages = [];

    FilePickerResult results = await FilePicker.platform
        .pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: withCompression,
    )
        .catchError((e) {
      print('fsdfsdfsdfs');
    });

    if (results == null) {
      return false;
    }
    LoadingDialog().showLoad(context);

    if (results != null)
      for (var result in results.files) {
        listImages.add(result.bytes);
      }

    for (var image in listImages) {
      final imageId = generateUniqueId();
      fb.Reference refWithCompression =
          fb.FirebaseStorage.instance.ref('images/$imageId.png');

      fb.Reference refWithoutCompression =
          fb.FirebaseStorage.instance.ref('images/resized/nutrValue');

      if (withCompression)
        await refWithCompression
            .putData(image, metadata)
            .then((v) => null)
            .catchError((onError) {
          print(onError);
          isSuccessful = false;
        });
      else
        await refWithoutCompression
            .putData(image, metadata)
            .then((v) => null)
            .catchError((onError) {
          print(onError);
          isSuccessful = false;
        });
    }
    LoadingDialog().dispLoad();
    return isSuccessful;
  }

  Future<bool> deleteImageFromGallery(
      List<dynamic> images, String image) async {
    bool isSuccess;
    await fb.FirebaseStorage.instance
        .refFromURL(image)
        .delete()
        .then((value) => isSuccess = true)
        .catchError((e) {
      print(e);
      isSuccess = false;
    });
    return isSuccess;
  }

  Future<List<Product>> loadProducts() async {
    listProducts = [];
    await firestore
        .collection('products')
        .get()
        .then((snapshot) => snapshot.docs.forEach((doc) {
              listProducts.add(
                Product(
                  productId: doc.data()['productId'],
                  title: doc.data()['title'],
                  images: doc.data()['images'],
                  price: doc.data()['price'],
                  description: doc.data()['description'],
                  type: doc.data()['type'],
                ),
              );
            }))
        .catchError((onError) {});
    return listProducts;
  }

  Future<Map<String, dynamic>> uploadNewProduct(Product product) async {
    final String productId = generateUniqueId();
    bool success = true;
    await firestore.collection('products').doc(productId).set({
      'productId': productId,
      'title': product.title,
      'images': product.images,
      'price': product.price,
      'description': product.description,
      'type': product.type,
    }).catchError((e) {
      success = false;
    });
    return {'success': success, 'error': null};
  }

  Future<Map> uploadChangedProduct(Product product) async {
    bool success = true;
    await firestore.collection('products').doc(product.productId).update({
      'title': product.title,
      'images': product.images,
      'price': product.price,
      'description': product.description,
      'type': product.type,
    }).catchError((e) {
      print(e);
      success = false;
    });
    return {'success': success, 'error': null};
  }

  Future<bool> deleteProduct(Product product) async {
    bool success = true;
    await firestore
        .collection('products')
        .doc(product.productId)
        .delete()
        .catchError((e) {
      success = false;
    });
    return success;
  }

  Future<List<Coupon>> loadCurrentCoupons() async {
    final List<Coupon> listCurrentCoupons = [];

    await firestore
        .collection('coupons')
        .get()
        .then((value) => value.docs.forEach((doc) {
              print(doc.data()['title']);
              DateTime startDate = doc.data()['startDate'].toDate();
              DateTime expirationDate = doc.data()['expirationDate'].toDate();

              listCurrentCoupons.add(new Coupon(
                couponId: doc.data()['couponId'],
                title: doc.data()['title'],
                images: doc.data()['images'],
                price: doc.data()['price'],
                description: doc.data()['description'],
                startDate: startDate,
                expirationDate: expirationDate,
                type: doc.data()['type'],
                expirationTask: doc.data()['expirationTask'],
                restartHours: doc.data()['restartHours'],
                expirationMinutes: doc.data()['expirationMinutes'],
              ));
            }))
        .catchError((onError) {});

    return listCurrentCoupons;
  }

  Future<List<Coupon>> loadScheduledCoupons() async {
    final List<Coupon> listScheduledCoupons = [];

    await firestore.collection('scheduledcoupons').get().then((value) {
      value.docs.forEach((doc) {
        DateTime startDate = doc.data()['startDate'].toDate();
        DateTime expirationDate = doc.data()['expirationDate'].toDate();

        listScheduledCoupons.add(new Coupon(
          couponId: doc.data()['couponId'],
          title: doc.data()['title'],
          images: doc.data()['images'],
          price: doc.data()['price'],
          description: doc.data()['description'],
          startDate: startDate,
          expirationDate: expirationDate,
          type: doc.data()['type'],
          restartHours: doc.data()['restartHours'],
          expirationMinutes: doc.data()['expirationMinutes'],
        ));
      });
    }).catchError((onError) {});

    listScheduledCoupons.sort(
        (a, b) => b.startDate.toString().compareTo(a.startDate.toString()));
    listScheduledCoupons.forEach((coupon) {
      coupon.stringStartDate =
          DateFormat('EEE, d/M/y').format(coupon.startDate);
      coupon.stringExpirationDate =
          DateFormat('EEE, d/M/y').format(coupon.expirationDate);
    });
    return listScheduledCoupons;
  }

  Future<Map> uploadChangedCoupon(Coupon coupon, String couponMode) async {
    bool success = true;

    if (couponMode == 'current') {
      print('cur=');
      await firestore.collection('coupons').doc(coupon.couponId).update({
        'title': coupon.title,
        'images': coupon.images,
        'price': coupon.price,
        'restartHours': coupon.restartHours,
        'expirationMinutes': coupon.expirationMinutes,
        'description': coupon.description,
        'type': coupon.type,
      }).catchError((onError) {
        success = false;
      });
      if (couponMode == 'scheduled') {
        print('sch==');
        await firestore
            .collection('scheduledcoupons')
            .doc(coupon.couponId)
            .update({
          'title': coupon.title,
          'images': coupon.images,
          'price': coupon.price,
          'restartHours': coupon.restartHours,
          'expirationMinutes': coupon.expirationMinutes,
          'description': coupon.description,
          'type': coupon.type,
        }).catchError((onError) {
          success = false;
        });
      }
    }
    return {'success': success, 'error': null};
  }

  Future<Map> uploadNewCoupon(Coupon coupon) async {
    bool success = true;
    final couponId = generateUniqueId();

    await firestore
        .collection('scheduledcoupons')
        .doc(couponId)
        .set({
          'couponId': couponId,
          'title': coupon.title,
          'price': coupon.price,
          'description': coupon.description,
          'images': coupon.images,
          'startDate': coupon.startDate,
          'expirationDate': coupon.expirationDate,
          'type': coupon.type,
          'restartHours': coupon.restartHours,
          'expirationMinutes': coupon.expirationMinutes,
        })
        .then((value) {})
        .catchError((e) {
          success = false;
        });

    return {'success': success, 'error': null};
  }

  Future<List<Feed>> loadScheduledFeeds() async {
    final List<Feed> list = [];

    await firestore.collection('scheduledfeeds').get().then((snapshot) {
      for (var doc in snapshot.docs) {
        DateTime startDate = doc.data()['startDate'].toDate();
        list.add(Feed(
          feedId: doc.id,
          description: doc.data()['description'],
          title: doc.data()['title'],
          startDate: startDate,
          startTask: doc.data()['startTask'],
          images: doc.data()['images'],
        ));
      }
    }).catchError((e) {});
    return list;
  }

  Future<List<Feed>> loadCurrentFeeds() async {
    final List<Feed> list = [];

    await firestore.collection('feeds').get().then((snapshot) {
      for (var doc in snapshot.docs) {
        DateTime startDate = doc.data()['startDate'].toDate();
        list.add(Feed(
          feedId: doc.id,
          description: doc.data()['description'],
          title: doc.data()['title'],
          startDate: startDate,
          expirationTask: doc.data()['expirationTask'],
          images: doc.data()['images'],
        ));
      }
    }).catchError((e) {});
    return list;
  }

  Future<Map<String, dynamic>> uploadNewFeed(Feed feed) async {
    bool success = true;
    final String feedId = generateUniqueId();
    await firestore.collection('scheduledfeeds').doc(feedId).set({
      'feedId': feedId,
      'title': feed.title,
      'description': feed.description,
      'startDate': feed.startDate,
      'images': feed.images
    }).catchError((e) {
      success = false;
    });
    return {'success': success, 'error': null};
  }

  Future<Map> uploadChangedFeed(Feed feed, String isCurrent) async {
    bool success = true;
    if (isCurrent == 'current')
      await firestore.collection('feeds').doc(feed.feedId).update({
        'title': feed.title,
        'description': feed.description,
        'images': feed.images
      }).catchError((e) {
        success = false;
      });
    if (isCurrent == 'scheduled')
      await firestore.collection('scheduledfeeds').doc(feed.feedId).update({
        'title': feed.title,
        'description': feed.description,
        'images': feed.images
      }).catchError((e) {
        success = false;
      });
    return {'success': success, 'error': null};
  }

  Future<bool> deleteFeedFunction(Feed feed, String mode) async {
    bool success = true;
    if (mode == 'current') {
      await firestore
          .collection('feeds')
          .doc(feed.feedId)
          .delete()
          .catchError((e) {
        success = false;
      });
    } else if (mode == 'scheduled') {
      await firestore
          .collection('scheduledfeeds')
          .doc(feed.feedId)
          .delete()
          .catchError((e) {
        success = false;
      });
    }
    return success;
  }

  Future<int> getTime() async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
      'currentTime',
    );
    final results = await callable.call().catchError((e) {});
    return results.data['response'];
  }
}

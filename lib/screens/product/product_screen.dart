import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodika/functions/show_error_dialog.dart';
import 'package:foodika/screens/product/product_select_category_screen.dart';
import 'package:foodika/screens/product/widget/edit_product_name_dialog.dart';
import 'package:foodika/screens/products/products_from_category_screen.dart';
import 'package:foodika/screens/profile/edit_name_dialog.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:foodika/core/models/product_model.dart';
import 'package:foodika/core/models/review_model.dart';
import 'package:foodika/core/services/auth_service.dart';
import 'package:foodika/core/services/categories_service.dart';
import 'package:foodika/core/services/fav_service.dart';
import 'package:foodika/core/services/products_service.dart';
import 'package:foodika/functions/get_language_value_from_map.dart';
import 'package:foodika/functions/show_loading_dialog.dart';
import 'package:foodika/screens/auth/auth_login_screen.dart';
import 'package:foodika/screens/product/widget/rate_dialog.dart';
import 'package:foodika/screens/product/widget/review_widget.dart';
import 'package:foodika/screens/products/products_best_from_category_screen.dart';
import 'package:foodika/style/app_colors.dart';
import 'package:foodika/style/app_text_style.dart';
import 'package:foodika/widget/app_bar_widget.dart';
import 'package:foodika/widget/cached_image_widget.dart';
import 'package:foodika/widget/product_widget.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({
    super.key,
    required this.product,
  });
  final ProductModel product;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool isBestProductsLoaded = false;
  List<ProductModel>? bestProducts = [];
  late ProductModel product;
  int _current = 0;

  List<ReviewModel> reviews = [];
  bool isLoadedReviews = false;
  bool isNoMoreRevies = false;

  @override
  void initState() {
    product = widget.product;
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo({
    bool isNeedInfoAboutProduct = false,
    bool isNeedBestProducts = true,
  }) async {
    var service = Get.find<CategoriesService>();

    if (isNeedBestProducts) {
      if (product.categoryId == null) {
        bestProducts = null;
      } else {
        var res = await service.getBestProductsFromCategory(
          categoryId: product.categoryId!,
          count: 27,
          productBarcode: product.barcode,
        );
        bestProducts = [...res.products];
      }
      isBestProductsLoaded = true;
    }

    isLoadedReviews = false;
    var productsService = Get.find<ProductsService>();
    reviews = await productsService.getReviews(product.barcode);
    isLoadedReviews = true;
    if (reviews.isEmpty) isNoMoreRevies = true;

    if (isNeedInfoAboutProduct) {
      product = await productsService.getProduct(product.barcode);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget.titleAndBack('Details'.tr),
      body: ListView(
        padding: EdgeInsets.only(
          top: 15,
          bottom: Get.mediaQuery.viewPadding.bottom + 20,
        ),
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: product.productDescription == null
                ? Row(
                    children: [
                      Text(
                        'Unknown'.tr,
                        style: TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 0,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  contentPadding: EdgeInsets.zero,
                                  content: EditProductNameDialog(
                                    barcode: product.barcode,
                                    onSet: (newProduct) {
                                      setState(() => product = newProduct);
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          child: SvgPicture.asset('assets/edit.svg'),
                        ),
                      )
                    ],
                  )
                : Text(
                    getLanguageValue(product.productDescriptionToMap()),
                    style: TextStyle(
                      color: AppColors.orange,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
          const SizedBox(height: 25),

          _buildPhotos(),

          //Tap to rate
          Builder(builder: (context) {
            var user = Get.find<AuthService>().user;

            if (user != null) {
              var isContains = user.productIdsRate.contains(
                widget.product.barcode,
              );
              if (isContains) {
                return const SizedBox(height: 0, width: 0);
              }
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 15),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      var user = Get.find<AuthService>().user;
                      if (user == null) {
                        Get.to(() => const AuthLoginScreen());
                        return;
                      }
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            contentPadding: EdgeInsets.zero,
                            content: RateDialog(
                              product: product,
                              initStar: 0,
                              onRatePublish: () async {
                                await _loadInfo(
                                  isNeedBestProducts: false,
                                  isNeedInfoAboutProduct: true,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      'YOUR RATE'.tr,
                      style: TextStyle(
                        color: AppColors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 0,
                        onPressed: () {
                          var user = Get.find<AuthService>().user;
                          if (user == null) {
                            Get.to(() => const AuthLoginScreen());
                            return;
                          }
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                contentPadding: EdgeInsets.zero,
                                content: RateDialog(
                                  product: product,
                                  initStar: 1,
                                  onRatePublish: () async {
                                    await _loadInfo(
                                      isNeedBestProducts: false,
                                      isNeedInfoAboutProduct: true,
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                        child: SvgPicture.asset(
                          'assets/star.svg',
                          color: const Color(0xFFA19CA9),
                          height: 22,
                          width: 22,
                        ),
                      ),
                      const SizedBox(width: 15),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 0,
                        onPressed: () {
                          var user = Get.find<AuthService>().user;
                          if (user == null) {
                            Get.to(() => const AuthLoginScreen());
                            return;
                          }
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                contentPadding: EdgeInsets.zero,
                                content: RateDialog(
                                  product: product,
                                  initStar: 2,
                                  onRatePublish: () async {
                                    await _loadInfo(
                                      isNeedBestProducts: false,
                                      isNeedInfoAboutProduct: true,
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                        child: SvgPicture.asset(
                          'assets/star.svg',
                          color: const Color(0xFFA19CA9),
                          height: 22,
                          width: 22,
                        ),
                      ),
                      const SizedBox(width: 15),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 0,
                        onPressed: () {
                          var user = Get.find<AuthService>().user;
                          if (user == null) {
                            Get.to(() => const AuthLoginScreen());
                            return;
                          }
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                contentPadding: EdgeInsets.zero,
                                content: RateDialog(
                                  product: product,
                                  initStar: 3,
                                  onRatePublish: () async {
                                    await _loadInfo(
                                      isNeedBestProducts: false,
                                      isNeedInfoAboutProduct: true,
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                        child: SvgPicture.asset(
                          'assets/star.svg',
                          color: const Color(0xFFA19CA9),
                          height: 22,
                          width: 22,
                        ),
                      ),
                      const SizedBox(width: 15),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 0,
                        onPressed: () {
                          var user = Get.find<AuthService>().user;
                          if (user == null) {
                            Get.to(() => const AuthLoginScreen());
                            return;
                          }
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                contentPadding: EdgeInsets.zero,
                                content: RateDialog(
                                  product: product,
                                  initStar: 4,
                                  onRatePublish: () async {
                                    await _loadInfo(
                                      isNeedBestProducts: false,
                                      isNeedInfoAboutProduct: true,
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                        child: SvgPicture.asset(
                          'assets/star.svg',
                          color: const Color(0xFFA19CA9),
                          height: 22,
                          width: 22,
                        ),
                      ),
                      const SizedBox(width: 15),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 0,
                        onPressed: () {
                          var user = Get.find<AuthService>().user;
                          if (user == null) {
                            Get.to(() => const AuthLoginScreen());
                            return;
                          }
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                contentPadding: EdgeInsets.zero,
                                content: RateDialog(
                                  product: product,
                                  initStar: 5,
                                  onRatePublish: () async {
                                    await _loadInfo(
                                      isNeedBestProducts: false,
                                      isNeedInfoAboutProduct: true,
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                        child: SvgPicture.asset(
                          'assets/star.svg',
                          color: const Color(0xFFA19CA9),
                          height: 22,
                          width: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      var user = Get.find<AuthService>().user;
                      if (user == null) {
                        Get.to(() => const AuthLoginScreen());
                        return;
                      }
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            contentPadding: EdgeInsets.zero,
                            content: RateDialog(
                              product: product,
                              initStar: 0,
                              onRatePublish: () async {
                                await _loadInfo(
                                  isNeedBestProducts: false,
                                  isNeedInfoAboutProduct: true,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: Center(
                      child: Text(
                        'Tap to rate'.tr,
                        style: const TextStyle(
                          color: Color(0xFFA19CA9),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
          //Product details
          Container(
            margin: const EdgeInsets.only(left: 20, top: 20),
            child: Text(
              'Product Details'.tr,
              style: AppTextStyle.buttonText.copyWith(
                color: AppColors.orange,
              ),
            ),
          ),
          GetBuilder<CategoriesService>(builder: (service) {
            var categories = service.categories;
            var category = categories.firstWhereOrNull(
              (e) => e.id == product.categoryId,
            );
            var text = category == null
                ? 'Unknown'.tr
                : getLanguageValue(category.name);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: _buildOption(
                    'Category'.tr,
                    text,
                    onPressed: category == null
                        ? null
                        : () async {
                            Get.to(
                              () => ProductsFromCategoryScreen(
                                category: category,
                              ),
                            );
                          },
                  ),
                ),
                category == null
                    ? Container(
                        margin: const EdgeInsets.only(left: 10, top: 10),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 0,
                          onPressed: () {
                            Get.to(
                              () => ProductSelectCategoryScreen(
                                barcode: product.barcode,
                                onSet: (newProduct) {
                                  setState(() => product = newProduct);
                                },
                              ),
                            );
                          },
                          child: SvgPicture.asset('assets/edit.svg'),
                        ),
                      )
                    : const SizedBox(height: 0, width: 0),
              ],
            );
          }),
          _buildOption('Brand'.tr, getLanguageValue(product.brandNameToMap())),
          _buildOption(
            'Country'.tr,
            product.countryOfSaleCode?.isEmpty ?? true
                ? 'Unknown'.tr
                : product.countryOfSaleCode!.first.alpha3 ?? 'Unknown'.tr,
          ),
          //best products button
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Builder(builder: (context) {
              if (bestProducts == null && isBestProductsLoaded == true ||
                  product.categoryId == null) {
                return const SizedBox(height: 0, width: 0);
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: Text(
                              'Best Products'.tr,
                              style: AppTextStyle.header2.copyWith(
                                color: AppColors.text,
                              ),
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 0,
                          onPressed: () {
                            showErrorDialog(
                              context,
                              title: 'The best products in this category'.tr,
                              content: null,
                              okButtonText: 'Ok'.tr,
                            );
                          },
                          child: Icon(
                            Icons.info_outline,
                            size: 22,
                            color: AppColors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      if (product.categoryId == null) return;
                      Get.to(
                        () => ProductsBestFromCategoryScreen(
                          categoryId: product.categoryId!,
                          productBarcode: product.barcode,
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    child: Text(
                      'See all'.tr,
                      style: AppTextStyle.titleText.copyWith(
                        color: AppColors.orange,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          //best products list
          SizedBox(
            height: bestProducts == null && isBestProductsLoaded == true ||
                    product.categoryId == null
                ? 0
                : 155,
            child: Builder(builder: (context) {
              if (isBestProductsLoaded == false) {
                return CupertinoActivityIndicator(
                  color: AppColors.orange,
                  radius: 13,
                );
              }

              if (bestProducts == null) {
                return const SizedBox(height: 0, width: 0);
              }

              if (bestProducts!.isEmpty) {
                return Center(
                  child: Text(
                    'There are no products'.tr,
                    style: AppTextStyle.bodyText.copyWith(
                      color: AppColors.middleGrey,
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: bestProducts!.length,
                padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Container(
                    width: 102.5,
                    margin: const EdgeInsets.only(right: 20),
                    child: ProductWidget(
                      product: bestProducts![index],
                    ),
                  );
                },
              );
            }),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text(
              'Reviews'.tr,
              style: AppTextStyle.header2.copyWith(
                color: AppColors.text,
              ),
            ),
          ),
          _buildReviews(),
        ],
      ),
    );
  }

  Widget _buildOption(
    String category,
    String text, {
    void Function()? onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 10),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$category:   ',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ).copyWith(color: AppColors.darkGrey),
            ),
            TextSpan(
              text: text,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  if (onPressed != null) onPressed();
                },
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ).copyWith(
                color:
                    onPressed != null ? AppColors.orange : AppColors.darkGrey,
                decoration: onPressed == null ? null : TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotos() {
    if (product.photoUrls.isEmpty) {
      return Column(
        children: [
          GestureDetector(
            onTap: () async {
              showCupertinoModalPopup(
                context: context,
                builder: (context) {
                  return CupertinoActionSheet(
                    actions: <CupertinoActionSheetAction>[
                      CupertinoActionSheetAction(
                        onPressed: () async {
                          Navigator.pop(context);
                          var file = await ImagePicker().pickImage(
                            source: ImageSource.camera,
                            imageQuality: 50,
                          );
                          if (file == null) return;
                          showLoadingDialog();
                          var service = Get.find<ProductsService>();
                          product = await service.savePhotosToProduct(
                            [file.path],
                            product.barcode,
                          );
                          setState(() {});
                          Get.back();
                        },
                        child: Text(
                          'Camera'.tr,
                          style: AppTextStyle.buttonText.copyWith(
                            color: AppColors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      CupertinoActionSheetAction(
                        onPressed: () async {
                          Navigator.pop(context);
                          var files = await ImagePicker().pickMultiImage(
                            imageQuality: 50,
                          );
                          if (files.isEmpty) return;
                          showLoadingDialog();
                          var service = Get.find<ProductsService>();
                          product = await service.savePhotosToProduct(
                            files.map((e) => e.path).toList(),
                            product.barcode,
                          );
                          setState(() {});
                          Get.back();
                        },
                        child: Text(
                          'Gallery'.tr,
                          style: AppTextStyle.buttonText.copyWith(
                            color: AppColors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel'.tr,
                        style: AppTextStyle.buttonText.copyWith(
                          color: AppColors.orange,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            child: Column(
              children: [
                SvgPicture.asset('assets/product_empty_photos.svg'),
                Center(
                  child: Text(
                    'Add photo'.tr,
                    style: TextStyle(
                      color: AppColors.orange,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    'There are no photos of this product yet. Be the first to share a photo of this product!'
                        .tr,
                    style: const TextStyle(
                      color: Color(0xFF6B6770),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildRatingAndFav(),
        ],
      );
    }
    if (product.photoUrls.length > 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: Get.height * 0.275,
              autoPlay: false,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              },
            ),
            items: product.photoUrls.map((i) {
              return SizedBox(
                width: Get.width,
                child: CachedImageWidget(
                  imageUrl: i.value,
                  fit: BoxFit.contain,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: product.photoUrls.map((entry) {
              var index = product.photoUrls.indexOf(entry);
              return AnimatedContainer(
                duration: 150.milliseconds,
                width: _current == index ? 22 : 12,
                height: 6,
                margin: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: _current == index
                      ? AppColors.orange
                      : const Color(0xFFD9D9D9),
                ),
              );
            }).toList(),
          ),
          _buildRatingAndFav(),
        ],
      );
    }
    return Column(
      children: [
        Container(
          width: Get.width,
          height: Get.height * 0.275,
          margin: const EdgeInsets.only(bottom: 5),
          child: CachedImageWidget(
            imageUrl: product.photoUrls.first.value,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 2.5),
        _buildRatingAndFav(),
      ],
    );
  }

  Widget _buildRatingAndFav() {
    return GetBuilder<FavService>(builder: (favService) {
      var favBarcodes = favService.favIds;
      return Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Color(0xFF6B6770),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(
                  'assets/star.svg',
                  color: const Color(0xFFFCAF23),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${product.rate.allCount})',
                  style: const TextStyle(
                    color: Color(0xFF6B6770),
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () async {
                var userId = Get.find<AuthService>().user?.id;
                if (userId == null) {
                  Get.to(() => const AuthLoginScreen());
                  return;
                }
                await favService.favToogle(product.barcode, product);
              },
              child: Container(
                padding: const EdgeInsets.all(6.5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: favBarcodes.contains(product.barcode)
                      ? AppColors.orange
                      : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A1919).withOpacity(0.25),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    favBarcodes.contains(product.barcode)
                        ? Icons.favorite
                        : Icons.favorite_outline,
                    color: favBarcodes.contains(product.barcode)
                        ? Colors.white
                        : AppColors.orange,
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }

  Widget _buildReviews() {
    if (isLoadedReviews == false) {
      return Container(
        margin: EdgeInsets.only(
          top: 60,
          bottom: Get.mediaQuery.viewPadding.bottom + 30,
        ),
        alignment: Alignment.center,
        child: CupertinoActivityIndicator(
          color: AppColors.orange,
          radius: 13,
        ),
      );
    }

    if (reviews.isEmpty) {
      return Container(
        margin: EdgeInsets.only(
          top: 60,
          bottom: Get.mediaQuery.viewPadding.bottom + 30,
        ),
        alignment: Alignment.center,
        child: Text(
          'There are no reviews'.tr,
          style: AppTextStyle.bodyText.copyWith(
            color: AppColors.middleGrey,
          ),
        ),
      );
    }

    return Column(
      children: reviews
          .map(
            (e) => ReviewWidget(
              review: e,
              product: product,
              onToggleLike: (newWhoLiked, countLikes) {
                var index = reviews.indexOf(e);
                reviews[index].whoLikeIds = newWhoLiked;
                reviews[index].countLikes = countLikes;
                setState(() {});
              },
              onReviewEditOrDelete: () async {
                _loadInfo(
                    isNeedBestProducts: false, isNeedInfoAboutProduct: true);
              },
            ),
          )
          .toList(),
    );
  }
}

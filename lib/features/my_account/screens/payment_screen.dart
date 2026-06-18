import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:siame_delivery/helper/route_helper.dart';
import 'package:siame_delivery/util/dimensions.dart';
import 'package:siame_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:siame_delivery/features/my_account/widgets/fund_payment_dialog_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentScreen extends StatefulWidget {
  final String paymentMethod;
  final String? redirectUrl;
  const PaymentScreen({super.key, required this.paymentMethod, this.redirectUrl});

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  late String selectedUrl;
  double value = 0.0;
  final bool _isLoading = true;
  PullToRefreshController? pullToRefreshController;
  late MyInAppBrowser browser;
  double? maxCodOrderAmount;

  @override
  void initState() {
    super.initState();
    selectedUrl = widget.redirectUrl!;
    _initData();
  }

  void _initData() async {
    browser = MyInAppBrowser(redirectUrl: widget.redirectUrl);

    if (GetPlatform.isAndroid) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);

      bool swAvailable = await WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_BASIC_USING);
      bool swInterceptAvailable = await WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

      if (swAvailable && swInterceptAvailable) {
        ServiceWorkerController serviceWorkerController = ServiceWorkerController.instance();
        await serviceWorkerController.setServiceWorkerClient(ServiceWorkerClient(
          shouldInterceptRequest: (request) async {
            if (kDebugMode) {
              print(request);
            }
            return null;
          },
        ));
      }
    }

    await browser.openUrlRequest(
      urlRequest: URLRequest(url: WebUri(selectedUrl)),
      settings: InAppBrowserClassSettings(
        webViewSettings: InAppWebViewSettings(useShouldOverrideUrlLoading: true, useOnLoadResource: true),
        browserSettings: InAppBrowserSettings(hideUrlBar: true, hideToolbarTop: GetPlatform.isAndroid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        _exitApp().then((value) => value);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: CustomAppBarWidget(title: 'payment'.tr, onTap: _exitApp),
        body: Center(
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: Stack(
              children: [
                _isLoading ? Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                ) : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _exitApp() async {
    return Get.dialog(const FundPaymentDialogWidget());
  }

}

class MyInAppBrowser extends InAppBrowser {
  final String? redirectUrl;
  MyInAppBrowser({super.windowId, super.initialUserScripts, this.redirectUrl});

  final bool _canRedirect = true;

  Future<void> _openExternalUrl(String raw) async {
    try {
      final String maxItStoreUrl = defaultTargetPlatform == TargetPlatform.iOS
          ? 'https://apps.apple.com/app/id1039327980'
          : 'https://play.google.com/store/apps/details?id=com.orange.myorange.osn';

      if (raw.startsWith('intent://') || raw.startsWith('intent:/')) {
        String correctedUrl = raw;
        if (raw.startsWith('intent:/') && !raw.startsWith('intent://')) {
          correctedUrl = raw.replaceFirst('intent:/', 'intent://');
        }
        try {
          final Uri intentUri = Uri.parse(correctedUrl);
          await launchUrl(intentUri, mode: LaunchMode.externalApplication);
          return;
        } catch (e) {
          if (kDebugMode) {
            print('Erreur lors de l\'ouverture de Max It avec l\'URL: $correctedUrl - $e');
          }
        }
        await launchUrl(Uri.parse(maxItStoreUrl), mode: LaunchMode.externalApplication);
        return;
      }
      if (raw.startsWith('wave://capture/')) {
        final String afterCapture = raw.substring('wave://capture/'.length);
        final Uri waveUri = Uri.parse(raw);
        if (await canLaunchUrl(waveUri)) {
          await launchUrl(waveUri, mode: LaunchMode.externalApplication);
          return;
        }
        final Uri httpsUri = Uri.parse(afterCapture);
        await launchUrl(httpsUri, mode: LaunchMode.externalApplication);
        return;
      }

      if (raw.startsWith('maxit://') || raw.startsWith('maxit:/')) {
        String correctedUrl = raw;
        if (raw.startsWith('maxit:/') && !raw.startsWith('maxit://')) {
          correctedUrl = raw.replaceFirst('maxit:/', 'maxit://');
        }
        try {
          final Uri maxItUri = Uri.parse(correctedUrl);
          await launchUrl(maxItUri, mode: LaunchMode.externalApplication);
          return;
        } catch (e) {
          if (kDebugMode) {
            print('Erreur lors de l\'ouverture de Max It avec l\'URL: $correctedUrl - $e');
          }
        }
        await launchUrl(Uri.parse(maxItStoreUrl), mode: LaunchMode.externalApplication);
        return;
      }

      if (raw.startsWith('sameaosnapp://') || raw.startsWith('sameaosnapp:/')) {
        String correctedUrl = raw;
        if (raw.startsWith('sameaosnapp:/') && !raw.startsWith('sameaosnapp://')) {
          correctedUrl = raw.replaceFirst('sameaosnapp:/', 'sameaosnapp://');
        }
        try {
          final Uri maxItUri = Uri.parse(correctedUrl);
          await launchUrl(maxItUri, mode: LaunchMode.externalApplication);
          return;
        } catch (e) {
          if (kDebugMode) {
            print('Erreur lors de l\'ouverture de Max It avec l\'URL: $correctedUrl - $e');
          }
        }
        await launchUrl(Uri.parse(maxItStoreUrl), mode: LaunchMode.externalApplication);
        return;
      }

      if (raw.startsWith('orangemoney://') || 
          raw.startsWith('orange-money://') || 
          raw.startsWith('om://')) {
        final Uri orangeMoneyUri = Uri.parse(raw);
        if (await canLaunchUrl(orangeMoneyUri)) {
          await launchUrl(orangeMoneyUri, mode: LaunchMode.externalApplication);
          return;
        }
        final String orangeMoneyStoreUrl = defaultTargetPlatform == TargetPlatform.iOS
            ? 'https://apps.apple.com/app/orange-money-senegal/id1447224280'
            : 'https://play.google.com/store/apps/details?id=com.orange.orangemoney';
        await launchUrl(Uri.parse(orangeMoneyStoreUrl), mode: LaunchMode.externalApplication);
        return;
      }

      if (raw.startsWith('wave://')) {
        final Uri waveUri = Uri.parse(raw);
        if (await canLaunchUrl(waveUri)) {
          await launchUrl(waveUri, mode: LaunchMode.externalApplication);
          return;
        }
        final String waveStoreUrl = defaultTargetPlatform == TargetPlatform.iOS
            ? 'https://apps.apple.com/app/wave-mobile-money/id1523884528'
            : 'https://play.google.com/store/apps/details?id=com.wave.personal';
        await launchUrl(Uri.parse(waveStoreUrl), mode: LaunchMode.externalApplication);
        return;
      }

      final uri = Uri.parse(raw);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}
  }

  @override
  Future onBrowserCreated() async {
    if (kDebugMode) {
      print("\n\nBrowser Created!\n\n");
    }
  }

  @override
  Future onLoadStart(url) async {
    if (kDebugMode) {
      print("\n\nStarted: $url\n\n");
    }
    final current = url.toString();
    if (current.startsWith('wave://') || 
        current.startsWith('maxit://') || 
        current.startsWith('sameaosnapp://') || 
        current.startsWith('orangemoney://') || 
        current.startsWith('orange-money://') || 
        current.startsWith('om://') || 
        current.startsWith('intent://') ||
        current.startsWith('sameaosnapp:/') ||
        current.startsWith('maxit:/') ||
        current.startsWith('intent:/')) {
      await _openExternalUrl(current);
      return;
    }
    _redirect(url.toString());
  }

  @override
  Future onLoadStop(url) async {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      print("\n\nStopped: $url\n\n");
    }
    _redirect(url.toString());
  }

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      print("Can't load [$url] Error: $message");
    }
    final failing = url.toString();
    final errorMessage = message.toString();
    
    if (failing.startsWith('wave://') || 
        failing.startsWith('maxit://') || 
        failing.startsWith('sameaosnapp://') || 
        failing.startsWith('orangemoney://') || 
        failing.startsWith('orange-money://') || 
        failing.startsWith('om://') || 
        failing.startsWith('intent://') ||
        failing.startsWith('sameaosnapp:/') ||
        failing.startsWith('maxit:/') ||
        failing.startsWith('intent:/') ||
        errorMessage.contains('ERR_UNKNOWN_URL_SCHEME')) {
      _openExternalUrl(failing);
    }
  }

  @override
  void onProgressChanged(progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
    if (kDebugMode) {
      print("Progress: $progress");
    }
  }

  @override
  void onExit() {
    if(_canRedirect) {
      
    }
    if (kDebugMode) {
      print("\n\nBrowser closed!\n\n");
    }
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(navigationAction) async {
    if (kDebugMode) {
      print("\n\nOverride ${navigationAction.request.url}\n\n");
    }
    final uri = navigationAction.request.url;
    final url = uri?.toString() ?? '';
    if (url.startsWith('wave://') || 
        url.startsWith('maxit://') || 
        url.startsWith('sameaosnapp://') || 
        url.startsWith('orangemoney://') || 
        url.startsWith('orange-money://') || 
        url.startsWith('om://') || 
        url.startsWith('intent://') ||
        url.startsWith('sameaosnapp:/') ||
        url.startsWith('maxit:/') ||
        url.startsWith('intent:/')) {
      await _openExternalUrl(url);
      return NavigationActionPolicy.CANCEL;
    }
    return NavigationActionPolicy.ALLOW;
  }

  @override
  void onLoadResource(resource) {
    if (kDebugMode) {
      print("Started at: ${resource.startTime}ms ---> duration: ${resource.duration}ms ${resource.url ?? ''}");
    }
  }

  @override
  void onConsoleMessage(consoleMessage) {
    if (kDebugMode) {
      print("""
    console output:
      message: ${consoleMessage.message}
      messageLevel: ${consoleMessage.messageLevel.toValue()}
   """);
    }
  }

  void _redirect(String url) {
    if (kDebugMode) {
      print('---url---$url');
    }
    if(_canRedirect) {
      bool isSuccess = url.contains('success?flag=success');
      bool isFailed = url.contains('success?flag=fail');
      bool isCancel = url.contains('success?flag=cancel');
      if (isSuccess || isFailed || isCancel) {
        _canRedirect = false;
        close();
      }

      if(isSuccess || isFailed || isCancel) {
        if(Get.currentRoute.contains(RouteHelper.payment)) {
          Get.back();
        }
        Get.back();
        Get.toNamed(RouteHelper.getWalletAddFundSuccessRoute(isSuccess ? 'success' : isFailed ? 'fail' : 'cancel'));
      }
    }
  }

}

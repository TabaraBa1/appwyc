import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

class PayTech extends StatefulWidget {
  final String paymentUrl;

  const PayTech(this.paymentUrl, {super.key});

  @override
  _PayTechState createState() => _PayTechState();
}

class _PayTechState extends State<PayTech> {
  // late InterstitialAd _interstitialAd;
  // bool _isInterstitialAdReady = false;
  late InAppWebViewController _webViewController;
  double progress = 0;

  // @override
  // void initState() {
  //   super.initState();
  //   _loadInterstitialAd(); // Charger l'annonce interstitielle à l'initialisation
  // }

  // Charger l'annonce interstitielle
  // void _loadInterstitialAd() {
  //   InterstitialAd.load(
  //     adUnitId: 'ca-app-pub-3617476928520921/5163672664', // ID de test
  //     request: AdRequest(),
  //     adLoadCallback: InterstitialAdLoadCallback(
  //       onAdLoaded: (InterstitialAd ad) {
  //         setState(() {
  //           _interstitialAd = ad;
  //           _isInterstitialAdReady = true;
  //         });
  //       },
  //       onAdFailedToLoad: (LoadAdError error) {
  //         print('Failed to load interstitial ad: ${error.message}');
  //       },
  //     ),
  //   );
  // }

  // Affichage de l'annonce interstitielle
  // void _showInterstitialAd() {
  //   if (_isInterstitialAdReady) {
  //     _interstitialAd.show();
  //     // Recharger l'annonce après l'affichage
  //     _loadInterstitialAd();
  //   } else {
  //     print('Interstitial ad is not ready yet.');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFd0b258),
      appBar: AppBar(
        backgroundColor: const Color(0xFFd0b258),
        centerTitle: true,
        title: Text(
          'WYC',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          if (progress < 1.0)
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              color: Color(0xFFd0b258),
            ),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: Uri.parse(widget.paymentUrl)),

              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onProgressChanged: (controller, progressValue) {
                setState(() {
                  progress = progressValue / 100;
                });
              },
              onLoadStop: (controller, url) {
                setState(() {
                  progress = 1.0;
                });

                // Gérer le résultat du paiement : succès, annulation ou échec
                if (url.toString().contains("success")) {
                  _showPaymentStatus(
                    isSuccess: true,
                    message: "Votre paiement a été effectué avec succès ! 🎉 ",
                  );
                  // _showInterstitialAd(); // Afficher l'annonce interstitielle après le succès
                } else if (url.toString().contains("cancel") ||
                    url.toString().contains("failure")) {
                  _showPaymentStatus(
                    isSuccess: false,
                    message: "Votre paiement a échoué ou a été annulé. ❌",
                  );
                  // _showInterstitialAd(); // Afficher l'annonce interstitielle après l'échec ou l'annulation
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Afficher le statut de paiement (succès ou échec)
  void _showPaymentStatus({required bool isSuccess, required String message}) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 50,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Ferme le modal
                  Navigator.pop(context); // Ferme la page de paiement
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess ? Colors.green : Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // @override
  // void dispose() {
  //   if (_isInterstitialAdReady) {
  //     _interstitialAd.dispose();
  //   }
  //   super.dispose();
  // }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_loader_widget.dart';
import 'package:sixam_mart_delivery/features/contract/controllers/contract_controller.dart';
import 'package:sixam_mart_delivery/features/contract/widgets/signature_canvas_widget.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class ContractScreen extends StatefulWidget {
  const ContractScreen({super.key});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  String? _capturedSignature;

  @override
  void initState() {
    super.initState();
    Get.find<ContractController>().getMyContract();
  }

  Future<void> _openDownloadUrl(int contractId) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.downloadContractUri}$contractId');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Erreur', 'Impossible d\'ouvrir le lien de téléchargement', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'mon_contrat'.tr),
      body: GetBuilder<ContractController>(
        builder: (contractController) {
          if (contractController.isLoading) {
            return const CustomLoaderWidget();
          }

          if (contractController.contract == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description_outlined, size: 80, color: Theme.of(context).disabledColor),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Text(
                      'aucun_contrat_disponible'.tr,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(
                      'Aucun contrat n\'a été attribué pour le moment.',
                      style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final contract = contractController.contract!;
          bool isSigned = contract.status == 2 || (contract.signature != null && contract.signature!.isNotEmpty);

          return RefreshIndicator(
            onRefresh: () async {
              await contractController.getMyContract();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: isSigned ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: isSigned ? Colors.green : Colors.orange, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSigned ? Icons.verified : Icons.error_outline,
                          color: isSigned ? Colors.green : Colors.orange,
                          size: 30,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSigned ? 'Contrat Signé' : 'Contrat en attente de signature',
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeMedium,
                                  color: isSigned ? Colors.green[800] : Colors.orange[800],
                                ),
                              ),
                              if (isSigned && contract.signedAt != null)
                                Text(
                                  'Signé le : ${contract.signedAt}',
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // Contract Title
                  Text(
                    contract.title ?? 'Contrat de Prestation',
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // Contract Content Body
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 5, spreadRadius: 1)],
                    ),
                    child: HtmlWidget(
                      contract.content ?? '<p>Aucun contenu disponible.</p>',
                      textStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  // Signature Display or Signature Canvas
                  if (isSigned) ...[
                    Text(
                      'Votre Signature :',
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Container(
                      height: 140,
                      width: double.infinity,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Center(
                        child: contract.signature!.startsWith('data:image')
                            ? Image.memory(
                                base64Decode(contract.signature!.split(',').last),
                                fit: BoxFit.contain,
                              )
                            : Image.memory(
                                base64Decode(contract.signature!),
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // Download Button
                    CustomButtonWidget(
                      buttonText: 'Télécharger le Contrat (PDF)',
                      icon: Icons.download,
                      onPressed: () => _openDownloadUrl(contract.id!),
                    ),
                  ] else ...[
                    // Electronic Signature Canvas Widget
                    SignatureCanvasWidget(
                      onSigned: (base64Img) {
                        setState(() {
                          _capturedSignature = base64Img;
                        });
                      },
                    ),
                    if (_capturedSignature != null) ...[
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      contractController.isSigning
                          ? const CustomLoaderWidget()
                          : CustomButtonWidget(
                              buttonText: 'Confirmer et Transmettre le Contrat',
                              onPressed: () async {
                                bool success = await contractController.signContract(
                                  contract.id!,
                                  _capturedSignature!,
                                );
                                if (success) {
                                  setState(() {
                                    _capturedSignature = null;
                                  });
                                }
                              },
                            ),
                    ],
                  ],
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

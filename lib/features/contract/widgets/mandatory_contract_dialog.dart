import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_loader.dart';
import 'package:sixam_mart_delivery/features/contract/controllers/contract_controller.dart';
import 'package:sixam_mart_delivery/features/contract/widgets/signature_canvas_widget.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';

class MandatoryContractDialog extends StatefulWidget {
  const MandatoryContractDialog({super.key});

  @override
  State<MandatoryContractDialog> createState() => _MandatoryContractDialogState();
}

class _MandatoryContractDialogState extends State<MandatoryContractDialog> {
  String? _capturedSignature;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
        insetPadding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: GetBuilder<ContractController>(
            builder: (contractController) {
              if (contractController.isLoading) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CustomLoaderWidget()),
                );
              }

              final contract = contractController.contract;
              if (contract == null) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.orange),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Text(
                      'Aucun contrat disponible.',
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    CustomButtonWidget(
                      buttonText: 'Réessayer',
                      onPressed: () => contractController.getMyContract(),
                    ),
                  ],
                );
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Warning Header
                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.red),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: Text(
                              'Signature de contrat obligatoire pour continuer',
                              style: robotoBold.copyWith(color: Colors.red[800], fontSize: Dimensions.fontSizeSmall),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Text(
                      contract.title ?? 'Contrat de Prestation',
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Container(
                      height: 250,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: SingleChildScrollView(
                        child: HtmlWidget(
                          contract.content != null && !contract.content!.contains('<')
                              ? contract.content!.replaceAll('\n', '<br>')
                              : (contract.content ?? ''),
                          textStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Text(
                      'Veuillez signer ci-dessous :',
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    SignatureCanvasWidget(
                      onSigned: (base64Img) {
                        setState(() {
                          _capturedSignature = base64Img;
                        });
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    if (_capturedSignature != null)
                      contractController.isSigning
                          ? const Center(child: CustomLoaderWidget())
                          : CustomButtonWidget(
                              buttonText: 'Valider et Signer le Contrat',
                              onPressed: () async {
                                bool success = await contractController.signContract(
                                  contract.id!,
                                  _capturedSignature!,
                                );
                                if (success && context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'package:get/get.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/features/contract/domain/models/contract_model.dart';
import 'package:sixam_mart_delivery/features/contract/domain/services/contract_service_interface.dart';

class ContractController extends GetxController implements GetxService {
  final ContractServiceInterface contractServiceInterface;
  ContractController({required this.contractServiceInterface});

  ContractModel? _contract;
  ContractModel? get contract => _contract;

  ContractModel? _activeContract;
  ContractModel? get activeContract => _activeContract;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSigning = false;
  bool get isSigning => _isSigning;

  Future<void> getMyContract() async {
    _isLoading = true;
    update();
    Response response = await contractServiceInterface.getMyContract();
    if (response.statusCode == 200 && response.body != null) {
      _contract = ContractModel.fromJson(Map<String, dynamic>.from(response.body));
    } else {
      _contract = null;
    }
    _isLoading = false;
    update();
  }

  Future<void> getActiveContract() async {
    _isLoading = true;
    update();
    Response response = await contractServiceInterface.getActiveContract();
    if (response.statusCode == 200 && response.body != null) {
      _activeContract = ContractModel.fromJson(Map<String, dynamic>.from(response.body));
    } else {
      _activeContract = null;
    }
    _isLoading = false;
    update();
  }

  Future<bool> signContract(int contractId, String signatureBase64) async {
    _isSigning = true;
    update();
    Response response = await contractServiceInterface.signContract(contractId, signatureBase64);
    bool isSuccess = false;
    if (response.statusCode == 200) {
      showCustomSnackBar('Contrat signé avec succès !', isError: false);
      try {
        if (response.body != null && response.body['contract'] != null) {
          _contract = ContractModel.fromJson(Map<String, dynamic>.from(response.body['contract']));
        } else {
          await getMyContract();
        }
      } catch (e) {
        await getMyContract();
      }
      isSuccess = true;
    } else {
      showCustomSnackBar(response.statusText ?? 'Échec de la signature du contrat', isError: true);
    }
    _isSigning = false;
    update();
    return isSuccess;
  }
}

import 'package:get/get_connect/http/src/response/response.dart';
import 'package:sixam_mart_delivery/features/contract/domain/repositories/contract_repository_interface.dart';
import 'package:sixam_mart_delivery/features/contract/domain/services/contract_service_interface.dart';

class ContractService implements ContractServiceInterface {
  final ContractRepositoryInterface contractRepositoryInterface;
  ContractService({required this.contractRepositoryInterface});

  @override
  Future<Response> getMyContract() async {
    return await contractRepositoryInterface.getMyContract();
  }

  @override
  Future<Response> signContract(int contractId, String signatureBase64) async {
    return await contractRepositoryInterface.signContract(contractId, signatureBase64);
  }
}

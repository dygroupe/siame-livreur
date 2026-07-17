import 'package:get/get_connect/http/src/response/response.dart';
import 'package:sixam_mart_delivery/api/api_client.dart';
import 'package:sixam_mart_delivery/features/contract/domain/repositories/contract_repository_interface.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';

class ContractRepository implements ContractRepositoryInterface {
  final ApiClient apiClient;
  ContractRepository({required this.apiClient});

  @override
  Future<Response> getMyContract() async {
    return await apiClient.getData(AppConstants.getContractUri);
  }

  @override
  Future<Response> signContract(int contractId, String signatureBase64) async {
    return await apiClient.postData(AppConstants.signContractUri, {
      'contract_id': contractId,
      'signature': signatureBase64,
    });
  }

  @override
  Future add(value) => throw UnimplementedError();

  @override
  Future delete(int? id) => throw UnimplementedError();

  @override
  Future get(String? id) => throw UnimplementedError();

  @override
  Future getList({int? offset}) => throw UnimplementedError();

  @override
  Future update(Map<String, dynamic> body, int? id) => throw UnimplementedError();
}

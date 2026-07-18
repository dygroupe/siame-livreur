import 'package:get/get_connect/http/src/response/response.dart';

abstract class ContractServiceInterface {
  Future<Response> getMyContract();
  Future<Response> getActiveContract();
  Future<Response> signContract(int contractId, String signatureBase64);
}

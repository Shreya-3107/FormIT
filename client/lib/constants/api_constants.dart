// lib/constants/api_constants.dart

class ApiConstants {
  static const String baseUrl = "http://localhost:3000/api";

  // Gemini AI call
  static const String suggestModules = "$baseUrl/gemini/suggest-modules";
  static const String suggestFields = "$baseUrl/gemini/suggest-fields";

  // Auth
  static const String signup = "$baseUrl/auth/signup";
  static const String login = "$baseUrl/auth/login";
  static const String getUserID = "$baseUrl/auth/get-id";
  static const String getUserDetails = "$baseUrl/auth/user/"; //followed by user id
  static const String updateUserDetails = "$baseUrl/auth/update/user/"; //followed by user id
  static const String deleteUser = "$baseUrl/auth/user"; //no need for id cuz of jwt auth token

  // Organization
  static const String createOrg = "$baseUrl/orgs/create";
  static const String getAllOrgs = "$baseUrl/orgs/getall";
  static const String getOrgDetails = "$baseUrl/orgs/get/"; //followed by org id
  static const String updateOrgDetails = "$baseUrl/orgs/update/"; //followed by org id
  static const String deleteOrg = "$baseUrl/orgs/delete/"; //followed by org id

  // Modules
  static const String createModule = "$baseUrl/modules/create";
  static const String getModulesForOrg = "$baseUrl/modules/all/"; //followed by org id
  static const String getSingleModuleDetails = "$baseUrl/modules/get/"; //followed by module id
  static const String updateModuleDetails = "$baseUrl/modules/update/"; //followed by module id
  static const String deleteModule = "$baseUrl/modules/delete/"; //followed by module id

  // Fields
  static const String createField = "$baseUrl/fields/create";
  static const String getFieldsForModule = "$baseUrl/fields/getForMod/"; //followed by module id
  static const String getFieldDetails = "$baseUrl/fields/getField/"; //followed by field id
  static const String updateFieldDetails = "$baseUrl/fields/update/"; //followed by field id
  static const String deleteField = "$baseUrl/fields/delete/"; //followed by field id

  // Records
  static const String createRecord = "$baseUrl/records/create";
  static const String getRecordsForModule = "$baseUrl/records/list/"; //followed by module-id
  static const String getRecordDetails = "$baseUrl/records/detailed/"; //followed by module-id/field-id
  static const String updateRecordDetails = "$baseUrl/records/update/"; //followed by module-id/field-id
  static const String deleteRecordDetails = "$baseUrl/records/delete/"; //followed by module-id/field-id
}

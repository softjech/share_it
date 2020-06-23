import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  searchByName(String searchField) {
    return Firestore.instance
        .collection('users')
        .where('searchKey', isEqualTo: searchField)
        .getDocuments();
  }
}

class SearchServiceByName {
  searchByName(String searchField) {
    return Firestore.instance
        .collection('users')
        .where('nameKey', isEqualTo: searchField)
        .getDocuments();
  }
}

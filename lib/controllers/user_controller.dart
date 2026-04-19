import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserController extends GetxController {
  final supabase = Supabase.instance.client;

  var currentUser = Rxn<UserModel>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    
 
    final session = supabase.auth.currentSession;
    if (session != null) {
      getUserProfile();
    }
  }

  Future<void> getUserProfile() async {
    try {
      final userAuth = supabase.auth.currentUser;

      if (userAuth != null) {
        isLoading.value = true;

        final data = await supabase
            .from('users')
            .select()
            .eq('id', userAuth.id)
            .single();

        currentUser.value = UserModel.fromMap(data);

        print("Profil Berhasil Diambil: ${currentUser.value?.namaLengkap}");
      }
    } catch (e) {
      print("Error ambil profil: ");
    } finally {
      isLoading.value = false;
    }
  }

  bool get isOwner => currentUser.value?.role == 'owner';


  int get outletId => currentUser.value?.outletId ?? 0;
}
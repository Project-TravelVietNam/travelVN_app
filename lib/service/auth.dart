import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Đăng ký
  Future<String> signUpUser(
      {required String email,
      required String password,
      required String confirmPassword}) async {
    String res;
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          confirmPassword.isNotEmpty) {
        // kiểm tra pass
        if (password == confirmPassword) {
          UserCredential credential = await _auth
              .createUserWithEmailAndPassword(email: email, password: password);
          // add dữ liệu vào firestrore
          await _firestore
              .collection("users")
              .doc(credential.user!.uid)
              .set({'email': email, 'uid': credential.user!.uid});
          return res = "Đăng ký thành công!";
        } else {
          return res = "Mật khẩu không trùng khớp!";
        }
      } else {
        return res = "Vui lòng điền đầy đủ thông tin!";
      }
    } catch (e) {
      return e.toString();
    }
  }
  // Đăng nhập
  Future<String> loginUser({ 
    required String email,
    required String password 
  }) async {
    String res;
    try{
      if(email.isNotEmpty || password.isNotEmpty){
        //email và password
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        return res = "Đăng nhập thành công!";
      }else{
        return res = "Vui lòng điền đầy đủ thông tin!";
      }
    } catch(e){
      return e.toString();
    } 
  }
}

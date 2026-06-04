// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// class GoogleAuthService {
//   Future<UserCredential?> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//
//       if (googleUser == null) {
//         return null;
//       }
//
//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;
//
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       UserCredential userCredential =
//           await FirebaseAuth.instance.signInWithCredential(credential);
//
//       return userCredential;
//     } catch (e) {
//       print('GOOGLE LOGIN ERROR ==> $e');
//       return null;
//     }
//   }
// }

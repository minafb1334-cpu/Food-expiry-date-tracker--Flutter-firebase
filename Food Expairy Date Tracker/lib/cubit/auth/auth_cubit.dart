import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthCubit() : super(AuthInitial());

 
  void login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      emit(AuthSuccess(user: _auth.currentUser));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  
  void register({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      emit(AuthSuccess(user: _auth.currentUser));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

 
  void logout() async {
    await _auth.signOut();
    emit(AuthInitial());
  }

 
  void checkLoggedIn() {
    final user = _auth.currentUser;
    if (user != null) {
      emit(AuthSuccess(user: user));
    } else {
      emit(AuthInitial());
    }
  }
}

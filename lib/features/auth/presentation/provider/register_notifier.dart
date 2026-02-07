import 'package:flutter/material.dart';

import 'dart:developer' as dev;

import 'package:flutter_event/common/helpers/enum.dart';
import 'package:flutter_event/common/helpers/storage.dart';

import 'package:flutter_event/features/auth/domain/usecases/register.dart';
import 'package:flutter_event/snackbar.dart';

class RegisterNotifier with ChangeNotifier {
  final RegisterUseCase registerUseCase;

  RegisterNotifier({
    required this.registerUseCase
  });

  late TextEditingController fullnameC;
  late TextEditingController emailC;
  late TextEditingController passwordC;

  ProviderState _state = ProviderState.loading;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;
    
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> register() async {
    setStateProvider(ProviderState.loading);
    try {

      if(fullnameC.text.trim() == "") {
        ShowSnackbar.snackbarErr("Field fullname is required");
        return;
      }

      if(emailC.text.trim() == "") {
        ShowSnackbar.snackbarErr("Field email is required");
        return;
      }

      if(passwordC.text.trim() == "") {
        ShowSnackbar.snackbarErr("Field password is required");
        return;
      }
      
      final result = await registerUseCase.execute(
        fullname: fullnameC.text,
        email: emailC.text, 
        password: passwordC.text
      );

      result.fold((l) {
        setStateProvider(ProviderState.error);
        _message = l.message;
      }, (r) {
        StorageHelper.saveToken(token: r.data.token);

        setStateProvider(ProviderState.loaded);
      });

    } catch(e) {
      dev.log(e.toString());
      setStateProvider(ProviderState.error);
    }

  }

}
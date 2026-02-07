import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_event/common/helpers/enum.dart';

import 'package:flutter_event/features/auth/data/models/profile.dart';
import 'package:flutter_event/features/auth/domain/usecases/profile.dart';

class ProfileNotifier with ChangeNotifier {
  final ProfileUseCase profileUseCase;

  ProfileNotifier({
    required this.profileUseCase
  });

  late TextEditingController emailC;
  late TextEditingController passC; 

  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  ProfileData _entity = ProfileData();
  ProfileData get entity => _entity;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> getProfile() async {
    setStateProvider(ProviderState.loading);

    final result = await profileUseCase.execute();

    result.fold((l) {
      _message = l.message;
      setStateProvider(ProviderState.error);
    }, (r) {
      _entity = r.data;
      setStateProvider(ProviderState.loaded);
    });
  }

}
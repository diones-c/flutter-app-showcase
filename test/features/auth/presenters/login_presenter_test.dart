import 'package:flutter_demo/core/domain/model/user.dart';
import 'package:flutter_demo/features/auth/domain/model/log_in_failure.dart';
import 'package:flutter_demo/features/auth/login/login_initial_params.dart';
import 'package:flutter_demo/features/auth/login/login_presentation_model.dart';
import 'package:flutter_demo/features/auth/login/login_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../test_utils/test_utils.dart';
import '../mocks/auth_mock_definitions.dart';
import '../mocks/auth_mocks.dart';

void main() {
  late LoginPresentationModel model;
  late LoginPresenter presenter;
  late MockLoginNavigator navigator;

  setUp(() {
    model = LoginPresentationModel.initial(const LoginInitialParams());
    navigator = MockLoginNavigator();
    presenter = LoginPresenter(
      model,
      navigator,
      AuthMocks.logInUseCase,
    );
  });

  const user = User(
    id: 'id',
    username: 'username',
  );

  const username = 'username';
  const password = 'password';
  const title = 'title';
  const message = 'message';

  group('toggleLoginButton', () {
    test('shoud disable login button when username is not provided', () {
      // WHEN
      presenter.usernameChanged(username);

      //THEN
      expect(presenter.state.isLoginEnabled, false);
    });

    test('shoud disable login button when password is not provided', () {
      // WHEN
      presenter.passwordChanged(password);

      //THEN
      expect(presenter.state.isLoginEnabled, false);
    });

    test('shoud enable login button when username and password are provided', () {
      // WHEN
      presenter.usernameChanged(username);
      presenter.passwordChanged(password);

      //THEN
      expect(presenter.state.isLoginEnabled, true);
    });
  });

  group('LogInUseCase', () {
    test(
      'should show an error when LogInUseCase fails with error',
      () async {
        // GIVEN
        when(
          () => AuthMocks.logInUseCase.execute(
            username: any(named: username),
            password: any(named: password),
          ),
        ).thenAnswer((_) => failFuture(const LogInFailure.unknown()));

        when(() => navigator.showError(any())).thenAnswer((_) => Future.value());

        // WHEN
        await presenter.onLoginButtonTapped();

        // THEN
        verify(() => navigator.showError(any())).called(1);
      },
    );

    test(
      'should show an success when LogInUseCase occur correctly',
      () async {
        // GIVEN
        when(
          () => AuthMocks.logInUseCase.execute(
            username: any(named: username),
            password: any(named: password),
          ),
        ).thenAnswer((_) => successFuture(user));

        when(
          () => navigator.showAlert(
            title: any(named: title),
            message: any(named: message),
          ),
        ).thenAnswer((_) => Future.value());

        // WHEN
        await presenter.onLoginButtonTapped();

        // THEN
        verify(
          () => navigator.showAlert(
            title: any(named: title),
            message: any(named: message),
          ),
        ).called(1);
      },
    );
  });
}

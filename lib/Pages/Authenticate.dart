import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/Pages/Home.dart';
import 'package:wallet/Pages/Loading.dart';
import 'package:wallet/bloc/mainNavigation.dart';
import 'package:wallet/models/authenticator.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  final String _error = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<AuthenticateBloc>().add(
            LoadAuthenticate(),
          );
    }
  }

  Widget PINPageUi(AuthenticateState state, BuildContext context) {
    void submitForm() {
      if (_formKey.currentState!.validate()) {
        String value = _controller.text;
        _controller.clear();
        if (state is CreatingAuthenticate) {
          if (state.typedPin.isEmpty) {
            context.read<AuthenticateBloc>().add(
                  OnCreatingAuthenticate(value),
                );
          } else if (state.typedPin.isNotEmpty && state.typedPin != value) {
            context.read<AuthenticateBloc>().add(
                  const OnAuthenticateError("Pin did not match"),
                );
          } else {
            context.read<AuthenticateBloc>().add(
                  OnCreatingAuthenticate(value),
                );
          }
        } else if (state is AuthenticateLoaded) {
          context.read<AuthenticateBloc>().add(
                LoginAuthenticate(value),
              );
        }
      }
    }

    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                20,
              ),
              color: Theme.of(context).disabledColor),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ((state is CreatingAuthenticate)
                      ? (state.typedPin.isEmpty)
                          ? "Create Pin"
                          : "Re-type Pin"
                      : (state is AuthenticateLoaded)
                          ? "Insert your Pin"
                          : ""),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    maxLength: 6,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value';
                      } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                        return "Digits only";
                      } else if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                        return "Must Be Six Digits";
                      }
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: InputDecoration(
                      counterText: '',
                      errorText: (_error == '') ? null : _error,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 10,
                      fontSize: 20,
                    ),
                    onFieldSubmitted: (_) => submitForm(),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: submitForm,
                  child: Text(
                    'Submit',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<AuthenticateBloc, AuthenticateState>(
        listener: (context, state) {
          if (state is AuthenticateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.redAccent,
                content: Text(
                  state.message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          switch (state) {
            case AuthenticateInitial():
              return const Loading();
            case Authenticated():
              return BlocBuilder<NavigationBloc, NavigationState>(
                  builder: (context, state) {
                if (state is NavigationLoaded) {
                  return state.screen;
                } else {
                  return const HomeScreen();
                }
              });
            case AuthenticateLoaded() || CreatingAuthenticate():
              return PINPageUi(state, context);
            case AuthenticateError():
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            context
                                .read<AuthenticateBloc>()
                                .add(LoadAuthenticate());
                          },
                          child: const Text("Retry"))
                    ],
                  ),
                ),
              );
            default:
              return const SizedBox();
          }
        },
      ),
    );
  }
}

import 'dart:async';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:swap_toys/models/product.dart';
import 'package:swap_toys/models/user.dart';
import 'package:swap_toys/pages/message_page.dart';
import 'package:swap_toys/pages/search_page.dart';
import 'package:swap_toys/pages/home_page.dart';
import 'package:swap_toys/pages/profile_page.dart';
import 'package:swap_toys/pages/styles.dart';
import 'package:rxdart/rxdart.dart';

late user User_;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();
final displayName = TextEditingController();

int currentPageIndex = 0;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  static const String title = "Setup Firebase";

  @override
  Widget build(BuildContext context) => MaterialApp(
        scaffoldMessengerKey: Utils.messengryKey,
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: title,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Montserrat',
        ),
        home: const MainPage(),
      );
}

class AppPage extends StatefulWidget {
  const AppPage({super.key, required this.title});
  final String title;

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  List<Widget> screens = [
    HomePage(),
    SearchPage(),
    ProfilePage(FirebaseAuth.instance.currentUser!.email!),
    MessagePage()
  ];

  Stream<Map<String, bool>> getBadges() {
    final chats = FirebaseFirestore.instance
        .collection('users')
        .doc(User_.email)
        .collection('chats')
        .snapshots()
        .map((snapshot) {
      bool hasUnreadMessage = false;
      for (var change in snapshot.docChanges) {
        if (change.doc.exists && !change.doc.data()!['isRead']) {
          hasUnreadMessage = true;
          break;
        }
      }
      return hasUnreadMessage;
    });

    final Stream<bool> offers = FirebaseFirestore.instance
        .collection('users')
        .doc(User_.email)
        .collection('offers')
        .snapshots()
        .map((snapshot) {
      bool hasOffer = false;
      if (snapshot.docs.isNotEmpty) {
        hasOffer = true;
      }
      return hasOffer;
    });

    final Stream<bool> notifications = FirebaseFirestore.instance
        .collection('users')
        .doc(User_.email)
        .collection('notifications')
        .snapshots()
        .map((snapshot) {
      bool hasOffer = false;
      if (snapshot.docs.isNotEmpty) {
        hasOffer = true;
      }
      return hasOffer;
    });

    final hasNotification =
        Rx.combineLatest2(offers, notifications, (a, b) => a || b);

    return Rx.combineLatest2(chats, hasNotification,
        (message, profile) => {"message": message, "profile": profile});
  }

  @override
  Widget build(BuildContext context) {
    Future<void> setuserProduct() async {
      String userId = FirebaseAuth.instance.currentUser!.email!;
      var usrRef = await FirebaseFirestore.instance.collection('users').get();
      for (var usr in usrRef.docs) {
        if (usr["email"] == userId) {
          User_.displayName = usr["displayName"];
          await User_.MyProducts(usr);
        }
      }
    }

    User_ = user(displayName.text, FirebaseAuth.instance.currentUser!.email!);
    var ref = FirebaseFirestore.instance.collection("users").doc(User_.email);

    ref.snapshots().listen((snapshot) {
      if (!snapshot.exists) {
        User_.saveUser();
      } else {
        setuserProduct();
      }
    });

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 244, 237, 249),
      body: screens[currentPageIndex],
      bottomNavigationBar: StreamBuilder<Map<String, bool>>(
          stream: getBadges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GNav(
                selectedIndex: currentPageIndex,
                color: backgroundColorDefault,
                backgroundColor: Colors.blue,
                activeColor: Colors.indigo,
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                duration: Duration.zero,
                tabs: [
                  const GButton(
                    icon: Icons.explore_rounded,
                    iconSize: 30,
                  ),
                  const GButton(
                    icon: Icons.search_rounded,
                    iconSize: 30,
                  ),
                  GButton(
                      icon: Icons.account_circle_rounded,
                      iconSize: 30,
                      leading: snapshot.data!["profile"]!
                          ? Badge(
                              badgeContent: const Text(""),
                              position: BadgePosition.topEnd(end: 0, top: -7),
                              child: Icon(
                                Icons.account_circle_rounded,
                                color: currentPageIndex != 3
                                    ? Colors.white
                                    : Colors.indigo,
                                size: 30,
                              ),
                            )
                          : null),
                  GButton(
                      icon: Icons.mail_outline_rounded,
                      iconSize: 30,
                      leading: snapshot.data!["message"]!
                          ? Badge(
                              badgeContent: const Text(""),
                              position: BadgePosition.topEnd(end: -2, top: -7),
                              child: Icon(
                                Icons.mail_outline_rounded,
                                color: currentPageIndex != 3
                                    ? Colors.white
                                    : Colors.indigo,
                                size: 30,
                              ),
                            )
                          : null)
                ],
                onTabChange: (index) {
                  setState(() {
                    currentPageIndex = index;
                  });
                },
              );
            } else if (snapshot.hasError) {
              print("eror");
              return Container();
            } else {
              return GNav(
                selectedIndex: currentPageIndex,
                color: backgroundColorDefault,
                backgroundColor: Colors.blue,
                activeColor: Colors.indigo,
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                duration: Duration.zero,
                tabs: const [
                  GButton(
                    icon: Icons.explore,
                    iconSize: 30,
                  ),
                  GButton(
                    icon: Icons.search,
                    iconSize: 30,
                  ),
                  GButton(
                    icon: Icons.account_circle,
                    iconSize: 30,
                  ),
                  GButton(
                    icon: Icons.mail_outline_rounded,
                    iconSize: 30,
                  )
                ],
                onTabChange: (index) {
                  setState(() {
                    currentPageIndex = index;
                  });
                },
              );
            }
          }),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Bir şeyler yanlış gitti!"));
            } else if (snapshot.hasData) {
              return VerifyEmailPage();
            } else {
              return const AuthPage();
            }
          },
        ),
      );
}

class VerifyEmailPage extends StatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool? isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified;
    if (!isEmailVerified!) {
      sendVerificationEmail();

      timer = Timer.periodic(
          const Duration(seconds: 3), (_) => checkEmailVerified());
    }

    @override
    void dispose() {
      timer?.cancel();

      super.dispose();
    }
  }

  Future checkEmailVerified() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.currentUser!.reload();
      setState(() {
        isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      });

      if (isEmailVerified!) timer?.cancel();
    } //call after email verification
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));

      setState(() => canResendEmail = false);
    } catch (e) {
      Utils.showSnackBar(e.toString(), Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerified!
        ? const AppPage(title: "app page")
        : Scaffold(
            appBar: AppBar(
              title: const Text("E-posta doğrulama"),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "e-postanıze bir doğrulama postası gönderilmiştir !",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      icon: const Icon(Icons.mail, size: 32),
                      label: const Text(
                        "Postayı tekrar gönder",
                        style: TextStyle(fontSize: 24),
                      ),
                      onPressed: canResendEmail ? sendVerificationEmail : null),
                  const SizedBox(
                    height: 8,
                  ),
                  TextButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50)),
                      child: const Text("İptal et",
                          style: TextStyle(fontSize: 24)),
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        timer?.cancel();
                      })
                ],
              ),
            ));
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) => isLogin
      ? LoginWidget(onClickedSignUp: toggle)
      : SignUpWidget(onClickedSignIn: toggle);
  void toggle() => setState(() => isLogin = !isLogin);
}

class SignUpWidget extends StatefulWidget {
  final Function() onClickedSignIn;

  const SignUpWidget({
    Key? key,
    required this.onClickedSignIn,
  }) : super(key: key);

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();

  void onClickedSignUp() {}
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('lib/assets/images/background.png'),
                  fit: BoxFit.cover)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(46, 60, 46, 0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(" Kayıt Ol",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    cursorColor: Colors.white,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        labelText: "E-Posta",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white))),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) =>
                        email != null && !EmailValidator.validate(email)
                            ? "Lütfen geçerli bir e-posta adresi giriniz."
                            : null,
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: displayName,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        labelText: "Kullanıcı Adı",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white))),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: ((value) => value != null && value.length < 6
                        ? "Lütfen en az 2 karakter giriniz."
                        : null),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: passwordController,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        labelText: "Şifre",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white))),
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: ((value) => value != null && value.length < 6
                        ? "Lütfen en az 6 karakter giriniz."
                        : null),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: confirmPasswordController,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        labelText: "Şifreyi doğrula",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white))),
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: ((value) =>
                        value != null && value != passwordController.text.trim()
                            ? "Şifreleriniz uyuşmuyor!"
                            : null),
                  ),
                  const SizedBox(height: 35),
                  Center(
                      child: ElevatedButton(
                    style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all<Size>(
                            const Size(300, 45)),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22)))),
                    child: Text(
                      "Kayıt Ol",
                      style:
                          TextStyle(fontSize: 20, color: Colors.blue.shade600),
                    ),
                    onPressed: signUp,
                  )),
                  const SizedBox(height: 100),
                  Center(
                      child: Text("Zaten hesabınız var mı?",
                          style: TextStyle(color: Colors.white))),
                  SizedBox(height: 8),
                  Center(
                      child: ElevatedButton(
                    style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all<Size>(
                            const Size(120, 45)),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22)))),
                    child: Text(
                      "Giriş Yap",
                      style:
                          TextStyle(fontSize: 20, color: Colors.blue.shade600),
                    ),
                    onPressed: widget.onClickedSignIn,
                  )),
                ],
              ),
            ),
          )));

  Future signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message, Colors.red);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}

class Utils {
  static GlobalKey<ScaffoldMessengerState> messengryKey =
      GlobalKey<ScaffoldMessengerState>();
  static showSnackBar(String? text, Color color) {
    if (text == null) return;

    final snackBar = SnackBar(content: Text(text), backgroundColor: color);

    messengryKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

class LoginWidget extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const LoginWidget({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  @override
  _LoginWidgetState createState() => _LoginWidgetState();

  void onClickedSignIn() {}
}

class _LoginWidgetState extends State<LoginWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('lib/assets/images/background.png'),
                fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(46, 60, 46, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(" Giriş Yap",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800)),
              SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: "E-Posta",
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white))),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) =>
                    email != null && !EmailValidator.validate(email)
                        ? "Lütfen geçerli bir e-posta adresi giriniz."
                        : null,
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: passwordController,
                textInputAction: TextInputAction.done,
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: "Şifre",
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white))),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: ((value) => value != null && value.length < 6
                    ? "Lütfen en az 6 karakter giriniz."
                    : null),
              ),
              const SizedBox(height: 4),
              const SizedBox(height: 35),
              Center(
                  child: ElevatedButton(
                style: ButtonStyle(
                    minimumSize:
                        MaterialStateProperty.all<Size>(const Size(300, 45)),
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22)))),
                child: Text(
                  "Giriş Yap",
                  style: TextStyle(fontSize: 20, color: Colors.blue.shade600),
                ),
                onPressed: signIn,
              )),
              const SizedBox(height: 5),
              GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotPasswordPage())),
                  child: Center(
                    child: const Text(
                      "Şifremi Unuttum",
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
              const SizedBox(height: 100),
              Center(
                  child: Text("Hesabınız yok mu?",
                      style: TextStyle(color: Colors.white))),
              SizedBox(height: 8),
              Center(
                  child: ElevatedButton(
                style: ButtonStyle(
                    minimumSize:
                        MaterialStateProperty.all<Size>(const Size(120, 45)),
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22)))),
                child: Text(
                  "Kayıt Ol",
                  style: TextStyle(fontSize: 20, color: Colors.blue.shade600),
                ),
                onPressed: widget.onClickedSignUp,
              )),
            ],
          ),
        ),
      ));

  Future signIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message, Colors.red);
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('lib/assets/images/background.png'),
                fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Şifremi Unuttum",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: emailController,
                  cursorColor: Colors.white,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                      labelText: "E-Posta",
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white))),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (email) =>
                      email != null && !EmailValidator.validate(email)
                          ? "Lütfen geçerli bir e-posta adresi giriniz."
                          : null,
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: resetPassword,
                    style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all<Size>(
                            const Size(120, 45)),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22)))),
                    child: const Text(
                      "Şiremi Sıfırla",
                      style: TextStyle(color: Colors.blue),
                    ))
              ],
            ),
          ),
        ),
      ));

  void resetPassword() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());

      Utils.showSnackBar("Şifre sıfırlama talebi gönderildi!", Colors.green);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message, Colors.red);
      Navigator.of(context).pop();
    }
  }
}

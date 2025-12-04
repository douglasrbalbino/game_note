import 'dart:async'; // <--- IMPORTANTE: Adicione esta linha
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_page.dart';
// import 'forgot_password_page.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false; 
  
  final Color _headerPurple = const Color(0xFFD1C4E9);
  final Color _accentPurple = const Color(0xFF7C4DFF);

  void _doLogin() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      // Tenta logar com um limite de 15 segundos
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ).timeout(const Duration(seconds: 15)); 

      // Se passar daqui, o login deu certo.
      // O main.dart vai trocar a tela automaticamente.

    } on TimeoutException {
      // SE DEMORAR DEMAIS:
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("A conexão está demorando muito. Verifique sua internet."),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // SE DER ERRO NO FIREBASE:
      if (mounted) {
        setState(() => _isLoading = false);
        String msg = "Erro desconhecido";
        
        if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
          msg = "E-mail ou senha incorretos.";
        } else if (e.code == 'invalid-email') {
          msg = "E-mail inválido.";
        } else if (e.code == 'user-not-found') {
          msg = "Usuário não encontrado.";
        } else if (e.code == 'network-request-failed') {
          msg = "Sem conexão com a internet ou firewall bloqueando.";
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabeçalho
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _headerPurple,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videogame_asset, size: 80, color: Colors.black87),
                  const SizedBox(height: 10),
                  const Text("Game Note", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Formulário
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "E-mail",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true, fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Senha",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true, fillColor: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 30),

                  // Botão Entrar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _doLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading 
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Text("ENTRAR", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 30),

                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SignupPage())),
                    child: Text("Criar nova conta", style: TextStyle(color: _accentPurple, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}